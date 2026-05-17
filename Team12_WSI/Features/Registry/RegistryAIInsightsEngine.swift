//
//  RegistryAIInsightsEngine.swift
//  Team12_WSI
//
//  AI-powered analysis engine that evaluates a registry's quality,
//  balance, aesthetic harmony, budget distribution, and completeness.
//

import SwiftUI

// MARK: - Insight Models

/// Overall score tier for the registry
enum RegistryScoreTier: String {
    case exceptional = "Exceptional"
    case strong = "Well-Curated"
    case developing = "Developing"
    case needsAttention = "Needs Attention"

    var color: Color {
        switch self {
        case .exceptional: return Color(hex: "#6F8768") // sage
        case .strong: return Color(hex: "#9A8355") // gold
        case .developing: return Color(hex: "#786049")
        case .needsAttention: return Color(hex: "#B85C38")
        }
    }

    var icon: String {
        switch self {
        case .exceptional: return "star.fill"
        case .strong: return "checkmark.seal.fill"
        case .developing: return "arrow.up.right"
        case .needsAttention: return "lightbulb.fill"
        }
    }
}

/// Individual insight category
enum InsightCategory: String, CaseIterable, Identifiable {
    case overallScore = "Registry Score"
    case budget = "Budget Balance"
    case aesthetic = "Aesthetic Harmony"
    case completeness = "Collection Completeness"
    case giftability = "Giftability"
    case diversity = "Category Diversity"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .overallScore: return "sparkles"
        case .budget: return "indianrupeesign.circle"
        case .aesthetic: return "paintpalette"
        case .completeness: return "checkmark.circle"
        case .giftability: return "gift"
        case .diversity: return "square.grid.2x2"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .overallScore: return [Color(hex: "#9A8355"), Color(hex: "#C4A96A")]
        case .budget: return [Color(hex: "#6F8768"), Color(hex: "#8FAA87")]
        case .aesthetic: return [Color(hex: "#786049"), Color(hex: "#9A7B5C")]
        case .completeness: return [Color(hex: "#9A8355"), Color(hex: "#B8A06E")]
        case .giftability: return [Color(hex: "#B85C38"), Color(hex: "#D4855E")]
        case .diversity: return [Color(hex: "#5B7065"), Color(hex: "#7D9E90")]
        }
    }
}

/// A single insight result
struct RegistryInsight: Identifiable {
    let id = UUID()
    let category: InsightCategory
    let score: Double // 0.0 – 1.0
    let tier: RegistryScoreTier
    let headline: String
    let detail: String
    let suggestions: [String]

    var scorePercentage: Int { Int((score * 100).rounded()) }
}

/// Budget breakdown bucket
struct BudgetBucket: Identifiable {
    let id = UUID()
    let label: String
    let range: String
    let count: Int
    let percentage: Double
    let color: Color
}

/// Full analysis report
struct RegistryInsightsReport: Identifiable {
    let id = UUID()
    let generatedAt: Date
    let overallScore: Double
    let overallTier: RegistryScoreTier
    let headline: String
    let tagline: String
    let insights: [RegistryInsight]
    let budgetBreakdown: [BudgetBucket]
    let topStrengths: [String]
    let topSuggestions: [String]
    let collectionCoveragePercent: Double
    let priceRangeText: String
    let averagePriceText: String
    let totalValueText: String
}

// MARK: - Analysis Engine

enum RegistryAIInsightsEngine {

