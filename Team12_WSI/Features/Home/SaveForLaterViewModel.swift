// SaveForLaterViewModel.swift
// Team12_WSI — Drives SaveForLaterView

import Foundation
import Combine

@MainActor
final class SaveForLaterViewModel: ObservableObject {

    @Published private(set) var items: [CartItem] = []
    private var cancellable: AnyCancellable?
    private var saveForLaterRepo: SaveForLaterRepository?
    private var cartRepo: CartRepository?

    func bind(saveForLaterRepository: SaveForLaterRepository,
              cartRepository: CartRepository) {
        self.saveForLaterRepo = saveForLaterRepository
        self.cartRepo = cartRepository
        self.items = saveForLaterRepository.items

        cancellable = saveForLaterRepository.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updated in self?.items = updated }
    }

    var isEmpty: Bool { items.isEmpty }

    // Move a saved item to cart and remove from list
    func moveToCart(_ item: CartItem) {
        // Reconstruct a minimal ProductItem to pass to CartRepository
        let product = ProductItem(
            id: item.id,
            name: item.name,
            price: item.price,
            path: item.path,
            productType: nil,
            brand: nil
        )
        cartRepo?.add(product: product)
        saveForLaterRepo?.remove(productId: item.id)
    }

    // Remove entirely from list
    func remove(_ item: CartItem) {
        saveForLaterRepo?.remove(productId: item.id)
    }
}
