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
    let properties: PropertiesDTO?
    let availability: String?
    let deliveryEstimate: String?
}

struct PriceDTO: Codable {
    let regularPrice: Double?
    let sellingPrice: Double?
}

struct MediaDTO: Codable {
    let images: [ImageDTO]?
}

struct ImageDTO: Codable {
    let path: String?
}

struct PropertiesDTO: Codable {
    let productType: String?
    let brand: String?
    let pattern: String?
    let color: String?
    let material: String?
    let canGiftWrap: String?
    let isFood: String?
    let isFurniture: String?
}
