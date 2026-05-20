import Foundation
import Combine
import GoogleGenerativeAI

@MainActor
final class RegistryAIInsightsService: ObservableObject {

    static let shared = RegistryAIInsightsService()

    enum Source {
        case gemini
        case localFallback
        case mockMode
    }

    @Published private var cache: [UUID: CachedInsights] = [:]

    private struct CachedInsights {
        let fingerprint: String
        let report: RegistryInsightsReport
        let source: Source
    }

    private init() {}

    func cachedReport(for registry: Registry) -> RegistryInsightsReport? {
        let fingerprint = fingerprint(for: registry)
        guard let cached = cache[registry.id], cached.fingerprint == fingerprint else {
            return nil
        }
        return cached.report
    }

    func source(for registry: Registry) -> Source? {
        let fingerprint = fingerprint(for: registry)
        guard let cached = cache[registry.id], cached.fingerprint == fingerprint else {
            return nil
        }
        return cached.source
    }

    func report(for registry: Registry) -> RegistryInsightsReport {
        cachedReport(for: registry) ?? RegistryAIInsightsEngine.analyze(registry: registry)
    }

    @discardableResult
    func refreshInsights(for registry: Registry, force: Bool = false) async -> RegistryInsightsReport {
        let fingerprint = fingerprint(for: registry)

        if !force,
           let cached = cache[registry.id],
           cached.fingerprint == fingerprint,
           cached.source == .gemini {
            return cached.report
        }

        let fallback = RegistryAIInsightsEngine.analyze(registry: registry)

        guard !AURAConfiguration.useMockMode,
              !AURAConfiguration.geminiAPIKey.isEmpty,
              AURAConfiguration.geminiAPIKey != "YOUR_GEMINI_API_KEY_HERE" else {
            cache[registry.id] = CachedInsights(fingerprint: fingerprint, report: fallback, source: .mockMode)
            return fallback
        }

        do {
            let geminiReport = try await fetchGeminiReport(for: registry, fallback: fallback)
            cache[registry.id] = CachedInsights(fingerprint: fingerprint, report: geminiReport, source: .gemini)
            return geminiReport
        } catch {
            print("[RegistryAIInsightsService] Gemini insights failed: \(error.localizedDescription). Using fallback.")
            cache[registry.id] = CachedInsights(fingerprint: fingerprint, report: fallback, source: .localFallback)
            return fallback
        }
    }

    private func fetchGeminiReport(for registry: Registry, fallback: RegistryInsightsReport) async throws -> RegistryInsightsReport {
        let model = GenerativeModel(
            name: AURAConfiguration.geminiModelName,
            apiKey: AURAConfiguration.geminiAPIKey
        )

        let prompt = buildPrompt(for: registry, fallback: fallback)
        let response = try await model.generateContent(prompt)

        guard let text = response.text else {
            throw RegistryInsightsError.emptyResponse
        }

        let payload = try parsePayload(from: text)
        return mapPayload(payload, registry: registry, fallback: fallback)
    }

    private func buildPrompt(for registry: Registry, fallback: RegistryInsightsReport) -> String {
        let totalItems = registry.items.reduce(0) { $0 + $1.quantity }
        let groupedByCollection = Dictionary(grouping: registry.items) { ($0.collectionName ?? "Uncategorized").trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { key, items in
                "\(key): \(items.count)"
            }
            .sorted()
            .joined(separator: ", ")

        let itemsSnapshot = registry.items.prefix(40).map { item in
            [
                "id": item.id,
                "name": item.name,
                "price": item.price,
                "quantity": item.quantity,
                "collection": item.collectionName ?? "Uncategorized",
                "pattern": item.pattern ?? "unknown",
                "purchased": item.isPurchased
            ] as [String: Any]
        }

        let itemsJSON: String
        if let data = try? JSONSerialization.data(withJSONObject: itemsSnapshot, options: [.sortedKeys]),
           let json = String(data: data, encoding: .utf8) {
            itemsJSON = json
        } else {
            itemsJSON = "[]"
        }

        return """
        You are AURA Registry Intelligence for Williams-Sonoma.

        Analyze this registry and produce personalized insights. The response must be specific to the provided data and must not repeat generic text.

        Registry owner: \(registry.firstName) \(registry.lastName)
        Event: \(registry.event.rawValue)
        Total item quantity: \(totalItems)
        Existing collection distribution: \(groupedByCollection)

        Catalog snapshot (JSON):
        \(itemsJSON)

        Existing fallback score for calibration: \(Int((fallback.overallScore * 100).rounded()))

        Output STRICT JSON only (no markdown):
        {
          "overallScore": 0,
          "headline": "",
          "tagline": "",
          "topStrengths": ["", ""],
          "topSuggestions": ["", "", ""],
          "insights": [
            {
              "category": "budget|aesthetic|completeness|giftability|diversity",
              "score": 0,
              "headline": "",
              "detail": "",
              "suggestions": ["", ""]
            }
          ]
        }

        Rules:
        - Score fields must be integers from 0 to 100.
        - Include exactly 5 insight objects, one for each category.
        - Keep detail and suggestions concrete and registry-specific.
        - If data is sparse, state that honestly and provide best actionable advice.
        """
    }

    private func parsePayload(from text: String) throws -> GeminiRegistryInsightsPayload {
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            throw RegistryInsightsError.invalidJSON
        }

        do {
            return try JSONDecoder().decode(GeminiRegistryInsightsPayload.self, from: data)
        } catch {
            throw RegistryInsightsError.invalidJSON
        }
    }

