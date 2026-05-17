import Foundation
import SwiftUI
import Combine

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
    @Published var collectionBundles: [RegistryCollectionBundle] = []
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
        self.collectionBundles = makeCollectionBundles(from: response)
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
        let candidates = recommendations.prefix(20).map { productItem(from: $0.product) }
        registryRepo?.addProducts(candidates, collectionName: "AI Personalized Set", sourceTag: "ai-personalized-set")
        addedProductIDs.formUnion(candidates.map(\.id))
    }

    func addTopEssentials() {
        let candidates = essentials.prefix(100).map { productItem(from: $0) }
        registryRepo?.addProducts(candidates, collectionName: "Top Registry Essentials", sourceTag: "top-essentials")
        addedProductIDs.formUnion(candidates.map(\.id))
    }

    func addCollection(_ bundle: RegistryCollectionBundle) {
        let candidates = bundle.productIDs.compactMap { catalogByID[$0] }.map { productItem(from: $0) }
        registryRepo?.addProducts(candidates, collectionName: bundle.title, sourceTag: "collection-\(bundle.id)")
        addedProductIDs.formUnion(candidates.map(\.id))
        addedCollectionIDs.insert(bundle.id)
    }

    func isCollectionAdded(_ bundle: RegistryCollectionBundle) -> Bool {
        addedCollectionIDs.contains(bundle.id)
    }

    private func productItem(from catalog: CatalogProduct) -> ProductItem {
        ProductItem(
            id: catalog.id,
            name: catalog.name,
            price: catalog.effectivePrice,
            path: catalog.imagePath
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

    private func makeCollectionBundles(from response: RegistryRecommendationResponse) -> [RegistryCollectionBundle] {
        response.categorySections.map { section in
            RegistryCollectionBundle(
                id: section.id,
                title: section.category,
                subtitle: section.title,
                productIDs: Array(section.productIDs.prefix(8))
            )
        }
    }
}
