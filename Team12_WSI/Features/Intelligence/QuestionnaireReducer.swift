import Foundation
import SwiftUI

// MARK: - Questionnaire Reducer

/// Maps raw UI selections from the GiftDNA flow into structured AURA models.
/// Handles normalization, skip states, and profile derivation.
enum QuestionnaireReducer {

    // MARK: - Build Payload from UI State

    static func buildPayload(
        registryID: UUID,
        moodboardVibe: String,
        moodboardPhotoCount: Int,
        homeType: String?,
        hobbies: Set<String>,
        hobbiesSkipped: Bool,
        productCategories: Set<String>,
        budgetPreference: String?,
        homeVision: String? = nil
    ) -> RegistryQuestionnairePayload {
        var selections: [QuestionnaireSelection] = []

        // moodboardVibe — optional text but highly recommended
        let normalizedVibeTags = extractMoodboardTags(from: moodboardVibe)
        if !normalizedVibeTags.isEmpty {
            selections.append(.answered(.moodboardVibe, values: normalizedVibeTags))
        } else {
            selections.append(.skipped(.moodboardVibe))
        }

        // homeVision — optional override from choice cards
        if let homeVision {
            selections.append(.answered(.homeVision, values: [normalizeTag(homeVision)]))
        }

        // homeType — required
        if let homeType {
            selections.append(.answered(.homeType, values: [normalizeTag(homeType)]))
        }

        // hobbies — optional
        if hobbiesSkipped {
            selections.append(.skipped(.hobbies))
        } else if !hobbies.isEmpty {
            selections.append(.answered(.hobbies, values: hobbies.map { normalizeTag($0) }))
        } else {
            selections.append(.skipped(.hobbies))
        }

        // productCategories — required
        if !productCategories.isEmpty {
            selections.append(.answered(.productCategories, values: productCategories.map { normalizeTag($0) }))
        }

        // budgetPreference — required
        if let budget = budgetPreference {
            selections.append(.answered(.budgetPreference, values: [normalizeTag(budget)]))
        }

        return RegistryQuestionnairePayload(
            registryID: registryID,
            createdAt: Date(),
            moodboardPhotoCount: moodboardPhotoCount,
            selections: selections
        )
    }

    // MARK: - Build Recommendation Context

    static func buildContext(from payload: RegistryQuestionnairePayload) -> RegistryRecommendationContext {
        let profile = deriveProfile(from: payload)
        let prioritized = payload.selections
            .first { $0.key == .productCategories && $0.state == .answered }?
            .values ?? []

        let skippedKeys = payload.selections
            .filter { $0.state == .skipped }
            .map(\.key)

        let normalizedTags = payload.selections
            .filter { $0.state == .answered }
            .flatMap(\.values)

        return RegistryRecommendationContext(
            registryID: payload.registryID,
            profile: profile,
            prioritizedCategories: prioritized,
            missingAnswerKeys: skippedKeys,
            normalizedTags: normalizedTags
        )
    }

    // MARK: - Profile Derivation

    static func deriveProfile(from payload: RegistryQuestionnairePayload) -> UserAestheticProfile {
        let selectionMap = Dictionary(
            uniqueKeysWithValues: payload.selections.map { ($0.key, $0) }
        )

        // Primary style from moodboard vibe or homeVision fallback
        let primaryStyle = selectionMap[.moodboardVibe]?.values.first
            ?? selectionMap[.homeVision]?.values.first
            ?? "warm-cozy"

        // Secondary styles from moodboard tags and home type (or defaults)
        let secondaryStyles: [String]
        if let vibe = selectionMap[.moodboardVibe], vibe.state == .answered {
            let extra = selectionMap[.homeType]?.values ?? []
            secondaryStyles = Array(Set(vibe.values + extra)).prefix(3).map { $0 }
        } else {
            secondaryStyles = defaultSecondaryStyles(for: primaryStyle)
        }

        // Dominant colors inferred from style
        let colors = inferColors(primary: primaryStyle, secondary: secondaryStyles)

        // Room priorities from product categories and home type
        let roomPriorities = inferRoomPriorities(from: selectionMap[.productCategories]?.values ?? [])

        // Budget band
        let budgetBand = inferBudgetBand(from: selectionMap[.budgetPreference]?.values.first)

        // Brand affinity defaults influenced by home type and hobbies
        let brandAffinity = defaultBrandAffinity(
            for: primaryStyle,
            homeType: selectionMap[.homeType]?.values.first,
            hobbies: selectionMap[.hobbies]?.values ?? []
        )

        return UserAestheticProfile(
            primaryStyle: primaryStyle,
            secondaryStyles: secondaryStyles,
            dominantColorsHex: colors,
            roomPriorities: roomPriorities,
            budgetBand: budgetBand,
            brandAffinity: brandAffinity
        )
    }

    // MARK: - Helpers

