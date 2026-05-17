import Foundation

// MARK: - Deterministic Recommendation Ranker

/// Pure deterministic ranker that scores products against a user profile.
/// No network calls — runs locally and instantly.
enum DeterministicRecommendationRanker {

    // MARK: - Public API

    static func rank(
        candidates: [CatalogProduct],
        profile: UserAestheticProfile,
        context: RegistryRecommendationContext,
        weights: ScoringWeights = AURAConfiguration.defaultScoringWeights,
        maxResults: Int = AURAConfiguration.maxRecommendationCandidates
    ) -> [RankedRecommendation] {
        let scored = candidates.map { product in
            let breakdown = scoreProduct(product, profile: profile, context: context, weights: weights)
            let explanation = templateExplanation(for: product, profile: profile, breakdown: breakdown)
            let confidence = confidenceLabel(for: breakdown.finalScore)

            return RankedRecommendation(
                id: product.id,
                product: product,
                score: breakdown,
                explanation: explanation,
                confidenceLabel: confidence
            )
        }

        return scored
            .sorted { $0.score.finalScore > $1.score.finalScore }
            .prefix(maxResults)
            .map { $0 }
    }

    // MARK: - Group by Category

    static func groupByCategory(
        _ recommendations: [RankedRecommendation]
    ) -> [RegistryRecommendationSection] {
        let categoryMap = Dictionary(grouping: recommendations) { rec -> String in
            categorize(product: rec.product)
        }

        return categoryMap.map { category, recs in
            RegistryRecommendationSection(
                id: category.lowercased().replacingOccurrences(of: " ", with: "-"),
                category: category,
                title: sectionTitle(for: category),
                productIDs: recs.map(\.id)
            )
        }
        .sorted { $0.category < $1.category }
    }

    // MARK: - Scoring

    private static func scoreProduct(
        _ product: CatalogProduct,
        profile: UserAestheticProfile,
        context: RegistryRecommendationContext,
        weights: ScoringWeights
    ) -> RecommendationScoreBreakdown {
        let style = styleMatchScore(product: product, profile: profile)
        let color = colorHarmonyScore(product: product, profile: profile)
        let category = categoryGapFillScore(product: product, context: context)
        let brand = brandAffinityScore(product: product, profile: profile)
        let budget = budgetFitScore(product: product, profile: profile)
        let popularity = popularityPriorScore(product: product)

        let final = style * weights.styleMatch
            + color * weights.colorHarmony
            + category * weights.categoryGapFill
            + brand * weights.brandAffinity
            + budget * weights.budgetFit
            + popularity * weights.popularityPrior

        return RecommendationScoreBreakdown(
            styleMatch: style,
            colorHarmony: color,
            categoryGapFill: category,
            brandAffinity: brand,
            budgetFit: budget,
            popularityPrior: popularity,
            finalScore: final
        )
    }

    // MARK: - Individual Scores

    private static func styleMatchScore(product: CatalogProduct, profile: UserAestheticProfile) -> Double {
        let profileStyles = Set([profile.primaryStyle.lowercased()] + profile.secondaryStyles.map { $0.lowercased() })
        let productStyles = Set(product.styleTags.map { $0.lowercased() })
        guard !profileStyles.isEmpty else { return 0.5 }
        let overlap = profileStyles.intersection(productStyles).count
        return min(1.0, Double(overlap) / max(1, Double(min(profileStyles.count, 3))))
    }

    private static func colorHarmonyScore(product: CatalogProduct, profile: UserAestheticProfile) -> Double {
        guard !profile.dominantColorsHex.isEmpty, !product.colorTags.isEmpty else { return 0.5 }
        let profileColors = Set(profile.dominantColorsHex.map { $0.lowercased() })
        let productColors = Set(product.colorTags.map { $0.lowercased() })
        let overlap = profileColors.intersection(productColors).count
        return overlap > 0 ? min(1.0, Double(overlap) * 0.5 + 0.3) : 0.25
    }

    private static func categoryGapFillScore(product: CatalogProduct, context: RegistryRecommendationContext) -> Double {
        let prioritized = Set(context.prioritizedCategories.map { $0.lowercased() })
        let productCats = Set(product.categoryTags.map { $0.lowercased() })
        let productType = product.productType.lowercased()

        if prioritized.contains(productType) || !prioritized.intersection(productCats).isEmpty {
            return 1.0
        }

        // Partial match via room
        let profileRooms = Set(context.profile.roomPriorities)
        let productRooms = Set(product.roomTags)
        if !profileRooms.intersection(productRooms).isEmpty {
            return 0.6
        }

        return 0.2
    }

    private static func brandAffinityScore(product: CatalogProduct, profile: UserAestheticProfile) -> Double {
        if let affinity = profile.brandAffinity.first(where: { $0.brand == product.brand }) {
            return affinity.weight
        }
        // Default moderate affinity for known brands
        return product.brand != .unknown ? 0.4 : 0.1
    }

