// HomeViewModel.swift
// Team12_WSI — Extended with search, bundle, and product navigation state

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var products: [ProductItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var hasLoaded = false
    private var cartRepository: CartRepository?
    private var registryRepository: RegistryRepository?
    private var saveForLaterRepository: SaveForLaterRepository?

    // MARK: - Binding

    func bind(cartRepository: CartRepository,
              registryRepository: RegistryRepository,
              saveForLaterRepository: SaveForLaterRepository? = nil) {
        self.cartRepository = cartRepository
        self.registryRepository = registryRepository
        self.saveForLaterRepository = saveForLaterRepository
    }

    // MARK: - Cart

    func addToCart(_ product: ProductItem) {
        cartRepository?.add(product: product, quantityDelta: 1)
    }

    func removeFromCart(_ product: ProductItem) {
        cartRepository?.removeOne(productId: product.id)
    }

    func cartQuantity(for product: ProductItem) -> Int {
        cartRepository?.items.first(where: { $0.id == product.id })?.quantity ?? 0
    }

    // MARK: - Bundle To Cart

    func addBundleToCart(_ bundle: AestheticBundle) {
        let bundleProducts = bundleProducts(for: bundle)
        bundleProducts.forEach { addToCart($0) }
    }

    // MARK: - Save For Later

    func addToSaveForLater(_ product: ProductItem) {
        saveForLaterRepository?.add(product: product)
    }

    func removeFromSaveForLater(_ product: ProductItem) {
        saveForLaterRepository?.remove(productId: product.id)
    }

    func isInSaveForLater(_ product: ProductItem) -> Bool {
        saveForLaterRepository?.contains(productId: product.id) ?? false
    }

    func bundleProducts(for bundle: AestheticBundle) -> [ProductItem] {
        bundle.productOffsets.compactMap { offset in
            guard offset < products.count else { return nil }
            return products[offset]
        }
    }

    // MARK: - Registry

    func addToRegistry(_ product: ProductItem) {
        // Opens the registry picker bottom sheet so the user can choose which registry to add to
        registryRepository?.presentRegistryPicker(for: product)
    }

    func canAddToRegistry(_ product: ProductItem) -> Bool {
        registryRepository?.isActiveRegistry ?? false
    }

    func removeFromRegistry(_ product: ProductItem) {
        registryRepository?.removeItem(product.id)
    }

    func registryQuantity(for product: ProductItem) -> Int {
        registryRepository?.currentRegistry?.items.first(where: { $0.id == product.id })?.quantity ?? 0
    }

    // MARK: - Search

    var filteredProducts: [ProductItem] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return products
        }
        let q = searchText.lowercased()
        return products.filter {
            $0.name.lowercased().contains(q) ||
            ($0.productType?.lowercased().contains(q) ?? false) ||
            ($0.brand?.lowercased().contains(q) ?? false)
        }
    }

    // MARK: - Seasonal Products

    func seasonalProducts() -> [ProductItem] {
        let keywords = SeasonalContextEngine.seasonalKeywords()
        let scored = HomeAIPersonalizationEngine.scoreProducts(products, keywords: keywords, colorTokens: [])
        return scored
    }

    // MARK: - Safe Product At Index

    func product(at index: Int) -> ProductItem? {
        guard index < products.count else { return nil }
        return products[index]
    }

    // MARK: - Fetch

    func fetchProducts() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        isLoading = true
        errorMessage = nil

        do {
            let response: ProductResponseDTO = try await APIClient.shared.request(Endpoint.products())
            await MainActor.run {
                self.products = response.products.map { ProductItem(from: $0) }
                self.isLoading = false
            }
        } catch {
            #if targetEnvironment(simulator)
            if let data = try? Data(contentsOf: URL(fileURLWithPath: "/Users/gayatri/Desktop/Team12_WSI/Backend/responses/skus.json")) {
                if let dtos = try? JSONDecoder().decode([ProductItemDTO].self, from: data) {
                    await MainActor.run {
                        self.products = dtos.map { ProductItem(from: $0) }
                        self.isLoading = false
                    }
                    return
                }
            }
            #endif
            
            await MainActor.run {
                self.products = ProductItem.fallbackProducts
                self.isLoading = false
            }
        }
    }
}
