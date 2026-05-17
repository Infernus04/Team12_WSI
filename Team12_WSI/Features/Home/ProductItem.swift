import Foundation

struct ProductItem: Identifiable, Hashable {
    let id: String
    let name: String
    let shortName: String?
    var title: String { name } // Alias for compatibility
    let price: Double?
    let path: String?
    let productType: String?
    let brand: String?

    var imageURL: URL? {
        guard let path = path else { return nil }
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        return URL(string: AppConstants.API.imageBasePath + path)
    }
}

extension ProductItem {
    init(from dto: ProductItemDTO) {
        self.id = dto.id
        self.name = dto.name
        self.shortName = dto.shortName
        self.price = dto.price?.regularPrice ?? 0.0
        self.path = dto.media?.images?.first?.path
        self.productType = dto.properties?.productType
        self.brand = dto.properties?.brand
    }
}
