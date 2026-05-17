import Foundation
import Combine

// MARK: - AURA Intelligence Service

/// Main orchestrator for the AURA recommendation + chronicle engines.
/// Coordinates questionnaire → profile derivation → deterministic ranking → optional Gemini rerank.
@MainActor
final class AURAIntelligenceService: ObservableObject {

    @Published var isLoading = false
    @Published var lastError: String?

    private let geminiClient = GeminiRecommendationClient()
    let persistenceStore = RegistryPersistenceStore.shared

    // MARK: - Recommendation Pipeline

    /// Full recommendation pipeline: derive profile → rank → optionally rerank with Gemini → group.
    func generateRecommendations(
        payload: RegistryQuestionnairePayload,
        catalog: [CatalogProduct]
    ) async -> RegistryRecommendationResponse {
        isLoading = true
        lastError = nil

        defer { isLoading = false }

        // 1. Derive profile and context from questionnaire
        let context = QuestionnaireReducer.buildContext(from: payload)
        let profile = context.profile

        // 2. Deterministic ranking
        let deterministicResults = DeterministicRecommendationRanker.rank(
            candidates: catalog,
            profile: profile,
            context: context,
            maxResults: AURAConfiguration.maxRecommendationCandidates
        )

        // 3. Optional Gemini rerank
        let finalResults: [RankedRecommendation]
        if !AURAConfiguration.useMockMode {
            finalResults = await geminiClient.rerank(
                candidates: deterministicResults,
                profile: profile,
                intent: "Registry recommendation for \(profile.primaryStyle) home"
            )
        } else {
            finalResults = deterministicResults
        }

        // 4. Group by category
        let sections = DeterministicRecommendationRanker.groupByCategory(finalResults)

        // 5. Persist snapshot
        await persistenceStore.saveRecommendations(finalResults, sections: sections)
        await persistenceStore.saveQuestionnaire(payload)

        // 6. Build summary
        let skippedKeys = payload.selections
            .filter { $0.state == .skipped }
            .map(\.key)
        let photoDescriptor: String = {
            guard let count = payload.moodboardPhotoCount, count > 0 else { return "vibe notes" }
            return "\(count) moodboard photo\(count == 1 ? "" : "s") and vibe notes"
        }()
        let summaryNote = skippedKeys.isEmpty
            ? "Personalized from your \(photoDescriptor) and complete profile."
            : "Curated from your \(photoDescriptor) and available answers. Add more details to refine further."

        return RegistryRecommendationResponse(
            contextSummary: summaryNote,
            recommendations: finalResults,
            categorySections: sections
        )
    }

    // MARK: - Load Cached Recommendations

    func loadCachedRecommendations() async -> RegistryRecommendationResponse? {
        guard let cached = await persistenceStore.loadRecommendations() else { return nil }
        return RegistryRecommendationResponse(
            contextSummary: "Showing your previously generated recommendations.",
            recommendations: cached.recommendations,
            categorySections: cached.sections
        )
    }

    // MARK: - Fetch Product Catalog

    /// Fetches products from the API and converts to CatalogProducts for ranking.
    func fetchCatalogProducts() async -> [CatalogProduct] {
        do {
            let response: ProductResponseDTO = try await APIClient.shared.request(Endpoint.products())
            let liveCatalog = response.products.map { CatalogProduct(from: $0) }
            if liveCatalog.count >= 80 {
                return liveCatalog
            }

            // Enrich small live feeds for richer hackathon demos.
            let merged = Dictionary(
                uniqueKeysWithValues: (liveCatalog + MockProductCatalog.sampleProducts).map { ($0.id, $0) }
            )
            return Array(merged.values)
        } catch {
            print("[AURAIntelligenceService] Failed to fetch catalog: \(error)")
            lastError = "Failed to load product catalog."
            return MockProductCatalog.sampleProducts
        }
    }

    // MARK: - Chronicle

    func generateTimeline(
        purchases: [ChroniclePurchaseRecord]
    ) -> ChronicleTimelineResponse {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: purchases) { record in
            calendar.component(.year, from: record.purchaseDate)
        }