    static func normalizeTag(_ raw: String) -> String {
        raw.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " & ", with: "-")
            .replacingOccurrences(of: "&", with: "-")
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "--", with: "-")
    }

    static func extractMoodboardTags(from text: String) -> [String] {
        let normalized = normalizeTag(text)
        guard !normalized.isEmpty else { return [] }

        let mapping: [String: [String]] = [
            "warm": ["warm-cozy", "warm-natural"],
            "cozy": ["warm-cozy"],
            "subtle": ["timeless", "calm-restorative"],
            "hall": ["living-room", "hosting"],
            "modular": ["modern-minimal"],
            "kitchen": ["culinary", "kitchen"],
            "cutlery": ["cutlery", "shared-dining"],
            "japandi": ["japandi-adjacent", "organic-modern"],
            "hosting": ["social-hosting-focused", "hosting"],
            "minimal": ["modern-minimal"],
            "quiet": ["calm-restorative"],
            "coastal": ["coastal-calm"]
        ]

        var tags = Set<String>()
        let words = normalized.split(separator: "-").map(String.init)
        for word in words {
            if let mapped = mapping[word] {
                tags.formUnion(mapped)
            } else if word.count > 2 {
                tags.insert(word)
            }
        }
        return Array(tags)
    }

    private static func defaultSecondaryStyles(for primary: String) -> [String] {
        switch primary {
        case "warm-cozy": return ["heritage", "warm-natural"]
        case "modern-minimal": return ["japandi-adjacent", "modern"]
        case "social-hosting-focused": return ["culinary-classic", "timeless"]
        case "calm-restorative": return ["organic-modern", "earthy"]
        case "creative-expressive": return ["vintage-modern", "personalized"]
        case "functional-everyday-living": return ["classic", "culinary"]
        default: return ["timeless", "classic"]
        }
    }

    private static func inferColors(primary: String, secondary: [String]) -> [String] {
        var colors: [String] = []

        switch primary {
        case "warm-cozy": colors += ["#8B7355", "#D4A574", "#F5E6D3"]
        case "modern-minimal": colors += ["#2C2C2C", "#FFFFFF", "#E8E8E8"]
        case "social-hosting-focused": colors += ["#1A2744", "#C9A84C", "#F8F4EE"]
        case "calm-restorative": colors += ["#7A8B6F", "#E8DCC8", "#F5F0EB"]
        case "creative-expressive": colors += ["#B8860B", "#5C4033", "#DEB887"]
        case "functional-everyday-living": colors += ["#696969", "#F5F5DC", "#8FBC8F"]
        default: colors += ["#1A2744", "#F8F4EE", "#C9A84C"]
        }

        return colors
    }

    private static func inferRoomPriorities(from categories: [String]) -> [AURARoomType] {
        var rooms: [AURARoomType] = []

        for cat in categories {
            let lower = cat.lowercased()
            if lower.contains("cook") || lower.contains("bake") || lower.contains("kitchen") || lower.contains("appliance") {
                rooms.append(.kitchen)
            }
            if lower.contains("dinner") || lower.contains("serve") || lower.contains("glass") || lower.contains("bar") {
                rooms.append(.dining)
            }
            if lower.contains("bed") || lower.contains("bath") {
                rooms.append(.bedroom)
                rooms.append(.bathroom)
            }
            if lower.contains("coffee") || lower.contains("tea") {
                rooms.append(.kitchen)
            }
            if lower.contains("decor") {
                rooms.append(.living)
            }
            if lower.contains("storage") || lower.contains("organiz") {
                rooms.append(.multiRoom)
            }
        }

        // Deduplicate while preserving order
        var seen = Set<AURARoomType>()
        return rooms.filter { seen.insert($0).inserted }
    }

    private static func inferBudgetBand(from raw: String?) -> AURABudgetBand {
        guard let raw else { return .mid }
        let lower = raw.lowercased()
        if lower.contains("under") || lower.contains("$50") && !lower.contains("150") {
            return .value
        }
        if lower.contains("150") && !lower.contains("300") {
            return .mid
        }
        if lower.contains("300") || lower.contains("$150-to-$300") {
            return .premium
        }
        if lower.contains("investment") {
            return .luxury
        }
        return .mid
    }

    private static func defaultBrandAffinity(
        for style: String,
        homeType: String?,
        hobbies: [String]
    ) -> [BrandAffinity] {
        let normalizedHomeType = homeType ?? ""
        let hobbyText = hobbies.joined(separator: " ")

        if normalizedHomeType.contains("apartment") || style.contains("modern") {
            return [
                BrandAffinity(brand: .westElm, weight: 0.9),
                BrandAffinity(brand: .williamsSonoma, weight: 0.7),
                BrandAffinity(brand: .rejuvenation, weight: 0.55)
            ]
        }

        if hobbyText.contains("hosting") || hobbyText.contains("cooking") || style.contains("culinary") {
            return [
                BrandAffinity(brand: .williamsSonoma, weight: 0.92),
                BrandAffinity(brand: .potteryBarn, weight: 0.62),
                BrandAffinity(brand: .markAndGraham, weight: 0.48)
            ]
        }

        switch style {
        case "warm-cozy":
            return [
                BrandAffinity(brand: .williamsSonoma, weight: 0.8),
                BrandAffinity(brand: .potteryBarn, weight: 0.7),
                BrandAffinity(brand: .rejuvenation, weight: 0.5)
            ]
        case "modern-minimal":
            return [
                BrandAffinity(brand: .westElm, weight: 0.9),
                BrandAffinity(brand: .rejuvenation, weight: 0.6),
                BrandAffinity(brand: .greenRow, weight: 0.5)
            ]
        case "social-hosting-focused":
            return [
                BrandAffinity(brand: .williamsSonoma, weight: 0.9),
                BrandAffinity(brand: .potteryBarn, weight: 0.6),
                BrandAffinity(brand: .markAndGraham, weight: 0.5)
            ]
        default:
            return [
                BrandAffinity(brand: .williamsSonoma, weight: 0.7),
                BrandAffinity(brand: .potteryBarn, weight: 0.5),
                BrandAffinity(brand: .westElm, weight: 0.4)
            ]
        }
    }
}
