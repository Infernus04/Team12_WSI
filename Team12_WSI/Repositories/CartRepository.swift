//
//  CartRepository.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation
import Combine

@MainActor
final class CartRepository: ObservableObject {
    
    @Published private(set) var items: [CartItem] = []
    
    func add(product: ProductItem, quantityDelta: Int = 1) {
        guard let priceValue = product.price, quantityDelta > 0 else { return }
        
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            items[index].quantity += quantityDelta
        } else {
            let newItem = CartItem(
                id: product.id,
                name: product.name,
                price: priceValue,
                path: product.path ?? "",
                quantity: quantityDelta
            )

            items.append(newItem)
        }
    }
    
    func removeOne(productId: String) {
        guard let index = items.firstIndex(where: { $0.id == productId }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
    }
    
    func removeAll(productId: String) {
        items.removeAll { $0.id == productId }
    }
    
    func replaceItem(oldId: String, newItem: ProductItem) {
        let existingQuantity = items.first(where: { $0.id == oldId })?.quantity ?? 1
        removeAll(productId: oldId)
        add(product: newItem, quantityDelta: existingQuantity)
    }
    
    func clear() {
        items.removeAll()
    }
    
    var totalPrice: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    func increaseQuantity(productId: String) {
        guard let index = items.firstIndex(where: { $0.id == productId }) else { return }
        items[index].quantity += 1
    }
}
