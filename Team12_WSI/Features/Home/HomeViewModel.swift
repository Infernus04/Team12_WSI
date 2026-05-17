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

    // MARK: - Binding

    func bind(cartRepository: CartRepository,
              registryRepository: RegistryRepository) {
        self.cartRepository = cartRepository
        self.registryRepository = registryRepository
    }

    // MARK: - Cart

    func addToCart(_ product: ProductItem) {
        cartRepository?.add(product: product)
    }

    func removeFromCart(_ product: ProductItem) {
        cartRepository?.remove(productId: product.id)
    }

    func cartQuantity(for product: ProductItem) -> Int {
        cartRepository?.items.first(where: { $0.id == product.id })?.quantity ?? 0
    }

    // MARK: - Bundle To Cart

    func addBundleToCart(_ bundle: AestheticBundle) {
        let bundleProducts = bundleProducts(for: bundle)
        bundleProducts.forEach { addToCart($0) }
    }

    func bundleProducts(for bundle: AestheticBundle) -> [ProductItem] {
        bundle.productOffsets.compactMap { offset in
            guard offset < products.count else { return nil }
            return products[offset]
        }
    }

    // MARK: - Registry

    func addToRegistry(_ product: ProductItem) {
        registryRepository?.addProduct(product)
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
            await MainActor.run {
                self.errorMessage = "Failed to load products"
                self.isLoading = false
                self.hasLoaded = false
            }
        }
    }
}
