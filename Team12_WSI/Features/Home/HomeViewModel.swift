//
//  HomeViewModel.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 04/04/26.
//

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

    func bind(cartRepository: CartRepository,
              registryRepository: RegistryRepository) {
        self.cartRepository = cartRepository
        self.registryRepository = registryRepository
    }
    
    // Cart
    func addToCart(_ product: ProductItem) {
        cartRepository?.add(product: product, quantityDelta: 1)
    }
    
    func removeFromCart(_ product: ProductItem) {
        cartRepository?.removeOne(productId: product.id)
    }
    
    // Registry
    func addToRegistry(_ product: ProductItem) {
        registryRepository?.addProduct(product)
    }
    
    func canAddToRegistry(_ product: ProductItem) -> Bool {
        if let registryRepository, registryRepository.isActiveRegistry {
            return true
        }
        return false
    }
    
    func removeFromRegistry(_ product: ProductItem) {
        registryRepository?.removeItem(product.id)
    }
    
    func quantity(for product: ProductItem) -> Int {
        cartRepository?.items.first(where: { $0.id == product.id })?.quantity ?? 0
    }
    
    func registryQuantity(for product: ProductItem) -> Int {
        registryRepository?.currentRegistry?.items.first(where: { $0.id == product.id })?.quantity ?? 0
    }
    
    var filteredProducts: [ProductItem] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func fetchProducts() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: ProductResponseDTO = try await APIClient.shared.request(Endpoint.products())
            self.products = response.products.map { ProductItem(from: $0) }
        } catch {
            print(error)
            errorMessage = "Failed to load products"
            hasLoaded = false
        }

        
        isLoading = false
    }
}
