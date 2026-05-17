import Foundation

struct ProductItem: Identifiable {
    let id: String
    let name: String
    var title: String { name } // Alias for compatibility
    let price: Double?
    let path: String?
    
    // Comprehensive Metadata Parameters
    let allProperties: [String: String]?
    let availability: String?
    let deliveryEstimate: String?
    
    // Detailed Price Tiers
    let regularPrice: Double?
    let surcharge: Double?
    let retailPrice: Double?
    let sellingPrice: Double?
    let monogramOrPersonalizationPrice: Double?

    // Convenience getters (maintains full backward compatibility)
    var productType: String? { allProperties?["productType"] }
    var brand: String? { allProperties?["brand"] }
    var pattern: String? { allProperties?["pattern"] }
    var material: String? { allProperties?["material"] }
    var collection: String? { allProperties?["collection"] }

    var imageURL: URL? {
        if let imageUrl = path {
            return URL(string: AppConstants.API.imageBasePath + imageUrl)
        }
        return nil
    }
}

extension ProductItem {
    // Custom initializer for backward compatibility with manual instantiations in other views
    init(
        id: String,
        name: String,
        price: Double?,
        path: String?,
        productType: String? = nil,
        brand: String? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.path = path
        
        var props: [String: String] = [:]
        if let type = productType { props["productType"] = type }
        if let b = brand { props["brand"] = b }
        self.allProperties = props.isEmpty ? nil : props
        
        self.availability = nil
        self.deliveryEstimate = nil
        self.regularPrice = price
        self.surcharge = nil
        self.retailPrice = price
        self.sellingPrice = price
        self.monogramOrPersonalizationPrice = nil
    }

    init(from dto: ProductItemDTO) {
        self.id = dto.id
        self.name = dto.name
        self.price = dto.price?.sellingPrice ?? dto.price?.regularPrice ?? 0.0
        self.path = dto.media?.images?.first?.path
        
        self.allProperties = dto.properties
        self.availability = dto.availability
        self.deliveryEstimate = dto.deliveryEstimate
        
        self.regularPrice = dto.price?.regularPrice
        self.surcharge = dto.price?.surcharge
        self.retailPrice = dto.price?.retailPrice
        self.sellingPrice = dto.price?.sellingPrice
        self.monogramOrPersonalizationPrice = dto.price?.monogramOrPersonalizationPrice
    }
}
