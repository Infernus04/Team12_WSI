import Foundation

// MARK: - Questionnaire Payload (supports skipped answers)

enum RegistryQuestionKey: String, Codable, CaseIterable, Hashable {
    case homeVision
    case moodboardVibe
    case homeType
    case hobbies
    case lifestyleMoments
    case productCategories
    case budgetPreference
    case visualStyles
}

enum QuestionAnswerState: String, Codable, Hashable {
    case answered
    case skipped
}

struct QuestionnaireSelection: Codable, Hashable {
    let key: RegistryQuestionKey
    let state: QuestionAnswerState
    let values: [String] // normalized answer ids/tags

    static func answered(_ key: RegistryQuestionKey, values: [String]) -> QuestionnaireSelection {
        QuestionnaireSelection(key: key, state: .answered, values: values)
    }

    static func skipped(_ key: RegistryQuestionKey) -> QuestionnaireSelection {
        QuestionnaireSelection(key: key, state: .skipped, values: [])
    }
}

struct RegistryQuestionnairePayload: Codable, Hashable {
    let registryID: UUID
    let createdAt: Date
    let moodboardPhotoCount: Int?
    let selections: [QuestionnaireSelection]

    init(
        registryID: UUID,
        createdAt: Date,
        moodboardPhotoCount: Int? = nil,
        selections: [QuestionnaireSelection]
    ) {
        self.registryID = registryID
        self.createdAt = createdAt
        self.moodboardPhotoCount = moodboardPhotoCount
        self.selections = selections
    }

    private enum CodingKeys: String, CodingKey {
        case registryID
        case createdAt
        case moodboardPhotoCount
        case selections
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        registryID = try container.decode(UUID.self, forKey: .registryID)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        moodboardPhotoCount = try container.decodeIfPresent(Int.self, forKey: .moodboardPhotoCount)
        selections = try container.decode([QuestionnaireSelection].self, forKey: .selections)
    }
}

// MARK: - Derived Recommendation Context

struct RegistryRecommendationContext: Codable, Hashable {
    let registryID: UUID
    let profile: UserAestheticProfile
    let prioritizedCategories: [String]
    let missingAnswerKeys: [RegistryQuestionKey]
    let normalizedTags: [String]
}

struct RegistryRecommendationRequest: Codable {
    let context: RegistryRecommendationContext
    let catalog: [CatalogProduct]
    let maxResults: Int
}

struct RegistryRecommendationResponse: Codable {
    let contextSummary: String
    let recommendations: [RankedRecommendation]
    let categorySections: [RegistryRecommendationSection]
}

struct RegistryCollectionBundle: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let productIDs: [String]
}

struct RegistryRecommendationSection: Codable, Hashable, Identifiable {
    let id: String
    let category: String
    let title: String
    let productIDs: [String]
}

// MARK: - Persistence Models

// Separate store so current Registry/Cart screens remain backward-compatible.
struct RegistryIntelligenceSnapshot: Codable, Hashable, Identifiable {
    let id: UUID // registryID
    let questionnaire: RegistryQuestionnairePayload
    let lastGeneratedAt: Date?
    let lastRecommendations: [RankedRecommendation]
}
