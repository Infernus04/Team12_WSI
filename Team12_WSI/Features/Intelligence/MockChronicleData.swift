import Foundation

// MARK: - Mock Chronicle Data

/// Seed data for Home Chronicle demo.
/// Contains purchase records, lifecycle policies, and popularity priors.
enum MockChronicleData {

    // MARK: - Lifecycle Policies

    static let lifecyclePolicies: [ProductLifecyclePolicy] = [
        ProductLifecyclePolicy(category: "Cookware", expectedLifespanMonths: 60, monitorThreshold: 0.8),
        ProductLifecyclePolicy(category: "Cutlery", expectedLifespanMonths: 120, monitorThreshold: 0.8),
        ProductLifecyclePolicy(category: "Knives", expectedLifespanMonths: 120, monitorThreshold: 0.8),
        ProductLifecyclePolicy(category: "Bedding", expectedLifespanMonths: 36, monitorThreshold: 0.8),
        ProductLifecyclePolicy(category: "Linen", expectedLifespanMonths: 36, monitorThreshold: 0.8),
        ProductLifecyclePolicy(category: "Towels", expectedLifespanMonths: 24, monitorThreshold: 0.8),
        ProductLifecyclePolicy(category: "Glassware", expectedLifespanMonths: 48, monitorThreshold: 0.8),
        ProductLifecyclePolicy(category: "Appliances", expectedLifespanMonths: 84, monitorThreshold: 0.8),
        ProductLifecyclePolicy(category: "Dinnerware", expectedLifespanMonths: 72, monitorThreshold: 0.8),
        ProductLifecyclePolicy(category: "Decor", expectedLifespanMonths: 120, monitorThreshold: 0.9)
    ]

    // MARK: - Sample Purchase Records

    static let samplePurchases: [ChroniclePurchaseRecord] = [
        // 2023
        ChroniclePurchaseRecord(
            id: "p-001", productID: "sku-dutch-oven", productName: "Le Creuset Dutch Oven",
            brand: .williamsSonoma, category: "Cookware", room: .kitchen,
            purchaseDate: date(2023, 3, 15), quantity: 1, unitPrice: 420.00
        ),
        ChroniclePurchaseRecord(
            id: "p-002", productID: "sku-knife-set", productName: "Wüsthof Classic 8\" Chef's Knife",
            brand: .williamsSonoma, category: "Cutlery", room: .kitchen,
            purchaseDate: date(2023, 3, 15), quantity: 1, unitPrice: 179.95
        ),
        ChroniclePurchaseRecord(
            id: "p-003", productID: "sku-linen-sheets", productName: "Belgian Flax Linen Sheet Set",
            brand: .potteryBarn, category: "Bedding", room: .bedroom,
            purchaseDate: date(2023, 5, 22), quantity: 1, unitPrice: 329.00
        ),
        ChroniclePurchaseRecord(
            id: "p-004", productID: "sku-bath-towels", productName: "Organic Cotton Bath Towels",
            brand: .potteryBarn, category: "Towels", room: .bathroom,
            purchaseDate: date(2023, 6, 10), quantity: 4, unitPrice: 39.00
        ),

        // 2024
        ChroniclePurchaseRecord(
            id: "p-005", productID: "sku-wine-glasses", productName: "Estate Wine Glasses (Set of 6)",
            brand: .williamsSonoma, category: "Glassware", room: .dining,
            purchaseDate: date(2024, 1, 20), quantity: 1, unitPrice: 89.95
        ),
        ChroniclePurchaseRecord(
            id: "p-006", productID: "sku-blender", productName: "Vitamix A3500 Blender",
            brand: .williamsSonoma, category: "Appliances", room: .kitchen,
            purchaseDate: date(2024, 4, 8), quantity: 1, unitPrice: 699.95
        ),
        ChroniclePurchaseRecord(
            id: "p-007", productID: "sku-dinner-plates", productName: "Marin Dinner Plate Set",
            brand: .williamsSonoma, category: "Dinnerware", room: .dining,
            purchaseDate: date(2024, 6, 1), quantity: 8, unitPrice: 14.95
        ),
        ChroniclePurchaseRecord(
            id: "p-008", productID: "sku-cast-iron", productName: "Lodge Cast Iron Skillet",
            brand: .williamsSonoma, category: "Cookware", room: .kitchen,
            purchaseDate: date(2024, 9, 12), quantity: 1, unitPrice: 44.90
        ),

        // 2025
        ChroniclePurchaseRecord(
            id: "p-009", productID: "sku-espresso", productName: "Breville Barista Express",
            brand: .williamsSonoma, category: "Appliances", room: .kitchen,
            purchaseDate: date(2025, 2, 14), quantity: 1, unitPrice: 749.95
        ),
        ChroniclePurchaseRecord(
            id: "p-010", productID: "sku-serving-bowl", productName: "Staub Ceramic Serving Bowl",
            brand: .williamsSonoma, category: "Dinnerware", room: .dining,
            purchaseDate: date(2025, 5, 3), quantity: 2, unitPrice: 79.95
        )
    ]

