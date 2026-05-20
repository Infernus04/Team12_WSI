import Foundation

struct ProductResponseDTO: Codable {
    let count: Int
    let products: [ProductItemDTO]
}

struct ProductItemDTO: Codable {
    let id: String
    let name: String
    let shortName: String?
    let price: PriceDTO?
    let media: MediaDTO?
    let properties: [String: String]? // Decodes EVERY property dynamically
    let availability: String?
    let deliveryEstimate: String?
}

struct PriceDTO: Codable {
    let regularPrice: Double?
    let surcharge: Double?
    let retailPrice: Double?
    let sellingPrice: Double?
    let monogramOrPersonalizationPrice: Double?
}

struct MediaDTO: Codable {
    let images: [ImageDTO]?
}

struct ImageDTO: Codable {
    let path: String?
}

extension Dictionary where Key == String, Value == String {
    var brand: String? { self["brand"] }
    var pattern: String? { self["pattern"] }
    var productType: String? { self["productType"] }
    var material: String? { self["material"] }
    var color: String? { self["color"] }
    var canGiftWrap: String? { self["canGiftWrap"] }
    var isFood: String? { self["isFood"] }
    var isFurniture: String? { self["isFurniture"] }
    var collection: String? { self["collection"] }
}
