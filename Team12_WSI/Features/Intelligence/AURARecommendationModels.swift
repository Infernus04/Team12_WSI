import Foundation

// MARK: - Catalog Domain

enum WSIBrand: String, Codable, CaseIterable {
    case williamsSonoma = "williams-sonoma"
    case potteryBarn = "pottery-barn"
    case westElm = "west-elm"
    case rejuvenation
    case markAndGraham = "mark-and-graham"
    case greenRow = "green-row"
    case unknown
}

enum AURABudgetBand: String, Codable, CaseIterable {
    case value
    case mid
    case premium
    case luxury
}

enum AURARoomType: String, Codable, CaseIterable {
    case kitchen
    case dining
    case living
    case bedroom
    case bathroom
    case outdoor
    case entryway
    case office
    case nursery
    case multiRoom
    case unknown
}

struct CatalogProduct: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let shortName: String?
    let brand: WSIBrand
    let productType: String
    let categoryTags: [String]
    let styleTags: [String]
    let colorTags: [String]
    let materialTags: [String]
    let roomTags: [AURARoomType]
    let regularPrice: Double?
    let sellingPrice: Double?
    let imagePath: String?
    let isGiftWrappable: Bool
    let isFood: Bool
    let isFurniture: Bool
    let availability: String?

    var effectivePrice: Double {
        if let sellingPrice {
            return sellingPrice
        }
        return regularPrice ?? 0
    }

    // Ideal for group-gifting UX in hackathon constraints.
    var fundabilityScore: Double {
        switch effectivePrice {
        case 300...1500:
            return 1.0
        case 180..<300, 1500...2200:
            return 0.7
        default:
            return 0.35
        }
    }
}

extension CatalogProduct {
    init(from dto: ProductItemDTO) {
        let brandValue = dto.properties?.brand?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let categoryTags = Self.parseList(dto.properties?.pattern) + Self.parseList(dto.properties?.productType)
        let materialTags = Self.parseList(dto.properties?.material)
        self.id = dto.id
        self.name = dto.name
        self.shortName = dto.shortName
        self.brand = WSIBrand(rawValue: brandValue) ?? .unknown
        self.productType = dto.properties?.productType ?? "unknown"
        self.categoryTags = categoryTags
        self.styleTags = Self.inferStyleTags(
            brand: self.brand,
            categoryTags: categoryTags,
            materialTags: materialTags
        )
        self.colorTags = Self.parseList(dto.properties?.color)
        self.materialTags = materialTags
        self.roomTags = Self.inferRoomTags(
            categories: self.categoryTags,
            productType: self.productType
        )
        self.regularPrice = dto.price?.regularPrice
        self.sellingPrice = dto.price?.sellingPrice
        self.imagePath = dto.media?.images?.first?.path
        self.isGiftWrappable = Self.parseBool(dto.properties?.canGiftWrap)
        self.isFood = Self.parseBool(dto.properties?.isFood)
        self.isFurniture = Self.parseBool(dto.properties?.isFurniture)
        self.availability = dto.availability
    }