    /// Analyze a registry and produce a full insights report.
    static func analyze(registry: Registry) -> RegistryInsightsReport {
        let items = registry.items
        guard !items.isEmpty else {
            return emptyReport()
        }

        let budgetInsight = analyzeBudget(items: items)
        let aestheticInsight = analyzeAesthetic(items: items)
        let completenessInsight = analyzeCompleteness(items: items)
        let giftabilityInsight = analyzeGiftability(items: items)
        let diversityInsight = analyzeDiversity(items: items)

        let allInsights = [budgetInsight, aestheticInsight, completenessInsight, giftabilityInsight, diversityInsight]

        let overallScore = allInsights.map(\.score).reduce(0, +) / Double(allInsights.count)
        let overallTier = tierForScore(overallScore)

        let overallInsight = RegistryInsight(
            category: .overallScore,
            score: overallScore,
            tier: overallTier,
            headline: headlineForOverall(tier: overallTier, items: items),
            detail: detailForOverall(tier: overallTier, items: items, registry: registry),
            suggestions: []
        )

        let budgetBreakdown = buildBudgetBreakdown(items: items)

        let prices = items.map(\.price)
        let totalValue = prices.reduce(0, +)
        let avgPrice = totalValue / Double(items.count)
        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 0

        let topStrengths = allInsights
            .filter { $0.score >= 0.7 }
            .map { $0.headline }

        let topSuggestions = allInsights
            .flatMap(\.suggestions)
            .prefix(4)
            .map { $0 }

        let collectionNames = Set(items.compactMap(\.collectionName))
        let totalCollections = max(1, collectionNames.count)
        let collectionCoverage = min(1.0, Double(totalCollections) / 4.0) // 4 = ideal collection count

        return RegistryInsightsReport(
            generatedAt: Date(),
            overallScore: overallScore,
            overallTier: overallTier,
            headline: headlineForOverall(tier: overallTier, items: items),
            tagline: taglineForOverall(tier: overallTier),
            insights: [overallInsight] + allInsights,
            budgetBreakdown: budgetBreakdown,
            topStrengths: topStrengths,
            topSuggestions: topSuggestions,
            collectionCoveragePercent: collectionCoverage * 100,
            priceRangeText: "$\(Int(minPrice)) – $\(Int(maxPrice))",
            averagePriceText: "$\(Int(avgPrice))",
            totalValueText: "$\(Int(totalValue))"
        )
    }

    // MARK: - Individual Analyzers

    private static func analyzeBudget(items: [RegistryItem]) -> RegistryInsight {
        let prices = items.map(\.price)
        let avg = prices.reduce(0, +) / Double(prices.count)
        let maxPrice = prices.max() ?? 0
        let minPrice = prices.min() ?? 0
        let range = maxPrice - minPrice

        // Score based on good price distribution
        let hasLowItems = prices.contains(where: { $0 < 50 })
        let hasMidItems = prices.contains(where: { $0 >= 50 && $0 <= 200 })
        let hasHighItems = prices.contains(where: { $0 > 200 })
        let rangeCount = [hasLowItems, hasMidItems, hasHighItems].filter { $0 }.count

        var score = Double(rangeCount) / 3.0

        // Bonus for not being all expensive
        if avg < 300 { score = min(1.0, score + 0.1) }

        // Penalty if everything is the same price tier
        if range < 20 { score = max(0.2, score - 0.2) }

        let tier = tierForScore(score)

        var suggestions: [String] = []
        if !hasLowItems { suggestions.append("Add a few affordable items (under $50) so every guest can contribute.") }
        if !hasMidItems { suggestions.append("Include mid-range items ($50–$200) for balanced gifting options.") }
        if !hasHighItems { suggestions.append("Consider adding a few premium pieces to complete your home vision.") }

        let headline: String
        switch tier {
        case .exceptional: headline = "Excellent price distribution"
        case .strong: headline = "Good budget balance"
        case .developing: headline = "Budget could be more balanced"
        case .needsAttention: headline = "Budget is concentrated in one tier"
        }

        return RegistryInsight(
            category: .budget,
            score: score,
            tier: tier,
            headline: headline,
            detail: "Your registry spans $\(Int(minPrice)) to $\(Int(maxPrice)) with an average of $\(Int(avg)). \(rangeCount) of 3 price tiers are represented.",
            suggestions: suggestions
        )
    }

