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
    
    /// Items that have already been gifted (celebration pool completed or emotionally attributed)
    var isGifted: Bool {
        state == .celebrationPoolAssisted || state == .emotionallyAttributed
    }
}

// MARK: - Mock Data
struct RegistryMockData {
    static let citronCollection = RegistryCollection(name: "Citron Dining Collection", completionPercentage: 82)
    static let pastaBowlCollection = RegistryCollection(name: "Pasta Bowl Collection", completionPercentage: 18)
    
    static let items: [ReceiverRegistryItem] = [
        ReceiverRegistryItem(name: "Citron Dinner Plates, Set of 4", imagePath: "/img23m.jpg", price: 12000, state: .celebrationPoolAssisted, category: .collections, collection: citronCollection, isPriority: true, description: "Hand-painted citron design."),
        ReceiverRegistryItem(name: "Smeg Espresso Machine", imagePath: "/img122m.jpg", price: 45000, state: .groupGiftActive, category: .groupGifts, groupGift: GroupGift(totalAmountNeeded: 45000, currentContribution: 14000), isPriority: true, description: "Retro style espresso machine."),
        ReceiverRegistryItem(name: "Le Creuset Dutch Oven", imagePath: "/lc_fondue_cerise.jpg", price: 32000, state: .emotionallyAttributed, category: .essentials, emotionalAttribution: EmotionalAttribution(contributorNames: ["Aarav", "Riya"], totalContributors: 5, message: "Enjoy cozy dinners!"), description: "Enameled cast iron dutch oven."),
        ReceiverRegistryItem(name: "Pasta Bowls, Set of 4", imagePath: "/img10s.jpg", price: 6500, state: .available, category: .essentials, collection: pastaBowlCollection, description: "Wide and shallow bowls.")
    ]
    
    static let coupleName = "Ananya & Rohan"
    static let totalContributed = 48000.0
    static let intentChips = ["Future dinners", "New kitchen", "First home", "Celebrate your union"]
}
