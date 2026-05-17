//
//  RegistryRepository.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Combine
import Foundation

@MainActor
final class RegistryRepository: ObservableObject {
    
    @Published var currentRegistry: Registry?

    private let persistenceStore = RegistryPersistenceStore.shared
    private var hasBoundPersistence = false
    
    // MARK: - Persistence Bootstrap
    
    /// Call once on app launch or first access to load persisted state.
    func loadPersistedState() {
        guard !hasBoundPersistence else { return }
        hasBoundPersistence = true
        
        Task {
            let envelope = await persistenceStore.load()
            if let persisted = envelope.registry {
                self.currentRegistry = persisted
            }
        }
    }
    
    // MARK: - Create
    var isActiveRegistry: Bool {
        currentRegistry != nil
    }
    
    func createRegistry(firstName: String,
                        lastName: String,
                        event: RegistryEvent,
                        date: Date) {
        
        currentRegistry = Registry(
            id: UUID(),
            firstName: firstName,
            lastName: lastName,
            event: event,
            date: date,
            items: []
        )
        persistCurrentRegistry()
    }
    
    // MARK: - Delete Registry
    
    func deleteRegistry() {
        currentRegistry = nil
        persistCurrentRegistry()
    }
    
    // MARK: - Add Product
    
    func addProduct(_ product: ProductItem) {
        addProduct(product, collectionName: nil, sourceTag: nil)
    }

    func addProduct(
        _ product: ProductItem,
        collectionName: String?,
        sourceTag: String?
    ) {
        guard var registry = currentRegistry else { return }
        
        let price = product.price ?? 0.0
        
        if let index = registry.items.firstIndex(where: { $0.id == product.id }) {
            registry.items[index].quantity += 1
            if registry.items[index].collectionName == nil {
                registry.items[index].collectionName = collectionName
            }
            if registry.items[index].sourceTag == nil {
                registry.items[index].sourceTag = sourceTag
            }
        } else {
            registry.items.append(
                RegistryItem(
                    id: product.id,
                    name: product.name,
                    price: price,
                    imageUrl: product.path ?? "",
                    quantity: 1,
                    collectionName: collectionName,
                    sourceTag: sourceTag
                )
            )

        }
        
        currentRegistry = registry
        persistCurrentRegistry()
    }

    func addProducts(
        _ products: [ProductItem],
        collectionName: String? = nil,
        sourceTag: String? = nil
    ) {
        guard !products.isEmpty else { return }
        guard var registry = currentRegistry else { return }

        for product in products {
            let price = product.price ?? 0.0
            if let index = registry.items.firstIndex(where: { $0.id == product.id }) {
                registry.items[index].quantity += 1
                if registry.items[index].collectionName == nil {
                    registry.items[index].collectionName = collectionName
                }
                if registry.items[index].sourceTag == nil {
                    registry.items[index].sourceTag = sourceTag
                }
            } else {
                registry.items.append(
                    RegistryItem(
                        id: product.id,
                        name: product.name,
                        price: price,
                        imageUrl: product.path ?? "",
                        quantity: 1,
                        collectionName: collectionName,
                        sourceTag: sourceTag
                    )
                )
            }
        }
        currentRegistry = registry
        persistCurrentRegistry()
    }
    
    // MARK: - Remove Item
    
    func removeItem(_ productId: String) {
        guard var registry = currentRegistry else { return }
        
        registry.items.removeAll { $0.id == productId }
        currentRegistry = registry
        persistCurrentRegistry()
    }
    
    // MARK: - Update Quantity
    
    func increaseQty(_ productId: String) {
        guard var registry = currentRegistry else { return }
        
        if let index = registry.items.firstIndex(where: { $0.id == productId }) {
            registry.items[index].quantity += 1
            currentRegistry = registry
            persistCurrentRegistry()
        }
    }
    
    func decreaseQty(_ productId: String) {
        guard var registry = currentRegistry else { return }
        
        guard let index = registry.items.firstIndex(where: { $0.id == productId }) else { return }
        
        if registry.items[index].quantity > 1 {
            registry.items[index].quantity -= 1
        } else {
            registry.items.remove(at: index)
        }
        
        currentRegistry = registry
        persistCurrentRegistry()
    }
    
    func quantity(for registryItem: RegistryItem) -> Int {
        currentRegistry?.items.first(where: { $0.id == registryItem.id })?.quantity ?? 0
    }

    func moveToCollection(productId: String, collectionName: String) {
        guard var registry = currentRegistry else { return }
        guard let index = registry.items.firstIndex(where: { $0.id == productId }) else { return }
        registry.items[index].collectionName = collectionName
        currentRegistry = registry
        persistCurrentRegistry()
    }
    
    // MARK: - Persistence (private)
    
    private func persistCurrentRegistry() {
        Task {
            await persistenceStore.saveRegistry(currentRegistry)
        }
    }
}
