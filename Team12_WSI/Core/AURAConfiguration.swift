import Foundation

// MARK: - AURA Intelligence Configuration

enum AURAConfiguration {
    // MARK: - Gemini
    // TODO: Move to environment variable / keychain for production
    static var geminiAPIKey: String {
        APIKeyManager.geminiAPIKey
    }
    static let geminiModelName = "gemini-2.0-flash"
    static let geminiTimeoutSeconds: TimeInterval = 10

    // MARK: - Mode
    /// When true, bypasses Gemini and uses deterministic ranking with template explanations.
    /// Toggle to `false` once a valid API key is set.
    static var useMockMode: Bool {
        geminiAPIKey == "YOUR_GEMINI_API_KEY_HERE"
    }

    // MARK: - Feature Flags
    static let recommendationsEnabled = true
    static let chronicleEnabled = true
    static let maxRecommendationCandidates = 15

    // MARK: - Persistence
    static let persistenceFileName = "aura_registry_store.json"
    static let currentSchemaVersion = 1

    // MARK: - Scoring Defaults
    static let defaultScoringWeights = ScoringWeights.registryDefault
}
