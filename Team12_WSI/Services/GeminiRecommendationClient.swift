import Foundation

// MARK: - Gemini Recommendation Client

/// Wraps Gemini API calls for recommendation reranking and explanation generation.
/// Falls back to deterministic results on any failure.
///
/// NOTE: Requires `generative-ai-swift` SPM package to be added to the Xcode project.
/// Until then, this uses a simulated Gemini response path.
final class GeminiRecommendationClient {

    // MARK: - Public API

    /// Rerank candidates using Gemini and return enriched explanations.
    /// Falls back to deterministic ranking on any failure.
    func rerank(
        candidates: [RankedRecommendation],
        profile: UserAestheticProfile?,
        intent: String
    ) async -> [RankedRecommendation] {
        guard !AURAConfiguration.useMockMode else {
            return candidates // Already ranked deterministically
        }

        do {
            let output = try await callGemini(
                candidates: candidates.map(\.product),
                profile: profile,
                intent: intent
            )

            // Validate: only accept IDs from our candidate set
            let candidateIDs = Set(candidates.map(\.id))
            let validRankedIDs = output.rankedProductIDs.filter { candidateIDs.contains($0) }

            guard !validRankedIDs.isEmpty else {
                print("[GeminiClient] No valid IDs returned, falling back to deterministic")
                return candidates
            }

            // Rebuild ranked list with Gemini explanations
            let candidateMap = Dictionary(uniqueKeysWithValues: candidates.map { ($0.id, $0) })
            var reranked: [RankedRecommendation] = []

            for id in validRankedIDs {
                guard let original = candidateMap[id] else { continue }
                let explanation = output.explanationsByProductID[id] ?? original.explanation
                let confidence = output.confidenceByProductID[id] ?? original.confidenceLabel

                reranked.append(RankedRecommendation(
                    id: original.id,
                    product: original.product,
                    score: original.score,
                    explanation: explanation,
                    confidenceLabel: confidence
                ))
            }

            // Append any candidates that Gemini didn't rank (keeps completeness)
            for candidate in candidates where !validRankedIDs.contains(candidate.id) {
                reranked.append(candidate)
            }

            return reranked

        } catch {
            print("[GeminiClient] Rerank failed: \(error.localizedDescription), using fallback")
            return candidates
        }
    }

    // MARK: - Gemini API Call

    private func callGemini(
        candidates: [CatalogProduct],
        profile: UserAestheticProfile?,
        intent: String
    ) async throws -> GeminiRankingOutput {
        // Build the prompt
        let prompt = buildPrompt(candidates: candidates, profile: profile, intent: intent)

        // -----------------------------------------------------------
        // SIMULATED GEMINI CALL
        // When `generative-ai-swift` is added to the project, replace
        // this block with:
        //
        //   import GoogleGenerativeAI
        //   let model = GenerativeModel(
        //       name: AURAConfiguration.geminiModelName,
        //       apiKey: AURAConfiguration.geminiAPIKey
        //   )
        //   let response = try await model.generateContent(prompt)
        //   guard let text = response.text else { throw GeminiError.emptyResponse }
        //   return try parseOutput(text, candidateIDs: Set(candidates.map(\.id)))
        // -----------------------------------------------------------

        // Simulate network delay
        try await Task.sleep(nanoseconds: 800_000_000)

        // Return a simulated reranking (same order, enriched explanations)
        let explanations = Dictionary(
            uniqueKeysWithValues: candidates.prefix(15).map { product in
                (product.id, generateSimulatedExplanation(for: product, profile: profile))
            }
        )

        let confidences = Dictionary(
            uniqueKeysWithValues: candidates.prefix(15).enumerated().map { index, product in
                (product.id, index < 5 ? "High" : (index < 10 ? "Medium" : "Suggested"))
            }
        )

        return GeminiRankingOutput(
            rankedProductIDs: candidates.prefix(15).map(\.id),
            explanationsByProductID: explanations,
            confidenceByProductID: confidences,
            querySummary: "Curated for a \(profile?.primaryStyle ?? "modern") home with focus on quality and warmth."
        )
    }

    // MARK: - Prompt Builder

