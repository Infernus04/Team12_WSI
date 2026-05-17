# AURA Intelligence Implementation Plan (Antigravity Handoff)

## Scope
This plan covers only:
- Recommendations engine
- Home Chronicle engine

Registry creation UI exists but is being updated, and cart UI is not finalized yet. Treat both as evolving consumers of these services and keep contracts additive/non-breaking.

## Stack Decision
- LLM provider: Gemini (via `generative-ai-swift`)
- Frontend: SwiftUI (existing iOS app)
- Data source: static/mock product catalog + mock purchase history for hackathon
- Recommendation mode: hybrid scoring
  - deterministic weighted ranker (fast + reliable)
  - optional Gemini reranker/explainer (presentation quality)

## Brand Constraints (must preserve in outputs)
- Palette and tone: premium, understated, curated, timeless.
- Recommendation copy style: short, elegant, confidence-oriented.
- Avoid casual/overhyped phrasing.

## Architecture
1. UI screen calls ViewModel methods.
2. ViewModel calls `AURAIntelligenceService`.
3. Service loads products/purchases and computes deterministic ranking.
4. Service optionally calls Gemini for rerank + explanation.
5. Service returns typed response models to UI.

## Data Contracts (implemented in code)
- Recommendation models:
  - `CatalogProduct`
  - `UserAestheticProfile`
  - `LifestyleSearchRequest/Response`
  - `RegistryCompletionRequest/Response`
  - `RankedRecommendation`
  - `RecommendationScoreBreakdown`
- Home Chronicle models:
  - `ChroniclePurchaseRecord`
  - `ProductLifecyclePolicy`
  - `ReplacementAlert`
  - `RoomGapSignal`
  - `CompleteYourHomeRequest/Response`

All models are in:
- `Team12_WSI/Features/Intelligence/AURARecommendationModels.swift`
- `Team12_WSI/Features/Intelligence/AURAHomeChronicleModels.swift`

## API/Service Interfaces to Implement
Create protocol-first interfaces so UI can run in mock mode.

```swift
protocol AURARecommendationServicing {
    func lifestyleSearch(_ request: LifestyleSearchRequest) async throws -> LifestyleSearchResponse
    func registryCompletion(_ request: RegistryCompletionRequest) async throws -> RegistryCompletionResponse
}

protocol AURAChronicleServicing {
    func timeline(_ request: ChronicleTimelineRequest) async throws -> ChronicleTimelineResponse
    func replacementAlerts(_ request: ReplacementAlertsRequest) async throws -> ReplacementAlertsResponse
    func homeGaps(_ request: HomeGapRequest) async throws -> HomeGapResponse
    func completeYourHome(_ request: CompleteYourHomeRequest) async throws -> CompleteYourHomeResponse
}
```

## Deterministic Ranking Logic (Hackathon-safe)
For each candidate product:
- `styleMatch`: overlap(query/profile style tags, product style tags)
- `colorHarmony`: overlap(profile dominant colors, product color tags)
- `categoryGapFill`: whether it fills missing categories from registry/home
- `brandAffinity`: weighted value from user profile
- `budgetFit`: match between product price and budget band
- `popularityPrior`: static prior from mock data for demo

Final score:
- `final = sum(weight_i * metric_i)`
- Default weights:
  - style 0.35
  - color 0.20
  - category gap 0.20
  - brand affinity 0.10
  - budget fit 0.05
  - popularity prior 0.10

## Gemini Integration Plan (`generative-ai-swift`)
Use Gemini only after deterministic top-K filtering (K=12 or K=15).

### Why
- token control
- stable latency
- predictable cost
- avoids exhausting quota during demos

### Prompt Contract
Input JSON:
- intent/query
- user profile
- top-K candidate products
- scoring weights

Output JSON:
- ranked product IDs
- explanation per product ID
- confidence label per product ID
- one-line query summary

### Guardrails
- JSON-only response
- no product hallucination (must rank from given IDs only)
- max explanation length ~20 words

### Failure Fallback
If Gemini call fails or times out:
- return deterministic ranking
- generate local template explanations

## Home Chronicle Logic

### Timeline
- Group purchases by year.
- Summarize brand spread and room coverage.

### Replacement Alerts
- `ageMonths = now - purchaseDate`
- `replacementScore = ageMonths / expectedLifespanMonths`
- labels:
  - `Watch` for `0.8...1.0`
  - `Ready to Replace` for `>1.0`

### Home Gaps
- Infer missing room categories from purchase history.
- Return 1-2 actionable category gaps per room.

### Complete Your Home Bundle
- Start from ungifted/high-priority items.
- Add cross-brand complements.
- Apply store credit and compute final payable.

## Work Breakdown (48 Hours)

### Block A: Foundations (4-6h)
- finalize models (done)
- add mock JSON data:
  - `products_seed.json`
  - `purchases_seed.json`
  - `popularity_seed.json`
- implement repository loaders

### Block B: Recommendation Engine (8-10h)
- deterministic ranker
- lifestyle search endpoint/service
- registry completion endpoint/service
- cross-brand bundle generator

### Block C: Gemini Layer (5-7h)
- `GeminiClient` wrapper
- prompt builder
- strict JSON decode
- fallback behavior

### Block D: Chronicle Engine (8-10h)
- timeline
- replacement alerts
- home gaps
- complete-your-home bundle

### Block E: App Integration + Polish (6-8h)
- ViewModel wiring
- loading/error states
- premium copy tone pass
- mock mode toggle for live demo safety

## Team Integration Contract (what Antigravity needs)
Expose async methods returning typed models only; no raw maps.

Required UI fields for recommendation cards:
- product name
- brand
- price
- explanation
- confidence label

Required UI fields for chronicle:
- timeline sections
- replacement alerts
- room gaps
- complete-your-home bundle summary

## Testing Checklist
- deterministic ranking returns consistent top-N for same input
- Gemini failure path returns usable results
- empty purchase history handled gracefully
- invalid color/style tags do not crash ranking
- out-of-budget products still appear with lower score (not dropped blindly)

## Demo Script (recommended)
1. Run lifestyle query: "warm japandi kitchen"
2. Show top cross-brand recommendations + explanations
3. Open Home Chronicle timeline
4. Show one replacement alert and one room gap
5. Show "Complete Your Home" bundle with applied credit

## Definition of Done
- Recommendation and Chronicle features run without dependency on unfinished teammate screens.
- Gemini path works, fallback path works.
- Every output is strongly typed and presentation-ready.
- Demo can run fully in mock mode if network/API fails.
