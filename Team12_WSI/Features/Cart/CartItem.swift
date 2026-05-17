import Foundation

struct CartItem: Identifiable, Codable {
    let id: String
    let name: String
    var title: String { name } // Alias for compatibility
    let price: Double

    let path: String
    var quantity: Int
    
    var imageURL: URL? {
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        return URL(string: AppConstants.API.imageBasePath + path)
    }
}

