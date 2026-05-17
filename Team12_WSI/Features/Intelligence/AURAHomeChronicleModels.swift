import Foundation

struct ChroniclePurchaseRecord: Codable, Identifiable, Hashable {
    let id: String
    let productID: String
    let productName: String
    let brand: WSIBrand
    let category: String
    let room: AURARoomType
    let purchaseDate: Date
    let quantity: Int
    let unitPrice: Double
}

struct ProductLifecyclePolicy: Codable, Hashable {
    let category: String
    let expectedLifespanMonths: Int
    let monitorThreshold: Double // 0...1, e.g. 0.8 means warn at 80% lifecycle
}

struct ReplacementAlert: Codable, Identifiable, Hashable {
    let id: String
    let productID: String
    let productName: String
    let ageMonths: Int
    let expectedLifespanMonths: Int
    let replacementScore: Double // >1 means overdue
    let urgencyLabel: String
    let recommendationText: String
}

struct RoomGapSignal: Codable, Identifiable, Hashable {
    let id: String
    let room: AURARoomType
    let missingCategories: [String]
    let recommendationReason: String
}

struct ChronicleTimelineSection: Codable, Hashable {
    let year: Int
    let entries: [ChroniclePurchaseRecord]
}

struct ChronicleSummary: Codable, Hashable {
    let totalItemsTracked: Int
    let brandsCovered: [WSIBrand]
    let roomsDetected: [AURARoomType]
    let replacementAlertsCount: Int
    let gapSignalsCount: Int
}

struct CompleteYourHomeBundle: Codable, Hashable {
    let title: String
    let itemIDs: [String]
    let estimatedTotal: Double
    let appliedStoreCredit: Double
    let finalPayable: Double
    let rationale: String
}

// MARK: - Chronicle Endpoints Contracts

struct ChronicleTimelineRequest: Codable {
    let userID: String
}

struct ChronicleTimelineResponse: Codable {
    let summary: ChronicleSummary
    let timeline: [ChronicleTimelineSection]
}

struct ReplacementAlertsRequest: Codable {
    let userID: String
    let purchases: [ChroniclePurchaseRecord]
    let lifecyclePolicies: [ProductLifecyclePolicy]
}

struct ReplacementAlertsResponse: Codable {
    let alerts: [ReplacementAlert]
}

struct HomeGapRequest: Codable {
    let userID: String
    let purchases: [ChroniclePurchaseRecord]
    let targetRooms: [AURARoomType]
}

struct HomeGapResponse: Codable {
    let gaps: [RoomGapSignal]
}

struct CompleteYourHomeRequest: Codable {
    let userID: String
    let profile: UserAestheticProfile
    let ungiftedItemIDs: [String]
    let catalog: [CatalogProduct]
    let availableStoreCredit: Double
}

struct CompleteYourHomeResponse: Codable {
    let bundle: CompleteYourHomeBundle
    let rankedTopUps: [RankedRecommendation]
}
