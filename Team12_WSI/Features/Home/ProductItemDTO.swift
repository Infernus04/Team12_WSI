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