    private static func analyzeAesthetic(items: [RegistryItem]) -> RegistryInsight {
        let collections = Set(items.compactMap(\.collectionName))
        let hasCollections = !collections.isEmpty
        let collectionItems = items.filter { $0.collectionName != nil }.count
        let collectionRatio = Double(collectionItems) / Double(items.count)

        var score = 0.5
        if hasCollections { score += 0.2 }
        if collectionRatio > 0.5 { score += 0.15 }
        if collections.count >= 2 { score += 0.15 }

        // Bonus for items from curated sources
        let curatedCount = items.filter { $0.sourceTag != nil }.count
        if curatedCount > 0 { score = min(1.0, score + 0.1) }

        score = min(1.0, score)
        let tier = tierForScore(score)

        var suggestions: [String] = []
        if !hasCollections {
            suggestions.append("Group items into collections for a cohesive aesthetic narrative.")
        }
        if collectionRatio < 0.5 {
            suggestions.append("Assign more items to collections to strengthen visual coherence.")
        }
        if collections.count < 2 {
            suggestions.append("Create at least 2 distinct collections to show intentional style range.")
        }

        let headline: String
        switch tier {
        case .exceptional: headline = "Beautifully curated aesthetic"
        case .strong: headline = "Strong visual coherence"
        case .developing: headline = "Aesthetic story is forming"
        case .needsAttention: headline = "Items feel disconnected stylistically"
        }

        return RegistryInsight(
            category: .aesthetic,
            score: score,
            tier: tier,
            headline: headline,
            detail: hasCollections
                ? "Your \(collections.count) collection\(collections.count == 1 ? "" : "s") create a cohesive home story. \(Int(collectionRatio * 100))% of items belong to a curated set."
                : "Your items don't yet belong to named collections. Grouping creates a stronger visual identity.",
            suggestions: suggestions
        )
    }

    private static func analyzeCompleteness(items: [RegistryItem]) -> RegistryInsight {
        let totalCount = items.reduce(0) { $0 + $1.quantity }
        let collectionCount = Set(items.compactMap(\.collectionName)).count

        // Scoring heuristics
        var score = 0.3
        if totalCount >= 5 { score += 0.15 }
        if totalCount >= 10 { score += 0.15 }
        if totalCount >= 20 { score += 0.1 }
        if collectionCount >= 2 { score += 0.15 }
        if collectionCount >= 4 { score += 0.15 }
        score = min(1.0, score)

        let tier = tierForScore(score)

        var suggestions: [String] = []
        if totalCount < 10 { suggestions.append("Most ideal registries have 15–30 items. Consider adding more.") }
        if collectionCount < 3 { suggestions.append("Add items to fill at least 3 lifestyle categories for well-rounded coverage.") }

        let headline: String
        switch tier {
        case .exceptional: headline = "Comprehensive, well-rounded registry"
        case .strong: headline = "Good item coverage across categories"
        case .developing: headline = "Registry is growing — keep adding"
        case .needsAttention: headline = "Registry needs more items"
        }

        return RegistryInsight(
            category: .completeness,
            score: score,
            tier: tier,
            headline: headline,
            detail: "\(totalCount) total items across \(collectionCount) collection\(collectionCount == 1 ? "" : "s"). A balanced registry typically has 15–30 items across 3–5 lifestyle categories.",
            suggestions: suggestions
        )
    }

    private static func analyzeGiftability(items: [RegistryItem]) -> RegistryInsight {
        let prices = items.map(\.price)
        let under75 = prices.filter { $0 < 75 }.count
        let mid = prices.filter { $0 >= 75 && $0 <= 300 }.count
        let premium = prices.filter { $0 > 300 }.count

        let giftFriendlyRatio = Double(under75 + mid) / Double(items.count)

        var score = giftFriendlyRatio * 0.6
        if under75 > 0 { score += 0.15 }
        if mid > 0 { score += 0.15 }
        if premium > 0 && premium <= items.count / 2 { score += 0.1 }
        score = min(1.0, score)

        let tier = tierForScore(score)

        var suggestions: [String] = []
        if under75 == 0 { suggestions.append("Add affordable items under $75 so casual acquaintances can participate.") }
        if premium > items.count / 2 { suggestions.append("Too many premium items may deter gift-givers. Add more accessible options.") }

        let headline: String
        switch tier {
        case .exceptional: headline = "Highly giftable for all budgets"
        case .strong: headline = "Good range of gifting options"
        case .developing: headline = "Some price gaps for gift-givers"
        case .needsAttention: headline = "Most items are hard to gift"
        }

        return RegistryInsight(
            category: .giftability,
            score: score,
            tier: tier,
            headline: headline,
            detail: "\(under75) affordable items, \(mid) mid-range, \(premium) premium. A guest-friendly registry has options for every budget level.",
            suggestions: suggestions
        )
    }