    // MARK: - Helper

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - Mock Product Catalog

enum MockProductCatalog {
    /// Fallback product catalog when API is unavailable.
    static let sampleProducts: [CatalogProduct] = {
        let seeds: [(String, WSIBrand, String, [String], [String], [String], [String], [AURARoomType], Double, String)] = [
            ("Dutch Oven", .williamsSonoma, "Cookware", ["cook", "kitchen"], ["culinary-classic"], ["flame"], ["cast-iron"], [.kitchen], 420, "/img122m.jpg"),
            ("Knife Set", .williamsSonoma, "Cutlery", ["cutlery", "kitchen"], ["heritage"], ["steel"], ["stainless-steel"], [.kitchen], 450, "/img17m.jpg"),
            ("Blender", .williamsSonoma, "Appliances", ["appliance", "kitchen"], ["modern"], ["graphite"], ["metal"], [.kitchen], 699.95, "/img83m.jpg"),
            ("Serving Bowl Set", .williamsSonoma, "Dinnerware", ["serving", "dining"], ["timeless"], ["white"], ["ceramic"], [.dining], 179.95, "/img64m.jpg"),
            ("Wine Glass Set", .williamsSonoma, "Glassware", ["glass", "bar", "dining"], ["classic"], ["clear"], ["crystal"], [.dining], 89.95, "/img95m.jpg"),
            ("Dinner Plate Set", .potteryBarn, "Dinnerware", ["plate", "table"], ["warm-natural"], ["ivory"], ["stoneware"], [.dining], 59.95, "/img5m.jpg"),
            ("Linen Sheet Set", .potteryBarn, "Bedding", ["bed", "linen"], ["organic-modern"], ["oat"], ["linen"], [.bedroom], 329, "/img42m.jpg"),
            ("Bath Towel Bundle", .potteryBarn, "Towels", ["bath", "towel"], ["classic"], ["white"], ["cotton"], [.bathroom], 78, "/img23m.jpg"),
            ("Espresso Machine", .williamsSonoma, "Appliances", ["coffee", "espresso", "kitchen"], ["modern"], ["stainless"], ["metal"], [.kitchen], 749.95, "/img4m.jpg"),
            ("Measuring Cup Set", .williamsSonoma, "Cookware", ["cook", "bake"], ["crafted"], ["copper"], ["copper"], [.kitchen], 129.95, "/img12c.jpg")
        ]

        let priceMultipliers: [Double] = [0.7, 0.85, 1.0, 1.25, 1.5, 1.8]
        let colorVariants: [String] = ["navy", "ivory", "gold", "sage", "walnut", "charcoal"]

        var products: [CatalogProduct] = []
        var nextID = 1

        for seed in seeds {
            for idx in 0..<12 {
                let multiplier = priceMultipliers[idx % priceMultipliers.count]
                let color = colorVariants[idx % colorVariants.count]
                products.append(
                    CatalogProduct(
                        id: String(format: "mock-%03d", nextID),
                        name: "\(seed.0) \(idx + 1)",
                        shortName: seed.0,
                        brand: seed.1,
                        productType: seed.2,
                        categoryTags: seed.3,
                        styleTags: seed.4,
                        colorTags: seed.5 + [color],
                        materialTags: seed.6,
                        collection: nil,
                        roomTags: seed.7,
                        regularPrice: (seed.8 * multiplier).rounded(.toNearestOrAwayFromZero),
                        sellingPrice: nil,
                        imagePath: seed.9,
                        isGiftWrappable: true,
                        isFood: false,
                        isFurniture: false,
                        availability: "In Stock"
                    )
                )
                nextID += 1
            }
        }
        return products
    }()
}
