import Foundation

struct ProductItem: Identifiable, Hashable {
    let id: String
    let name: String
    let shortName: String?
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
    var canGiftWrap: Bool { allProperties?["canGiftWrap"]?.lowercased() == "true" }

    var imageURL: URL? {
        guard let path = path else { return nil }
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        return URL(string: AppConstants.API.imageBasePath + path)
    }
}

extension ProductItem {
    static let fallbackProducts: [ProductItem] = [
        ProductItem(
            id: "pb-chesterfield-sofa",
            name: "Pottery Barn Chesterfield Leather Sofa",
            price: 2299.00,
            path: "/luxury_sofa.png",
            productType: "sofa",
            brand: "pottery-barn"
        ),
        ProductItem(
            id: "we-haven-sofa",
            name: "West Elm Haven Loft Sofa",
            price: 1599.00,
            path: "/we_haven_sofa.png",
            productType: "sofa",
            brand: "west-elm"
        ),
        ProductItem(
            id: "pb-jake-sofa",
            name: "Pottery Barn Jake Upholstered Sofa",
            price: 1899.00,
            path: "/pb_jake_sofa.png",
            productType: "sofa",
            brand: "pottery-barn"
        ),
        ProductItem(
            id: "2505456",
            name: "Williams Sonoma End-Grain Cutting Board, Acacia, 15\" X 20\"",
            price: 129.95,
            path: "/ws_walnut_board.jpg",
            productType: "cutting-board",
            brand: "williams-sonoma"
        ),
        ProductItem(
            id: "8800061",
            name: "Vitamix Immersion Blender, 5-Speed",
            price: 149.56,
            path: "/mc_mocha_kettle.jpg",
            productType: "blender",
            brand: "vitamix"
        )
    ]
    
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
        self.shortName = nil
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
        self.shortName = dto.shortName
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
