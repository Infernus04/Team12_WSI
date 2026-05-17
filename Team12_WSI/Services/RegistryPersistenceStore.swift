import Foundation

// MARK: - Persistence Envelope

struct PersistenceEnvelope: Codable {
    var schemaVersion: Int
    var registry: Registry?
    var questionnaire: RegistryQuestionnairePayload?
    var lastRecommendations: [RankedRecommendation]?
    var lastRecommendationSections: [RegistryRecommendationSection]?
    var chronicleSeed: [ChroniclePurchaseRecord]?
    var savedAt: Date

    static var empty: PersistenceEnvelope {
        PersistenceEnvelope(
            schemaVersion: AURAConfiguration.currentSchemaVersion,
            registry: nil,
            questionnaire: nil,
            lastRecommendations: nil,
            lastRecommendationSections: nil,
            chronicleSeed: nil,
            savedAt: Date()
        )
    }
}

// MARK: - Registry Persistence Store

actor RegistryPersistenceStore {
    static let shared = RegistryPersistenceStore()

    private let fileName: String
    private var envelope: PersistenceEnvelope
    private var hasLoaded = false

    init(fileName: String = AURAConfiguration.persistenceFileName) {
        self.fileName = fileName
        self.envelope = .empty
    }

    // MARK: - File URL

    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(fileName)
    }

    // MARK: - Load

    func load() -> PersistenceEnvelope {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            hasLoaded = true
            return .empty
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            var loaded = try decoder.decode(PersistenceEnvelope.self, from: data)

            // Schema migration placeholder
            if loaded.schemaVersion < AURAConfiguration.currentSchemaVersion {
                loaded.schemaVersion = AURAConfiguration.currentSchemaVersion
            }

            self.envelope = loaded
            hasLoaded = true
            return loaded
        } catch {
            print("[RegistryPersistenceStore] Load failed: \(error.localizedDescription)")
            hasLoaded = true
            return .empty
        }
    }

    private func ensureLoaded() {
        guard !hasLoaded else { return }
        _ = load()
    }

    // MARK: - Save

    private func persist() {
        do {
            envelope.savedAt = Date()
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(envelope)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("[RegistryPersistenceStore] Save failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Registry

    func saveRegistry(_ registry: Registry?) {
        ensureLoaded()
        envelope.registry = registry
        persist()
    }

    func loadRegistry() -> Registry? {
        ensureLoaded()
        return envelope.registry
    }

    // MARK: - Questionnaire

    func saveQuestionnaire(_ payload: RegistryQuestionnairePayload) {
        ensureLoaded()
        envelope.questionnaire = payload
        persist()
    }

    func loadQuestionnaire() -> RegistryQuestionnairePayload? {
        ensureLoaded()
        return envelope.questionnaire
    }

    // MARK: - Recommendations

    func saveRecommendations(
        _ recommendations: [RankedRecommendation],
        sections: [RegistryRecommendationSection]
    ) {
        ensureLoaded()
        envelope.lastRecommendations = recommendations
        envelope.lastRecommendationSections = sections
        persist()
    }

    func loadRecommendations() -> (
        recommendations: [RankedRecommendation],
        sections: [RegistryRecommendationSection]
    )? {
        ensureLoaded()
        guard let recs = envelope.lastRecommendations,
              let secs = envelope.lastRecommendationSections else { return nil }
        return (recs, secs)
    }

    // MARK: - Chronicle

    func saveChronicleSeed(_ records: [ChroniclePurchaseRecord]) {
        ensureLoaded()
        envelope.chronicleSeed = records
        persist()
    }

    func loadChronicleSeed() -> [ChroniclePurchaseRecord]? {
        ensureLoaded()
        return envelope.chronicleSeed
    }

    // MARK: - Clear

    func clearAll() {
        ensureLoaded()
        envelope = .empty
        persist()
    }
}