    private static func parseList(_ raw: String?) -> [String] {
        guard let raw, !raw.isEmpty else { return [] }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
            let noBrackets = trimmed.dropFirst().dropLast()
            return noBrackets
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        return trimmed
            .split(separator: "/")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func parseBool(_ raw: String?) -> Bool {
        raw?.lowercased() == "true"
    }

    private static func inferStyleTags(brand: WSIBrand,
                                       categoryTags: [String],
                                       materialTags: [String]) -> [String] {
        var tags: Set<String> = []
        switch brand {
        case .williamsSonoma:
            tags.formUnion(["culinary-classic", "timeless"])
        case .potteryBarn:
            tags.formUnion(["heritage", "classic"])
        case .westElm:
            tags.formUnion(["modern", "japandi-adjacent"])
        case .rejuvenation:
            tags.formUnion(["vintage-modern", "crafted"])
        case .markAndGraham:
            tags.formUnion(["personalized", "gift-centric"])
        case .greenRow:
            tags.formUnion(["organic-modern", "earthy"])
        case .unknown:
            break
        }

        if categoryTags.contains(where: { $0.contains("cook") }) {
            tags.insert("culinary")
        }
        if materialTags.contains(where: { $0.contains("wood") }) {
            tags.insert("warm-natural")
        }
        return Array(tags)
    }

    private static func inferRoomTags(categories: [String], productType: String) -> [AURARoomType] {
        let corpus = (categories + [productType]).joined(separator: " ").lowercased()
        if corpus.contains("cook") || corpus.contains("cutlery") || corpus.contains("kitchen") {
            return [.kitchen]
        }
        if corpus.contains("table") || corpus.contains("glassware") || corpus.contains("dining") {
            return [.dining]
        }
        if corpus.contains("sofa") || corpus.contains("living") {
            return [.living]
        }
        if corpus.contains("bed") || corpus.contains("linen") {
            return [.bedroom]
        }
        return [.unknown]
    }
}

// MARK: - Recommendation Inputs

struct UserAestheticProfile: Codable, Hashable {
    let primaryStyle: String
    let secondaryStyles: [String]
    let dominantColorsHex: [String]
    let roomPriorities: [AURARoomType]
    let budgetBand: AURABudgetBand
    let brandAffinity: [BrandAffinity]
}

struct BrandAffinity: Codable, Hashable {
    let brand: WSIBrand
    let weight: Double // 0...1
}

struct LifestyleSearchRequest: Codable {
    let query: String
    let userProfile: UserAestheticProfile?
    let maxResults: Int
}

struct RegistryCompletionRequest: Codable {
    let userProfile: UserAestheticProfile
    let existingRegistryProductIDs: [String]
    let receivedProductIDs: [String]
    let candidateProducts: [CatalogProduct]
    let maxResults: Int
}

// MARK: - Recommendation Outputs

struct RecommendationScoreBreakdown: Codable, Hashable {
    let styleMatch: Double
    let colorHarmony: Double
    let categoryGapFill: Double
    let brandAffinity: Double
    let budgetFit: Double
    let popularityPrior: Double
    let finalScore: Double
}

struct RankedRecommendation: Codable, Identifiable, Hashable {
    let id: String
    let product: CatalogProduct
    let score: RecommendationScoreBreakdown
    let explanation: String
    let confidenceLabel: String
}

struct CrossBrandBundleSuggestion: Codable, Hashable {
    let title: String
    let productIDs: [String]
    let narrative: String
}

struct LifestyleSearchResponse: Codable {
    let queryUnderstanding: String
    let rankedProducts: [RankedRecommendation]
    let bundles: [CrossBrandBundleSuggestion]
}

struct RegistryCompletionResponse: Codable {
    let missingCategories: [String]
    let rankedProducts: [RankedRecommendation]
    let bundles: [CrossBrandBundleSuggestion]
}

// MARK: - LLM Contracts (Gemini)

struct GeminiRankingInput: Codable {
    let intent: String
    let userProfile: UserAestheticProfile?
    let candidates: [CatalogProduct]
    let scoringWeights: ScoringWeights
}

struct GeminiRankingOutput: Codable {
    let rankedProductIDs: [String]
    let explanationsByProductID: [String: String]
    let confidenceByProductID: [String: String]
    let querySummary: String
}

struct ScoringWeights: Codable, Hashable {
    let styleMatch: Double
    let colorHarmony: Double
    let categoryGapFill: Double
    let brandAffinity: Double
    let budgetFit: Double
    let popularityPrior: Double

    static let registryDefault = ScoringWeights(
        styleMatch: 0.35,
        colorHarmony: 0.20,
        categoryGapFill: 0.20,
        brandAffinity: 0.10,
        budgetFit: 0.05,
        popularityPrior: 0.10
    )
}
