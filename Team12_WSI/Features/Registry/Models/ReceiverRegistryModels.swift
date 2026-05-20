import Foundation

enum RegistryItemState: String, CaseIterable {
    case available = "Available"
    case groupGiftActive = "Group Gift Active"
    case celebrationPoolAssisted = "Celebration Pool Assisted"
    case emotionallyAttributed = "Emotionally Attributed"
}

enum RegistryItemCategory: String, CaseIterable {
    case essentials = "Essentials"
    case collections = "Collections"
    case groupGifts = "Group Gifts"
}

struct RegistryCollection: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let completionPercentage: Int
}

struct GroupGift: Identifiable, Hashable {
    let id = UUID()
    let totalAmountNeeded: Double
    var currentContribution: Double
    
    var remainingAmount: Double { return max(0, totalAmountNeeded - currentContribution) }
    var isFullyFunded: Bool { return currentContribution >= totalAmountNeeded }
}

struct EmotionalAttribution: Hashable {
    let contributorNames: [String]
    let totalContributors: Int
    let message: String?
}

struct ReceiverRegistryItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imagePath: String
    let price: Double
    let state: RegistryItemState
    let category: RegistryItemCategory
    var groupGift: GroupGift?
    var collection: RegistryCollection?
    var emotionalAttribution: EmotionalAttribution?
    var isPriority: Bool = false
    let description: String
    /// Links this receiver item to a real RegistryItem ID in the seeded registry
    var linkedRegistryItemID: String?
    
    /// Items that have already been gifted (celebration pool completed or emotionally attributed)
    var isGifted: Bool {
        state == .celebrationPoolAssisted || state == .emotionallyAttributed
    }
}

// MARK: - Mock Data (linked to seeded demo registry product IDs)
struct RegistryMockData {
    static let citronCollection = RegistryCollection(name: "Citron Dining Collection", completionPercentage: 82)
    static let cookingCollection = RegistryCollection(name: "Daily Cooking", completionPercentage: 60)
    static let hostingCollection = RegistryCollection(name: "Hosting", completionPercentage: 40)
    
    static let items: [ReceiverRegistryItem] = [
        // Linked to seeded registry items by their real product IDs
        ReceiverRegistryItem(
            name: "Staub Dutch Oven, 7-Qt., Basil",
            imagePath: "/staub_dutch_basil.jpg",
            price: 299.95,
            state: .available,
            category: .essentials,
            collection: cookingCollection,
            isPriority: true,
            description: "Premium enameled cast iron Dutch oven for everyday cooking.",
            linkedRegistryItemID: "2453926"
        ),
        ReceiverRegistryItem(
            name: "Dorset Martini Glasses, Set of 4",
            imagePath: "/crystal_martini_glass.jpg",
            price: 179.80,
            state: .groupGiftActive,
            category: .groupGifts,
            groupGift: GroupGift(totalAmountNeeded: 179.80, currentContribution: 65.00),
            isPriority: true,
            description: "Lead-free crystal martini glasses for hosting.",
            linkedRegistryItemID: "9670912"
        ),
        ReceiverRegistryItem(
            name: "Cuisinart PerfecTemp Coffee Maker",
            imagePath: "/cuisinart_coffee_maker.jpg",
            price: 119.95,
            state: .emotionallyAttributed,
            category: .essentials,
            emotionalAttribution: EmotionalAttribution(
                contributorNames: ["Emma", "James"],
                totalContributors: 3,
                message: "For your morning rituals together! ☕"
            ),
            description: "14-cup programmable coffee maker with thermal carafe.",
            linkedRegistryItemID: "8381456"
        ),
        ReceiverRegistryItem(
            name: "Staub Deep Skillet, 8½\", Citron",
            imagePath: "/staub_frypan_citron.jpg",
            price: 180.00,
            state: .celebrationPoolAssisted,
            category: .collections,
            collection: citronCollection,
            isPriority: true,
            description: "Enameled cast iron skillet perfect for searing and braising.",
            linkedRegistryItemID: "181543"
        ),
        ReceiverRegistryItem(
            name: "Apilco Porcelain Cup & Saucer",
            imagePath: "/pillivuyt_cup.jpg",
            price: 34.95,
            state: .available,
            category: .essentials,
            description: "Classic French porcelain cup and saucer set.",
            linkedRegistryItemID: "1341411"
        ),
        ReceiverRegistryItem(
            name: "Hold Everything Ceramic Bowl, 12\"",
            imagePath: "/ceramic_lidded_bowl_white.jpg",
            price: 89.95,
            state: .available,
            category: .essentials,
            collection: hostingCollection,
            description: "Elegant lidded ceramic bowl for pantry or serving.",
            linkedRegistryItemID: "6247040"
        )
    ]
    
    static let coupleName = "Sasha & Andy"
    static let totalContributed = 245.00
    static let intentChips = ["Future dinners", "New kitchen", "First home", "Celebrate your union"]
}