    private func buildPrompt(
        candidates: [CatalogProduct],
        profile: UserAestheticProfile?,
        intent: String
    ) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        let candidateJSON: String
        do {
            let data = try encoder.encode(candidates.prefix(15).map { $0 })
            candidateJSON = String(data: data, encoding: .utf8) ?? "[]"
        } catch {
            candidateJSON = "[]"
        }

        let profileJSON: String
        if let profile {
            do {
                let data = try encoder.encode(profile)
                profileJSON = String(data: data, encoding: .utf8) ?? "{}"
            } catch {
                profileJSON = "{}"
            }
        } else {
            profileJSON = "{}"
        }

        return """
        You are a luxury home product recommendation engine for Williams-Sonoma.
        Your tone is refined, concise, and elegant. Never use casual language.

        TASK: Rank the following candidate products for the user's registry.
        You MUST only use product IDs from the candidates provided.
        Do NOT invent or hallucinate any product IDs.

        USER INTENT: \(intent)

        USER PROFILE:
        \(profileJSON)

        CANDIDATE PRODUCTS:
        \(candidateJSON)

        RESPOND WITH STRICT JSON ONLY (no markdown, no explanation outside JSON):
        {
            "rankedProductIDs": ["id1", "id2", ...],
            "explanationsByProductID": {"id1": "max 20 words", ...},
            "confidenceByProductID": {"id1": "High|Medium|Suggested", ...},
            "querySummary": "one line summary"
        }

        RULES:
        - Rank by relevance to user profile and intent.
        - Maximum 20 words per explanation.
        - Confidence: High (strong match), Medium (good match), Suggested (worth considering).
        - Use ONLY IDs from the candidates above.
        """
    }

    // MARK: - Response Parser

    private func parseOutput(
        _ text: String,
        candidateIDs: Set<String>
    ) throws -> GeminiRankingOutput {
        // Extract JSON from potential markdown wrapping
        var jsonString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if jsonString.hasPrefix("```json") {
            jsonString = String(jsonString.dropFirst(7))
        }
        if jsonString.hasPrefix("```") {
            jsonString = String(jsonString.dropFirst(3))
        }
        if jsonString.hasSuffix("```") {
            jsonString = String(jsonString.dropLast(3))
        }
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = jsonString.data(using: .utf8) else {
            throw GeminiError.invalidJSON
        }

        let output = try JSONDecoder().decode(GeminiRankingOutput.self, from: data)

        // Validate all IDs are from candidate set
        let validIDs = output.rankedProductIDs.filter { candidateIDs.contains($0) }
        guard !validIDs.isEmpty else {
            throw GeminiError.noValidIDs
        }

        return GeminiRankingOutput(
            rankedProductIDs: validIDs,
            explanationsByProductID: output.explanationsByProductID.filter { candidateIDs.contains($0.key) },
            confidenceByProductID: output.confidenceByProductID.filter { candidateIDs.contains($0.key) },
            querySummary: output.querySummary
        )
    }

    // MARK: - Simulated Explanation

    private func generateSimulatedExplanation(for product: CatalogProduct, profile: UserAestheticProfile?) -> String {
        let style = profile?.primaryStyle.replacingOccurrences(of: "-", with: " ").capitalized ?? "refined"
        let templates = [
            "A timeless addition that complements your \(style.lowercased()) home.",
            "Crafted quality that elevates everyday living.",
            "Essential for the kitchen experiences you value most.",
            "Perfectly suited to your entertaining style.",
            "A foundational piece for shared moments at home.",
            "Designed for the rituals that define your mornings.",
            "Blends function and beauty for your daily routines."
        ]

        // Deterministic selection based on product ID hash
        let index = abs(product.id.hashValue) % templates.count
        return templates[index]
    }
}

// MARK: - Errors

enum GeminiError: Error, LocalizedError {
    case emptyResponse
    case invalidJSON
    case noValidIDs
    case timeout

    var errorDescription: String? {
        switch self {
        case .emptyResponse: return "Gemini returned an empty response."
        case .invalidJSON: return "Gemini response was not valid JSON."
        case .noValidIDs: return "Gemini returned no valid product IDs."
        case .timeout: return "Gemini request timed out."
        }
    }
}