    private static func budgetFitScore(product: CatalogProduct, profile: UserAestheticProfile) -> Double {
        let price = product.effectivePrice
        switch profile.budgetBand {
        case .value:
            if price <= 50 { return 1.0 }
            if price <= 100 { return 0.7 }
            if price <= 200 { return 0.3 }
            return 0.1
        case .mid:
            if price >= 50 && price <= 150 { return 1.0 }
            if price <= 250 { return 0.6 }
            return 0.2
        case .premium:
            if price >= 150 && price <= 300 { return 1.0 }
            if price >= 100 && price <= 500 { return 0.7 }
            return 0.3
        case .luxury:
            if price >= 300 { return 1.0 }
            if price >= 150 { return 0.7 }
            return 0.3
        }
    }

    private static func popularityPriorScore(product: CatalogProduct) -> Double {
        // Mock popularity based on brand + gift-wrappability as proxy
        var score = 0.5
        if product.isGiftWrappable { score += 0.15 }
        switch product.brand {
        case .williamsSonoma: score += 0.2
        case .potteryBarn: score += 0.15
        case .westElm: score += 0.15
        default: break
        }
        return min(1.0, score)
    }

    // MARK: - Template Explanations

    private static func templateExplanation(
        for product: CatalogProduct,
        profile: UserAestheticProfile,
        breakdown: RecommendationScoreBreakdown
    ) -> String {
        // Pick the strongest signal to narrate
        let signals: [(Double, String)] = [
            (breakdown.styleMatch, styleNarrative(product: product, profile: profile)),
            (breakdown.categoryGapFill, categoryNarrative(product: product)),
            (breakdown.budgetFit, "Aligns well with your preferred price range."),
            (breakdown.brandAffinity, brandNarrative(product: product)),
            (breakdown.colorHarmony, "Harmonizes with your chosen color palette.")
        ]

        if let best = signals.max(by: { $0.0 < $1.0 }) {
            return best.1
        }
        return "A curated selection for your home."
    }

    private static func styleNarrative(product: CatalogProduct, profile: UserAestheticProfile) -> String {
        let style = profile.primaryStyle
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
        return "Complements your \(style.lowercased()) aesthetic beautifully."
    }

    private static func categoryNarrative(product: CatalogProduct) -> String {
        let type = product.productType.replacingOccurrences(of: "-", with: " ")
        return "Fills an essential \(type.lowercased()) need in your registry."
    }

    private static func brandNarrative(product: CatalogProduct) -> String {
        let brandName: String
        switch product.brand {
        case .williamsSonoma: brandName = "Williams Sonoma"
        case .potteryBarn: brandName = "Pottery Barn"
        case .westElm: brandName = "West Elm"
        case .rejuvenation: brandName = "Rejuvenation"
        case .markAndGraham: brandName = "Mark & Graham"
        case .greenRow: brandName = "GreenRow"
        case .unknown: brandName = "this brand"
        }
        return "From \(brandName), a trusted name in quality home goods."
    }

    // MARK: - Confidence Labels

    private static func confidenceLabel(for score: Double) -> String {
        switch score {
        case 0.7...: return "High"
        case 0.45...: return "Medium"
        default: return "Suggested"
        }
    }

    // MARK: - Category Classification

    private static func categorize(product: CatalogProduct) -> String {
        let corpus = (product.categoryTags + [product.productType]).joined(separator: " ").lowercased()

        if corpus.contains("cook") || corpus.contains("pan") || corpus.contains("pot")
            || corpus.contains("knife") || corpus.contains("cutlery") || corpus.contains("bake") {
            return "Cooking"
        }
        if corpus.contains("glass") || corpus.contains("wine") || corpus.contains("bar")
            || corpus.contains("carafe") || corpus.contains("serving") || corpus.contains("platter") {
            return "Hosting"
        }
        if corpus.contains("plate") || corpus.contains("bowl") || corpus.contains("dinner")
            || corpus.contains("table") || corpus.contains("flatware") || corpus.contains("dining") {
            return "Shared Dining"
        }
        if corpus.contains("coffee") || corpus.contains("tea") || corpus.contains("mug")
            || corpus.contains("kettle") || corpus.contains("espresso") {
            return "Morning Rituals"
        }
        if corpus.contains("bed") || corpus.contains("linen") || corpus.contains("towel")
            || corpus.contains("bath") || corpus.contains("pillow") {
            return "Comfort & Living"
        }
        if corpus.contains("decor") || corpus.contains("candle") || corpus.contains("vase")
            || corpus.contains("frame") {
            return "Home Accents"
        }
        if corpus.contains("storage") || corpus.contains("organiz") || corpus.contains("shelf") {
            return "Organization"
        }

        return "Curated Picks"
    }

    private static func sectionTitle(for category: String) -> String {
        switch category {
        case "Cooking": return "For Your Kitchen"
        case "Hosting": return "For Entertaining"
        case "Shared Dining": return "For the Table"
        case "Morning Rituals": return "For Slow Mornings"
        case "Comfort & Living": return "For Comfort"
        case "Home Accents": return "Finishing Touches"
        case "Organization": return "Thoughtful Storage"
        default: return "Curated for You"
        }
    }
}
