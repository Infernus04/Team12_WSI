import Foundation

struct Registry: Identifiable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var event: RegistryEvent
    var date: Date
    var items: [RegistryItem]
    
    var displayName: String {
        "\(firstName) \(lastName)'s \(event.rawValue) Registry"
    }
}


struct RegistryItem: Identifiable, Codable {
    let id: String
    let name: String
    var title: String { name } // Alias for compatibility
    let price: Double

    let imageUrl: String
    var quantity: Int
}
