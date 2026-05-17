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
    
    @Published var registries: [Registry] = []
    @Published var activeRegistryID: UUID?
    @Published var currentRegistry: Registry?
    @Published var activities: [RegistryActivity] = MockRegistryActivities.generate()

    private let persistenceStore = RegistryPersistenceStore.shared
    private var hasBoundPersistence = false
    
    // MARK: - Persistence Bootstrap
    
    /// Call once on app launch or first access to load persisted state.
    func loadPersistedState() {
        guard !hasBoundPersistence else { return }
        hasBoundPersistence = true
        
        Task {
            let envelope = await persistenceStore.load()
            if let persistedRegistries = envelope.registries, !persistedRegistries.isEmpty {
                registries = persistedRegistries
                activeRegistryID = envelope.activeRegistryID ?? persistedRegistries.last?.id
                syncCurrentRegistry()
                return
            }

            // Backward compatibility for older persistence schema.
            if let persisted = envelope.registry {
                registries = [persisted]
                activeRegistryID = persisted.id
                syncCurrentRegistry()
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
                        date: Date,
                        budget: Double? = nil) {
        let created = Registry(
            id: UUID(),
            firstName: firstName,
            lastName: lastName,
            event: event,
            date: date,
            items: [],
            budget: budget
        )
        registries.append(created)
        activeRegistryID = created.id
        syncCurrentRegistry()
        persistRegistryState()
    }
    
    // MARK: - Delete Registry
    
    func deleteRegistry() {
        guard let activeRegistryID else { return }
        registries.removeAll { $0.id == activeRegistryID }
        self.activeRegistryID = registries.last?.id
        syncCurrentRegistry()
        persistRegistryState()
    }

    func selectRegistry(id: UUID) {
        guard registries.contains(where: { $0.id == id }) else { return }
        activeRegistryID = id
        syncCurrentRegistry()
        persistRegistryState()
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
        mutateActiveRegistry { registry in
            let price = product.price ?? 0.0
            let resolved = RegistryRepository.resolvePattern(name: product.name, originalPattern: product.pattern)

            if let index = registry.items.firstIndex(where: { $0.id == product.id }) {
                registry.items[index].quantity += 1
                if registry.items[index].collectionName == nil {
                    registry.items[index].collectionName = collectionName
                }
                if registry.items[index].sourceTag == nil {
                    registry.items[index].sourceTag = sourceTag
                }
                if registry.items[index].pattern == nil || registry.items[index].pattern == "Uncategorized" {
                    registry.items[index].pattern = resolved
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
                        sourceTag: sourceTag,
                        pattern: resolved
                    )
                )
            }
        }
        let detail = collectionName != nil ? "Added to \(collectionName!) collection" : "Added to registry"
        activities.insert(RegistryActivity(type: .added, productName: product.name, collectionName: collectionName, detail: detail), at: 0)
    }

    func addProducts(
        _ products: [ProductItem],
        collectionName: String? = nil,
        sourceTag: String? = nil
    ) {
        guard !products.isEmpty else { return }
        mutateActiveRegistry { registry in
            for product in products {
                let price = product.price ?? 0.0
                let resolved = RegistryRepository.resolvePattern(name: product.name, originalPattern: product.pattern)
                if let index = registry.items.firstIndex(where: { $0.id == product.id }) {
                    registry.items[index].quantity += 1
                    if registry.items[index].collectionName == nil {
                        registry.items[index].collectionName = collectionName
                    }
                    if registry.items[index].sourceTag == nil {
                        registry.items[index].sourceTag = sourceTag
                    }
                    if registry.items[index].pattern == nil || registry.items[index].pattern == "Uncategorized" {
                        registry.items[index].pattern = resolved
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
                            sourceTag: sourceTag,
                            pattern: resolved
                        )
                    )
                }
            }
        }
        let bundleName = collectionName ?? "Bundle"
        activities.insert(RegistryActivity(type: .bundleAdded, productName: bundleName, collectionName: collectionName, detail: "\(products.count) items added from \(bundleName)"), at: 0)
    }
    
    // MARK: - Remove Item
    
    func removeItem(_ productId: String) {
        let itemName = registries
            .flatMap(\.items)
            .first(where: { $0.id == productId })?.name ?? "Item"
        mutateActiveRegistry { registry in
            registry.items.removeAll { $0.id == productId }
        }
        activities.insert(RegistryActivity(type: .removed, productName: itemName, detail: "Removed from registry"), at: 0)
    }
    
    // MARK: - Update Quantity
    
    func increaseQty(_ productId: String) {
        mutateActiveRegistry { registry in
            if let index = registry.items.firstIndex(where: { $0.id == productId }) {
                registry.items[index].quantity += 1
            }
        }
    }
    
    func decreaseQty(_ productId: String) {
        mutateActiveRegistry { registry in
            guard let index = registry.items.firstIndex(where: { $0.id == productId }) else { return }

            if registry.items[index].quantity > 1 {
                registry.items[index].quantity -= 1
            } else {
                registry.items.remove(at: index)
            }
        }
    }
    
    func quantity(for registryItem: RegistryItem) -> Int {
        currentRegistry?.items.first(where: { $0.id == registryItem.id })?.quantity ?? 0
    }

    func moveToCollection(productId: String, collectionName: String) {
        let itemName = registries
            .flatMap(\.items)
            .first(where: { $0.id == productId })?.name ?? "Item"
        mutateActiveRegistry { registry in
            guard let index = registry.items.firstIndex(where: { $0.id == productId }) else { return }
            registry.items[index].collectionName = collectionName
        }
        activities.insert(RegistryActivity(type: .movedCollection, productName: itemName, collectionName: collectionName, detail: "Moved to \(collectionName) collection"), at: 0)
    }
    
    // MARK: - Persistence (private)

    private func syncCurrentRegistry() {
        currentRegistry = registries.first(where: { $0.id == activeRegistryID }) ?? registries.last
    }

    private func mutateActiveRegistry(_ mutation: (inout Registry) -> Void) {
        guard let activeRegistryID else { return }
        guard let index = registries.firstIndex(where: { $0.id == activeRegistryID }) else { return }
        mutation(&registries[index])
        syncCurrentRegistry()
        persistRegistryState()
    }

    private func persistRegistryState() {
        Task {
            await persistenceStore.saveRegistries(registries, activeRegistryID: activeRegistryID)
        }
    }

    static func resolvePattern(name: String, originalPattern: String?) -> String {
        if let originalPattern = originalPattern, !originalPattern.isEmpty {
            return originalPattern
        }
        let lower = name.lowercased()
        
        if lower.contains("oil") || lower.contains("clean") || lower.contains("wash") || lower.contains("soap") || lower.contains("lidded ceramic bowl") || lower.contains("organizer") || lower.contains("pantry") || lower.contains("basket") {
            return "homekeeping"
        }
        if lower.contains("cutting board") || lower.contains("knife") || lower.contains("knives") || lower.contains("block") || lower.contains("cleaver") || lower.contains("shears") {
            return "cutlery"
        }
        if lower.contains("oven") || lower.contains("dutch") || lower.contains("pan") || lower.contains("skillet") || lower.contains("pot") || lower.contains("cookware") || lower.contains("saucepan") || lower.contains("griddle") {
            return "cookware"
        }
        if lower.contains("plate") || lower.contains("dinner plate") || lower.contains("salad plate") || lower.contains("bowl") || lower.contains("dinnerware") || lower.contains("saucer") || lower.contains("mug") || lower.contains("cup") {
            return "dinnerware"
        }
        if lower.contains("platter") || lower.contains("carafe") || lower.contains("glass") || lower.contains("tumbler") || lower.contains("serve") || lower.contains("decanter") || lower.contains("pitcher") || lower.contains("wine") || lower.contains("bar") {
            return "serveware"
        }
        if lower.contains("blender") || lower.contains("vitamix") || lower.contains("espresso") || lower.contains("coffee") || lower.contains("toaster") || lower.contains("mixer") || lower.contains("waffle") || lower.contains("kettle") || lower.contains("juicer") || lower.contains("processor") {
            return "appliances"
        }
        if lower.contains("sheet") || lower.contains("bed") || lower.contains("pillow") || lower.contains("linen") || lower.contains("towel") || lower.contains("apron") || lower.contains("runner") || lower.contains("napkin") || lower.contains("cloth") {
            return "textiles"
        }
        
        return "tabletop"
    }
}
