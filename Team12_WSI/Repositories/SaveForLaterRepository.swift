// SaveForLaterRepository.swift
// Team12_WSI — In-memory Save for Later list, mirrors CartRepository pattern

import Foundation
import Combine

@MainActor
final class SaveForLaterRepository: ObservableObject {

    @Published private(set) var items: [CartItem] = []

    // MARK: - Add
    func add(product: ProductItem) {
        guard let price = product.price else { return }
        if items.contains(where: { $0.id == product.id }) { return } // no duplicates
        items.append(CartItem(
            id: product.id,
            name: product.name,
            price: price,
            path: product.path ?? "",
            quantity: 1
        ))
    }

    // MARK: - Remove
    func remove(productId: String) {
        items.removeAll { $0.id == productId }
    }

    // MARK: - Count
    var totalItems: Int { items.count }

    // MARK: - Contains
    func contains(productId: String) -> Bool {
        items.contains { $0.id == productId }
    }
}
