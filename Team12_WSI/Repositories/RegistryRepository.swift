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
    /// In-memory cover image for the currently active registry (set during creation).
    @Published var activeCoverImageData: Data? = nil

    private let persistenceStore = RegistryPersistenceStore.shared
    private var hasBoundPersistence = false
    private let trialDemoSeedTag = "demo-seed"
    
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
                ensureTrialDemoRegistryExists(selectAsActive: false)
                syncCurrentRegistry()
                return
            }

            // Backward compatibility for older persistence schema.
            if let persisted = envelope.registry {
                registries = [persisted]
                activeRegistryID = persisted.id
                ensureTrialDemoRegistryExists(selectAsActive: false)
                syncCurrentRegistry()
                return
            }

            // No persisted data — seed a demo registry for the trial
            ensureTrialDemoRegistryExists(selectAsActive: true)
        }
    }

    // MARK: - Demo Registry Seed / Link

    /// Seeds a pre-made "Sasha & Andy" wedding registry with curated WSI products.
    /// Only called when there is no persisted registry (first launch / fresh install).
    private func buildDemoRegistry() -> Registry {
        let demoID = UUID()
        let demoDate = Calendar.current.date(byAdding: .day, value: 37, to: Date()) ?? Date()

        let seedItems: [RegistryItem] = [
            RegistryItem(
                id: "2505456",
                name: "Williams Sonoma End-Grain Cutting Board, Acacia",
                price: 129.95,
                imageUrl: "/ws_endgrain_board_acacia.jpg",
                quantity: 1,
                collectionName: "Daily Cooking",
                sourceTag: trialDemoSeedTag,
                pattern: "cutlery"
            ),
            RegistryItem(
                id: "2453926",
                name: "Staub Enameled Cast Iron Dutch Oven, 7-Qt., Basil",
                price: 299.95,
                imageUrl: "/staub_dutch_basil.jpg",
                quantity: 1,
                collectionName: "Daily Cooking",
                sourceTag: trialDemoSeedTag,
                pattern: "cookware"
            ),
            RegistryItem(
                id: "181543",
                name: "Staub Cast Iron Deep Skillet, 8½\", Citron",
                price: 180.00,
                imageUrl: "/staub_frypan_citron.jpg",
                quantity: 1,
                collectionName: "Daily Cooking",
                sourceTag: trialDemoSeedTag,
                pattern: "cookware"
            ),
            RegistryItem(
                id: "8381456",
                name: "Cuisinart PerfecTemp Coffee Maker, 14-Cup",
                price: 119.95,
                imageUrl: "/cuisinart_coffee_maker.jpg",
                quantity: 1,
                collectionName: "Morning Rituals",
                sourceTag: trialDemoSeedTag,
                pattern: "electrics"
            ),
            RegistryItem(
                id: "9670912",
                name: "Dorset Martini Glasses, Set of 4",
                price: 179.80,
                imageUrl: "/crystal_martini_glass.jpg",
                quantity: 1,
                collectionName: "Hosting",
                sourceTag: trialDemoSeedTag,
                pattern: "tabletop"
            ),
            RegistryItem(
                id: "1341411",
                name: "Apilco Tradition Porcelain Cup & Saucer",
                price: 34.95,
                imageUrl: "/pillivuyt_cup.jpg",
                quantity: 4,
                collectionName: "Morning Rituals",
                sourceTag: trialDemoSeedTag,
                pattern: "tabletop"
            ),
            RegistryItem(
                id: "6247040",
                name: "Hold Everything Lidded Ceramic Bowl, 12\"",
                price: 89.95,
                imageUrl: "/ceramic_lidded_bowl_white.jpg",
                quantity: 1,
                collectionName: "Hosting",
                sourceTag: trialDemoSeedTag,
                pattern: "homekeeping"
            ),
            RegistryItem(
                id: "8227593",
                name: "Hold Everything Lazy Susan, Walnut, 10\"",
                price: 59.95,
                imageUrl: "/walnut_lazy_susan_tray.jpg",
                quantity: 1,
                collectionName: "Daily Cooking",
                sourceTag: trialDemoSeedTag,
                pattern: "homekeeping"
            )
        ]

        return Registry(
            id: demoID,
            firstName: "Sasha",
            lastName: "Andy & Home",
            event: .wedding,
            date: demoDate,
            items: seedItems,
            budget: 2500.00
        )
    }

    private var trialDemoRegistryID: UUID? {
        registries.first(where: { registry in
            registry.items.contains(where: { $0.sourceTag == trialDemoSeedTag })
        })?.id
    }

    /// Ensures the pre-made trial registry exists in persisted state.
    @discardableResult
    func ensureTrialDemoRegistryExists(selectAsActive: Bool) -> UUID {
        if let existingID = trialDemoRegistryID {
            if selectAsActive {
                activeRegistryID = existingID
                syncCurrentRegistry()
            }
            return existingID
        }

        let demoRegistry = buildDemoRegistry()
        registries.append(demoRegistry)
        if selectAsActive || activeRegistryID == nil {
            activeRegistryID = demoRegistry.id
        }
        syncCurrentRegistry()
        persistRegistryState()
        return demoRegistry.id
    }

    /// Prepares the trial demo by ensuring the linked pre-made registry exists and is active.
    func prepareTrialDemoRegistry() {
        _ = ensureTrialDemoRegistryExists(selectAsActive: true)
    }

    /// Resets all registries and re-seeds the demo data. Useful for demo-day resets.
    func resetToDemo() {
        registries.removeAll()
        activeRegistryID = nil
        currentRegistry = nil
        _ = ensureTrialDemoRegistryExists(selectAsActive: true)
    }
    
    // MARK: - Create
    var isActiveRegistry: Bool {
        currentRegistry != nil
    }
    
    func createRegistry(firstName: String,
                        lastName: String,
                        event: RegistryEvent,
                        date: Date,
                        budget: Double? = nil,
                        coverImageData: Data? = nil) {
        var created = Registry(
            id: UUID(),
            firstName: firstName,
            lastName: lastName,
            event: event,
            date: date,
            items: [],
            budget: budget
        )
        created.coverImageData = coverImageData
        activeCoverImageData = coverImageData
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

    // MARK: - Mark Item Purchased (receiver trial flow)

    /// Marks an item as purchased by product ID on the linked trial demo registry.
    /// Falls back to the active registry if the demo registry does not exist.
    func markItemPurchased(_ productId: String) {
        let targetRegistryID = trialDemoRegistryID ?? activeRegistryID
        guard let targetRegistryID else { return }
        guard let registryIndex = registries.firstIndex(where: { $0.id == targetRegistryID }) else { return }
        guard let itemIndex = registries[registryIndex].items.firstIndex(where: { $0.id == productId }) else { return }

        registries[registryIndex].items[itemIndex].isPurchased = true
        let itemName = registries[registryIndex].items[itemIndex].name
        if activeRegistryID == targetRegistryID {
            syncCurrentRegistry()
        }
        persistRegistryState()
        activities.insert(RegistryActivity(type: .purchased, productName: itemName, detail: "Purchased by a guest"), at: 0)
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