    private func mapPayload(
        _ payload: GeminiRegistryInsightsPayload,
        registry: Registry,
        fallback: RegistryInsightsReport
    ) -> RegistryInsightsReport {
        let categoryOrder: [InsightCategory] = [.budget, .aesthetic, .completeness, .giftability, .diversity]
        let payloadByCategory = Dictionary(uniqueKeysWithValues: payload.insights.compactMap { insight -> (InsightCategory, GeminiRegistryInsightPayload)? in
            guard let category = InsightCategory(geminiKey: insight.category) else { return nil }
            return (category, insight)
        })

        let mappedInsights: [RegistryInsight] = categoryOrder.compactMap { category in
            guard let raw = payloadByCategory[category] else { return nil }
            let score = normalizedScore(raw.score)
            return RegistryInsight(
                category: category,
                score: score,
                tier: RegistryAIInsightsEngine.tier(for: score),
                headline: raw.headline.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty(or: fallbackHeadline(for: category)),
                detail: raw.detail.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty(or: fallbackDetail(for: category, from: fallback)),
                suggestions: raw.suggestions.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            )
        }

        let dimensionInsights = mappedInsights.isEmpty
            ? Array(fallback.insights.dropFirst())
            : mappedInsights

        let computedOverall = dimensionInsights.map(\.score).reduce(0, +) / Double(max(1, dimensionInsights.count))
        let scoreFromPayload = normalizedScore(payload.overallScore)
        let overallScore = abs(scoreFromPayload - computedOverall) <= 0.15 ? scoreFromPayload : computedOverall
        let overallTier = RegistryAIInsightsEngine.tier(for: overallScore)

        let overallInsight = RegistryInsight(
            category: .overallScore,
            score: overallScore,
            tier: overallTier,
            headline: payload.headline.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty(or: fallback.headline),
            detail: "\(registry.firstName) & \(registry.lastName)'s \(registry.event.rawValue.lowercased()) registry has \(registry.items.reduce(0) { $0 + $1.quantity }) items.",
            suggestions: []
        )

        let strengths = payload.topStrengths.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let suggestions = payload.topSuggestions.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }

        return RegistryInsightsReport(
            generatedAt: Date(),
            overallScore: overallScore,
            overallTier: overallTier,
            headline: overallInsight.headline,
            tagline: payload.tagline.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty(or: fallback.tagline),
            insights: [overallInsight] + dimensionInsights,
            budgetBreakdown: fallback.budgetBreakdown,
            topStrengths: strengths.isEmpty ? fallback.topStrengths : Array(strengths.prefix(5)),
            topSuggestions: suggestions.isEmpty ? fallback.topSuggestions : Array(suggestions.prefix(6)),
            collectionCoveragePercent: fallback.collectionCoveragePercent,
            priceRangeText: fallback.priceRangeText,
            averagePriceText: fallback.averagePriceText,
            totalValueText: fallback.totalValueText
        )
    }

    private func fallbackHeadline(for category: InsightCategory) -> String {
        switch category {
        case .budget: return "Budget balance"
        case .aesthetic: return "Aesthetic direction"
        case .completeness: return "Registry completeness"
        case .giftability: return "Giftability"
        case .diversity: return "Category diversity"
        case .overallScore: return "Registry score"
        }
    }

    private func fallbackDetail(for category: InsightCategory, from report: RegistryInsightsReport) -> String {
        report.insights.first(where: { $0.category == category })?.detail ?? "No details available."
    }

    private func normalizedScore(_ value: Int) -> Double {
        min(max(Double(value) / 100.0, 0), 1)
    }

    private func fingerprint(for registry: Registry) -> String {
        let sortedItems = registry.items
            .sorted { lhs, rhs in
                if lhs.id == rhs.id { return lhs.name < rhs.name }
                return lhs.id < rhs.id
            }
            .map { item in
                "\(item.id)|\(item.name)|\(item.quantity)|\(item.price)|\(item.collectionName ?? "")|\(item.pattern ?? "")|\(item.isPurchased)"
            }
            .joined(separator: ";")

        return "\(registry.id.uuidString)|\(registry.firstName)|\(registry.lastName)|\(registry.event.rawValue)|\(sortedItems)"
    }
}

private struct GeminiRegistryInsightsPayload: Decodable {
    let overallScore: Int
    let headline: String
    let tagline: String
    let topStrengths: [String]
    let topSuggestions: [String]
    let insights: [GeminiRegistryInsightPayload]
}

private struct GeminiRegistryInsightPayload: Decodable {
    let category: String
    let score: Int
    let headline: String
    let detail: String
    let suggestions: [String]
}

private enum RegistryInsightsError: Error {
    case emptyResponse
    case invalidJSON
}

private extension InsightCategory {
    init?(geminiKey: String) {
        switch geminiKey.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
        case "budget": self = .budget
        case "aesthetic": self = .aesthetic
        case "completeness": self = .completeness
        case "giftability": self = .giftability
        case "diversity": self = .diversity
        default: return nil
        }
    }
}

private extension String {
    func nonEmpty(or fallback: String) -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}