    private static func analyzeDiversity(items: [RegistryItem]) -> RegistryInsight {
        let collectionNames = items.map { $0.collectionName ?? "Uncategorized" }
        let uniqueCategories = Set(collectionNames).count

        var score = min(1.0, Double(uniqueCategories) / 4.0)
        if items.count >= 5 && uniqueCategories == 1 { score = max(0.2, score - 0.2) }

        let tier = tierForScore(score)

        var suggestions: [String] = []
        if uniqueCategories < 3 { suggestions.append("Expand into more lifestyle categories like hosting, morning rituals, or outdoor dining.") }

        let headline: String
        switch tier {
        case .exceptional: headline = "Excellent lifestyle coverage"
        case .strong: headline = "Good category diversity"
        case .developing: headline = "A few more categories would help"
        case .needsAttention: headline = "Items are concentrated in one area"
        }

        return RegistryInsight(
            category: .diversity,
            score: score,
            tier: tier,
            headline: headline,
            detail: "\(uniqueCategories) distinct categor\(uniqueCategories == 1 ? "y" : "ies") represented. Aim for 3–5 lifestyle themes for a registry that tells your complete home story.",
            suggestions: suggestions
        )
    }

    // MARK: - Helpers

    private static func tierForScore(_ score: Double) -> RegistryScoreTier {
        switch score {
        case 0.85...1.0: return .exceptional
        case 0.65..<0.85: return .strong
        case 0.45..<0.65: return .developing
        default: return .needsAttention
        }
    }

    private static func buildBudgetBreakdown(items: [RegistryItem]) -> [BudgetBucket] {
        let total = Double(items.count)
        guard total > 0 else { return [] }

        let affordable = items.filter { $0.price < 50 }.count
        let mid = items.filter { $0.price >= 50 && $0.price < 200 }.count
        let premium = items.filter { $0.price >= 200 && $0.price < 500 }.count
        let luxury = items.filter { $0.price >= 500 }.count

        return [
            BudgetBucket(label: "Affordable", range: "Under $50", count: affordable, percentage: Double(affordable) / total, color: Color(hex: "#6F8768")),
            BudgetBucket(label: "Mid-Range", range: "$50 – $200", count: mid, percentage: Double(mid) / total, color: Color(hex: "#9A8355")),
            BudgetBucket(label: "Premium", range: "$200 – $500", count: premium, percentage: Double(premium) / total, color: Color(hex: "#786049")),
            BudgetBucket(label: "Luxury", range: "$500+", count: luxury, percentage: Double(luxury) / total, color: Color(hex: "#3E2723"))
        ].filter { $0.count > 0 }
    }

    private static func headlineForOverall(tier: RegistryScoreTier, items: [RegistryItem]) -> String {
        switch tier {
        case .exceptional: return "A beautifully curated registry"
        case .strong: return "Your registry is looking great"
        case .developing: return "Your registry is coming together"
        case .needsAttention: return "Let's strengthen your registry"
        }
    }

    private static func taglineForOverall(tier: RegistryScoreTier) -> String {
        switch tier {
        case .exceptional: return "Thoughtful, balanced, and ready to share."
        case .strong: return "A few tweaks to make it perfect."
        case .developing: return "Good foundation — keep building."
        case .needsAttention: return "Small changes will make a big difference."
        }
    }

    private static func detailForOverall(tier: RegistryScoreTier, items: [RegistryItem], registry: Registry) -> String {
        let totalItems = items.reduce(0) { $0 + $1.quantity }
        let collections = Set(items.compactMap(\.collectionName)).count
        return "\(registry.firstName) & \(registry.lastName)'s \(registry.event.rawValue.lowercased()) registry has \(totalItems) items across \(collections) collection\(collections == 1 ? "" : "s")."
    }

    private static func emptyReport() -> RegistryInsightsReport {
        RegistryInsightsReport(
            generatedAt: Date(),
            overallScore: 0,
            overallTier: .needsAttention,
            headline: "Your registry is empty",
            tagline: "Start adding items to get personalized insights.",
            insights: [],
            budgetBreakdown: [],
            topStrengths: [],
            topSuggestions: ["Add items from AI recommendations to get started.", "Browse essentials to build your foundation."],
            collectionCoveragePercent: 0,
            priceRangeText: "—",
            averagePriceText: "—",
            totalValueText: "$0"
        )
    }
}