        let sections = grouped.map { year, entries in
            ChronicleTimelineSection(year: year, entries: entries.sorted { $0.purchaseDate > $1.purchaseDate })
        }
        .sorted { $0.year > $1.year }

        let brands = Set(purchases.map(\.brand))
        let rooms = Set(purchases.map(\.room))

        let summary = ChronicleSummary(
            totalItemsTracked: purchases.count,
            brandsCovered: Array(brands),
            roomsDetected: Array(rooms),
            replacementAlertsCount: 0,
            gapSignalsCount: 0
        )

        return ChronicleTimelineResponse(summary: summary, timeline: sections)
    }

    func generateReplacementAlerts(
        purchases: [ChroniclePurchaseRecord],
        policies: [ProductLifecyclePolicy]
    ) -> [ReplacementAlert] {
        let now = Date()
        let calendar = Calendar.current
        var alerts: [ReplacementAlert] = []

        for purchase in purchases {
            guard let policy = policies.first(where: {
                purchase.category.lowercased().contains($0.category.lowercased())
            }) else { continue }

            let ageMonths = calendar.dateComponents([.month], from: purchase.purchaseDate, to: now).month ?? 0
            let score = Double(ageMonths) / Double(policy.expectedLifespanMonths)

            guard score >= policy.monitorThreshold else { continue }

            let urgency: String
            let recommendation: String

            if score > 1.0 {
                urgency = "Ready to Replace"
                recommendation = "This \(purchase.productName) has exceeded its expected lifespan. Consider a quality replacement."
            } else {
                urgency = "Watch"
                recommendation = "Your \(purchase.productName) is approaching its expected lifespan. Plan ahead for a replacement."
            }

            alerts.append(ReplacementAlert(
                id: "alert-\(purchase.id)",
                productID: purchase.productID,
                productName: purchase.productName,
                ageMonths: ageMonths,
                expectedLifespanMonths: policy.expectedLifespanMonths,
                replacementScore: score,
                urgencyLabel: urgency,
                recommendationText: recommendation
            ))
        }

        return alerts.sorted { $0.replacementScore > $1.replacementScore }
    }

    func detectRoomGaps(
        purchases: [ChroniclePurchaseRecord],
        targetRooms: [AURARoomType]
    ) -> [RoomGapSignal] {
        let coveredRooms = Set(purchases.map(\.room))
        let coveredCategories = Dictionary(grouping: purchases, by: \.room)
            .mapValues { Set($0.map(\.category)) }

        var gaps: [RoomGapSignal] = []

        for room in targetRooms {
            if !coveredRooms.contains(room) {
                gaps.append(RoomGapSignal(
                    id: "gap-\(room.rawValue)",
                    room: room,
                    missingCategories: essentialCategories(for: room),
                    recommendationReason: "No items found for your \(room.rawValue) — consider adding essentials."
                ))
            } else if let categories = coveredCategories[room],
                      categories.count < 3 {
                let essentials = essentialCategories(for: room)
                let missing = essentials.filter { !categories.contains($0) }
                if !missing.isEmpty {
                    gaps.append(RoomGapSignal(
                        id: "gap-\(room.rawValue)-partial",
                        room: room,
                        missingCategories: missing,
                        recommendationReason: "Your \(room.rawValue) collection is growing. Add \(missing.first ?? "items") to complete it."
                    ))
                }
            }
        }

        return gaps
    }

    private func essentialCategories(for room: AURARoomType) -> [String] {
        switch room {
        case .kitchen: return ["Cookware", "Cutlery", "Small Appliances"]
        case .dining: return ["Dinnerware", "Glassware", "Serveware"]
        case .living: return ["Throws", "Decor", "Lighting"]
        case .bedroom: return ["Bedding", "Pillows", "Linen"]
        case .bathroom: return ["Towels", "Bath Accessories"]
        case .outdoor: return ["Outdoor Dining", "Grilling"]
        case .entryway: return ["Organization", "Decor"]
        case .office: return ["Desk Accessories", "Lighting"]
        case .nursery: return ["Bedding", "Storage"]
        case .multiRoom, .unknown: return ["General Essentials"]
        }
    }
}
