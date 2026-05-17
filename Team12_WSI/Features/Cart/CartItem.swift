import Foundation

struct CartItem: Identifiable, Codable {
    let id: String
    let name: String
    var title: String { name } // Alias for compatibility
    let price: Double

    let path: String
    var quantity: Int
    
    let productType: String?
    let brand: String?
    let canGiftWrap: Bool
    var isGiftWrapped: Bool = false
    let availability: String?
    let deliveryEstimate: String?
    
    var imageURL: URL? {
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        return URL(string: AppConstants.API.imageBasePath + path)
    }
}

