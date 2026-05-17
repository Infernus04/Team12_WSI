import Foundation
import SwiftUI
import Combine

struct HomeInspiredBundle: Identifiable, Hashable {
    let id: String
    let title: String
    let compatibilityScore: Int
    let description: String
    let aiReason: String
    let productIDs: [String]
}

// MARK: - AURA Recommendation Review ViewModel

@MainActor
final class AURARecommendationReviewViewModel: ObservableObject {

    // MARK: - Published State

    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var contextSummary = ""
    @Published var sections: [RegistryRecommendationSection] = []
    @Published var recommendations: [RankedRecommendation] = []
    @Published var addedProductIDs: Set<String> = []
    @Published var essentials: [CatalogProduct] = []
    @Published var homeBundles: [HomeInspiredBundle] = []
    @Published var addedCollectionIDs: Set<String> = []

    // MARK: - Dependencies

    private let intelligenceService = AURAIntelligenceService()
    private let payload: RegistryQuestionnairePayload
    private weak var registryRepo: RegistryRepository?
    private var catalogByID: [String: CatalogProduct] = [:]

    // MARK: - Init

    init(payload: RegistryQuestionnairePayload, registryRepo: RegistryRepository?) {
        self.payload = payload
        self.registryRepo = registryRepo
    }

    // MARK: - Load Recommendations

    func loadRecommendations() async {
        isLoading = true
        errorMessage = nil
        addedProductIDs = Set(registryRepo?.currentRegistry?.items.map(\.id) ?? [])

        // Fetch product catalog
        let catalog = await intelligenceService.fetchCatalogProducts()
        self.catalogByID = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0) })

        guard !catalog.isEmpty else {
            errorMessage = "Unable to load products. Please try again."
            isLoading = false
            return
        }

        // Generate recommendations
        let response = await intelligenceService.generateRecommendations(
            payload: payload,
            catalog: catalog
        )

        self.contextSummary = response.contextSummary
        self.recommendations = response.recommendations
        self.sections = response.categorySections
        self.essentials = curateEssentials(from: catalog)
        self.homeBundles = makeHomeBundles(from: catalog, recommendations: response.recommendations)
        self.isLoading = false
    }

    // MARK: - Regenerate

    func regenerate() async {
        await loadRecommendations()
    }

    // MARK: - Add to Registry

    func addToRegistry(_ recommendation: RankedRecommendation) {
        guard !addedProductIDs.contains(recommendation.id) else { return }

        let product = productItem(from: recommendation.product)
        registryRepo?.addProduct(product, collectionName: recommendationCollection(for: recommendation), sourceTag: "ai-recommendation")
        addedProductIDs.insert(recommendation.id)
    }

    func isAdded(_ recommendation: RankedRecommendation) -> Bool {
        addedProductIDs.contains(recommendation.id)
    }

    // MARK: - Section Recommendations

    func recommendations(for section: RegistryRecommendationSection) -> [RankedRecommendation] {
        let idSet = Set(section.productIDs)
        return recommendations.filter { idSet.contains($0.id) }
    }

    func addPersonalizedSet() {
        let candidates = recommendations
            .prefix(20)
            .filter { !addedProductIDs.contains($0.id) }
            .map { productItem(from: $0.product) }
        guard !candidates.isEmpty else { return }
        registryRepo?.addProducts(candidates, collectionName: "AI Personalized Set", sourceTag: "ai-personalized-set")
        addedProductIDs.formUnion(candidates.map(\.id))
    }

    func addTopEssentials() {
        let candidates = essentials
            .prefix(100)
            .filter { !addedProductIDs.contains($0.id) }
            .map { productItem(from: $0) }
        guard !candidates.isEmpty else { return }
        registryRepo?.addProducts(candidates, collectionName: "Top Registry Essentials", sourceTag: "top-essentials")
        addedProductIDs.formUnion(candidates.map(\.id))
    }

    func addCollection(_ bundle: HomeInspiredBundle) {
        let candidates = bundle.productIDs
            .filter { !addedProductIDs.contains($0) }
            .compactMap { catalogByID[$0] }
            .map { productItem(from: $0) }
        guard !candidates.isEmpty else {
            addedCollectionIDs.insert(bundle.id)
            return
        }
        registryRepo?.addProducts(candidates, collectionName: bundle.title, sourceTag: "collection-\(bundle.id)")
        addedProductIDs.formUnion(candidates.map(\.id))
        addedCollectionIDs.insert(bundle.id)
    }

    func isCollectionAdded(_ bundle: HomeInspiredBundle) -> Bool {
        addedCollectionIDs.contains(bundle.id)
    }

    func canAddPersonalizedSet() -> Bool {
        recommendations.prefix(20).contains { !addedProductIDs.contains($0.id) }
    }

    func canAddTopEssentials() -> Bool {
        essentials.prefix(100).contains { !addedProductIDs.contains($0.id) }
    }

    func removeFromRegistry(_ recommendation: RankedRecommendation) {
        guard addedProductIDs.contains(recommendation.id) else { return }
        registryRepo?.removeItem(recommendation.id)
        addedProductIDs.remove(recommendation.id)
    }

    func products(for bundle: HomeInspiredBundle) -> [CatalogProduct] {
        bundle.productIDs.compactMap { catalogByID[$0] }
    }

    private func productItem(from catalog: CatalogProduct) -> ProductItem {
        ProductItem(
            id: catalog.id,
            name: catalog.name,
            price: catalog.effectivePrice,
            path: catalog.imagePath,
            productType: catalog.productType,
            brand: catalog.brand.rawValue
        )
    }

    private func recommendationCollection(for recommendation: RankedRecommendation) -> String {
        sections.first(where: { $0.productIDs.contains(recommendation.id) })?.category ?? "AI Picks"
    }

    private func curateEssentials(from catalog: [CatalogProduct]) -> [CatalogProduct] {
        let preferredCategories = ["cookware", "tabletop", "glassware", "electrics", "homekeeping", "cutlery", "dining", "coffee"]
        let filtered = catalog.filter { product in
            guard product.availability?.uppercased() != "NLA" else { return false }
            let corpus = (product.categoryTags + [product.productType]).joined(separator: " ").lowercased()
            return preferredCategories.contains { corpus.contains($0) } && !product.isFood
        }
        return filtered.sorted { left, right in
            if left.fundabilityScore == right.fundabilityScore {
                return left.effectivePrice > right.effectivePrice
            }
            return left.fundabilityScore > right.fundabilityScore
        }
    }

    private func makeHomeBundles(
        from catalog: [CatalogProduct],
        recommendations: [RankedRecommendation]
    ) -> [HomeInspiredBundle] {
        let topRecommendationIDs: Set<String> = Set(recommendations.prefix(24).map { $0.id })
        let bundles: [HomeInspiredBundle] = HomeEditorialData.bundles.enumerated().compactMap { index, bundle in
            let productIDs: [String] = bundle.productOffsets.compactMap { (offset: Int) -> String? in
                guard catalog.indices.contains(offset) else { return nil }
                return catalog[offset].id
            }
            guard !productIDs.isEmpty else { return nil }

            let overlap = productIDs.filter { topRecommendationIDs.contains($0) }.count
            let adjustedScore = min(99, bundle.compatibilityScore + overlap * 2)

            return HomeInspiredBundle(
                id: "home-bundle-\(index)",
                title: bundle.title,
                compatibilityScore: adjustedScore,
                description: bundle.description,
                aiReason: bundle.aiReason,
                productIDs: productIDs
            )
        }

        return bundles.sorted { $0.compatibilityScore > $1.compatibilityScore }
    }
}
