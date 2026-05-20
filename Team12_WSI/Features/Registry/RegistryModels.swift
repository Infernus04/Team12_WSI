import Foundation

struct Registry: Identifiable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var event: RegistryEvent
    var date: Date
    var items: [RegistryItem]
    var budget: Double?
    /// In-memory only — not persisted to disk. Excluded from CodingKeys.
    var coverImageData: Data? = nil
    
    var displayName: String {
        "\(firstName) \(lastName)'s \(event.rawValue) Registry"
    }

    private enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, event, date, items, budget
    }
}


struct RegistryItem: Identifiable, Codable {
    let id: String
    let name: String
    var title: String { name } // Alias for compatibility
    let price: Double

    let imageUrl: String
    var quantity: Int
    var collectionName: String?
    var sourceTag: String?
    var pattern: String?
    var isPurchased: Bool

    init(
        id: String,
        name: String,
        price: Double,
        imageUrl: String,
        quantity: Int,
        collectionName: String? = nil,
        sourceTag: String? = nil,
        pattern: String? = nil,
        isPurchased: Bool = false
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.imageUrl = imageUrl
        self.quantity = quantity
        self.collectionName = collectionName
        self.sourceTag = sourceTag
        self.pattern = pattern
        self.isPurchased = isPurchased
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case imageUrl
        case quantity
        case collectionName
        case sourceTag
        case pattern
        case isPurchased
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        quantity = try container.decode(Int.self, forKey: .quantity)
        collectionName = try container.decodeIfPresent(String.self, forKey: .collectionName)
        sourceTag = try container.decodeIfPresent(String.self, forKey: .sourceTag)
        pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
        isPurchased = try container.decodeIfPresent(Bool.self, forKey: .isPurchased) ?? false
    }
}
