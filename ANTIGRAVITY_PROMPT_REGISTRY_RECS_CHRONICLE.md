# Prompt for Antigravity: Registry Recommendations + Home Chronicle (Gemini)

Use this prompt as the implementation brief.

## Role
You are the Antigravity engineer for Team12_WSI iOS app.
Your job is to implement recommendation intelligence and Home Chronicle in a way that is hackathon-presentable, robust, and non-breaking for existing screens.

## Critical Corrections
- Cart UI is **not finalized**. Do not assume cart contracts are frozen.
- Registry onboarding should be reduced in questions and used to generate AI recommendations.
- AI recommendations should **not auto-add** items to registry.
- Users should manually choose recommended items to add.
- Registry and recommendation state must be persistent across app restarts.

## Existing Codebase Context
- App root: `Team12_WSI/`
- Registry create flow: `Team12_WSI/Features/Registry/Create/CreateRegistryView.swift`
- Registry repository: `Team12_WSI/Repositories/RegistryRepository.swift`
- Product DTO: `Team12_WSI/Features/Home/ProductItemDTO.swift`
- Existing intelligence models:
  - `Team12_WSI/Features/Intelligence/AURARecommendationModels.swift`
  - `Team12_WSI/Features/Intelligence/AURAHomeChronicleModels.swift`
  - `Team12_WSI/Features/Intelligence/AURARegistryIntelligenceModels.swift`

## Product Direction
Implement a new registry intelligence flow:
1. User creates registry and answers a reduced set of onboarding questions.
2. User may skip optional questions.
3. System normalizes answers into a recommendation context.
4. Gemini + deterministic scoring returns category-wise recommendations (cooking, hosting, shared dining, etc.).
5. User manually selects products to add into registry.
6. User can view registry and changes persist.

## UX Flow Requirements

### 1) Reduce Questions
Keep only high-signal questions:
- `homeVision` (required)
- `lifestyleMoments` (optional)
- `productCategories` (required)
- `budgetPreference` (required)
- `visualStyles` (optional)

Drop or defer the rest from the primary flow.

### 2) Skip-Friendly Behavior
- Optional question screens must have `Skip` action.
- Skipped answers must be captured explicitly in payload, not silently omitted.
- Recommendation engine must still produce sensible output with partial answers.

### 3) Recommendation Review Screen
After onboarding, show “AI Curated Picks”:
- Grouped by category sections
- Each card shows: name, brand, price, short rationale, confidence label
- CTA: `Add to Registry`
- Secondary action: `Regenerate` or `Refine`

### 4) Registry Persistence
- Newly added recommended items are persisted.
- Registry and its items survive app relaunch.
- Recommendation snapshots should also be persisted for demo continuity.

## Data Model Requirements
Use and extend current intelligence models without breaking current screens.

### Product model quality
Recommendations must use dependable normalized product metadata:
- `brand`
- `categoryTags`
- `styleTags`
- `colorTags`
- `materialTags`
- `price`
- `availability`
- `isGiftWrappable`

Never let LLM invent products. LLM can only rank IDs from provided candidate set.

### Questionnaire + context models
Use:
- `RegistryQuestionnairePayload`
- `QuestionnaireSelection`
- `RegistryRecommendationContext`
- `RegistryRecommendationRequest/Response`

`QuestionnaireSelection` must store:
- key
- answered/skipped state
- normalized values

## Persistence Strategy (must be implemented)
Introduce local persistence with versioned storage:
- `RegistryRepository` currently stores in memory only; add persistence-backed variant.
- Store:
  - current registry
  - registry items
  - intelligence snapshot (`RegistryIntelligenceSnapshot`)
  - optional chronicle seed history

Recommended implementation:
- `RegistryPersistenceStore` (JSON file in app documents directory) OR `UserDefaults` with encoded payloads.
- Version the payload schema for safe evolution.

## Recommendation Engine Strategy

### Step A: Deterministic ranker (first pass)
Compute score from:
- style match
- category fit / gap fill
- budget fit
- brand affinity
- color harmony
- popularity prior (mock seed)

### Step B: Gemini rerank/explain (second pass)
Use `generative-ai-swift`:
- Input only top K deterministic candidates (K <= 15)
- Ask for strict JSON:
  - ranked IDs
  - rationale per ID
  - confidence label
- Enforce ID whitelist validation.

### Fallback
If Gemini fails/invalid JSON:
- return deterministic ranking
- attach template rationales

## Home Chronicle Requirements
Build the same way as recommendations: deterministic first, AI enrichment optional.

Must include:
- timeline grouped by year
- replacement alerts (age vs lifespan)
- room/category gaps
- complete-your-home bundle with credit application

Use models in:
- `AURAHomeChronicleModels.swift`

## Non-Breaking Rules
- Do not break existing `ProductItem`, `CartItem`, `RegistryItem` UI contracts.
- Additive changes only for shared models where possible.
- Keep existing tabs/navigation behavior intact.
- New recommendation flow should slot into registry journey, not alter unrelated screens.

## Implementation Tasks

1. Create a new service layer:
- `AURAIntelligenceService`
- `GeminiRecommendationClient`
- `DeterministicRecommendationRanker`

2. Build questionnaire reducer:
- Convert UI selections -> `RegistryQuestionnairePayload`
- Normalize text values to stable tags

3. Build recommendation screen VM:
- load candidates
- score + rerank
- expose sections and add-to-registry actions

4. Persistence:
- save/load registry
- save/load intelligence snapshot

5. Integrate with registry flow:
- after create + questions -> show recommendations
- from recommendation screen -> add selected items
- then navigate to registry detail/list

6. Home Chronicle module:
- timeline
- replacement alerts
- gap detection
- complete bundle

## Acceptance Criteria
- User can complete reduced onboarding, skip optional questions, and still receive recommendations.
- Recommendations are grouped by categories and are manually addable.
- Added items appear in registry screen immediately.
- Relaunching app restores registry + recommendations.
- No product hallucination from Gemini.
- App remains stable for existing home/cart/registry navigation.

## Demo Script
1. Create registry with reduced questions, skip at least one optional step.
2. Show AI recommended sections (cooking, hosting, shared dining).
3. Add 2-3 items manually to registry.
4. Open registry and confirm items are present.
5. Relaunch app and confirm persistence.
6. Open Home Chronicle and show replacement + gap insight.

## Engineering Notes
- Keep output tone premium and concise in rationale copy.
- Keep recommendation card text short for readability.
- Ensure all async calls have loading and retry states.
- Include a `mock mode` toggle so demo works even if Gemini/network fails.
