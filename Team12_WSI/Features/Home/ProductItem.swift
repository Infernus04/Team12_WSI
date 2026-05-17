import Foundation

struct ProductItem: Identifiable {
    let id: String
    let name: String
    var title: String { name } // Alias for compatibility
    let price: Double?
    let path: String?
    let productType: String?
    let brand: String?

    var imageURL: URL? {
        if let imageUrl = path {
            return URL(string: AppConstants.API.imageBasePath + imageUrl)
        }
        return nil
    }
}

extension ProductItem {
    init(from dto: ProductItemDTO) {
        self.id = dto.id
        self.name = dto.name
        self.price = dto.price?.regularPrice ?? 0.0
        self.path = dto.media?.images?.first?.path
        self.productType = dto.properties?.productType
        self.brand = dto.properties?.brand
    }
}
