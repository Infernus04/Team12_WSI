// MoodboardStyleAnalyzer.swift
// Team12_WSI — Structured style analysis + Gemini AI + weighted product scoring + MMR diversity

import Foundation
import SwiftUI
import CryptoKit
import GoogleGenerativeAI

// MARK: - Style Profile

struct MoodboardStyleProfile {
    let styleTags: [String]
    let moodTags: [String]
    let materialTags: [String]
    let colorPalette: [String]
    let roomTags: [String]
    let confidence: Double

    // Identity display
    let identityName: String
    let identityDescription: String
    let swatches: [Color]
    let warmth: Double
    let modern: Double
    let minimalist: Double

    // Cache key
    let inputFingerprint: String
}

// MARK: - Scored Product

struct ScoredProduct: Identifiable {
    let product: ProductItem
    let score: Double
    let reasons: [String]

    var id: String { product.id }
}

// MARK: - Analyzer

struct MoodboardStyleAnalyzer {

    // MARK: - Main Entry Point

    static func analyze(
        images: [UIImage],
        vibeText: String,
        allProducts: [ProductItem]
    ) async -> (MoodboardStyleProfile, [ScoredProduct]) {

        // 1) Extract color tokens from images (fast local)
        var colorTokens: [String] = []
        for image in images {
            if let color = HomeAIPersonalizationEngine.dominantColor(from: image) {
                let token = HomeAIPersonalizationEngine.classifyColor(color)
                colorTokens.append(token)
            }
        }

        // 2) Tokenize text
        let textKeywords = HomeAIPersonalizationEngine.tokenize(vibeText)

        // 3) Try Gemini AI analysis first, fallback to local
        let profile: MoodboardStyleProfile
        let aiResult = await tryGeminiAnalysis(images: images, vibeText: vibeText, colorTokens: colorTokens)

        if let aiProfile = aiResult {
            print("━━━ MoodboardStyleAnalyzer: Using Gemini AI analysis ━━━")
            profile = aiProfile
        } else {
            print("━━━ MoodboardStyleAnalyzer: Using local analysis fallback ━━━")
            profile = buildLocalProfile(colorTokens: colorTokens, textKeywords: textKeywords, vibeText: vibeText, imageCount: images.count)
        }

        // 4) Score products with weighted multi-signal ranking
        let scored = scoreProducts(allProducts, profile: profile, textKeywords: textKeywords)

        // 5) MMR diversity rerank
        let diversified = diversityRerank(scored, topN: profile.confidence < 0.5 ? 12 : 10)

        // 6) Debug log
        logAnalysis(profile: profile, topProducts: diversified)

        return (profile, diversified)
    }

    // MARK: - Gemini AI Analysis

    private static func tryGeminiAnalysis(
        images: [UIImage],
        vibeText: String,
        colorTokens: [String]
    ) async -> MoodboardStyleProfile? {
        let apiKey = AppConstants.API.geminiAPIKey
        guard !apiKey.isEmpty else { return nil }

        do {
            let model = GenerativeModel(
                name: "gemini-2.0-flash",
                apiKey: apiKey
            )

            // Describe image analysis in text (avoids SDK multimodal API issues)
            let imageAnalysis: String
            if images.isEmpty {
                imageAnalysis = "No images were provided."
            } else {
                let colorSummary = colorTokens.isEmpty ? "could not extract colors" : colorTokens.joined(separator: ", ")
                imageAnalysis = "User uploaded \(images.count) inspiration image(s). Dominant color analysis detected: \(colorSummary) tones."
            }

            let prompt = """
            You are an expert interior design style analyst for Williams-Sonoma luxury home products.

            \(imageAnalysis)

            User's vibe description: "\(vibeText.isEmpty ? "No text provided — analyze based on image colors only" : vibeText)"

            Based on this information, create a personalized interior design style profile.

            Respond ONLY with valid JSON (no markdown, no backticks, no extra text):
            {
              "identityName": "A creative 2-4 word name for their aesthetic identity",
              "identityDescription": "A 1-2 sentence poetic description of their design personality",
              "styleTags": ["tag1", "tag2"],
              "moodTags": ["tag1", "tag2"],
              "materialTags": ["tag1", "tag2"],
              "roomTags": ["tag1", "tag2"],
              "warmth": 0.7,
              "modern": 0.6,
              "minimalist": 0.5,
              "swatchHexColors": ["#hex1", "#hex2", "#hex3", "#hex4"]
            }

            Rules:
            - identityName: Unique and evocative, like "Sunlit Coastal Haven" or "Refined Earthy Warmth" — never generic
            - identityDescription: Poetic and personal, describing their home aesthetic personality
            - styleTags: 2-4 from [organic-modern, coastal, scandinavian, minimalist, industrial, parisian, bohemian, rustic, contemporary, traditional, mid-century, japandi]
            - moodTags: 2-3 from [warm, cool, intimate, dramatic, serene, energetic, luxurious, cozy, refined]
            - materialTags: 2-4 from [linen, ceramic, wood, brass, copper, glass, marble, cotton, leather, rattan, metal, stone]
            - roomTags: 1-2 from [kitchen, dining, living, bedroom, bathroom, outdoor]
            - warmth/modern/minimalist: floats between 0.0 and 1.0, reflecting the user's style
            - swatchHexColors: exactly 4 hex color strings that represent their aesthetic palette
            - The analysis MUST be different for different inputs — truly personalize it
            """

            let response = try await model.generateContent(prompt)
            guard let text = response.text else { return nil }

            // Clean response — strip any markdown formatting
            let cleaned = text
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let data = cleaned.data(using: .utf8) else { return nil }
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }

            // Parse JSON
            let identityName = json["identityName"] as? String ?? "Your Unique Style"
            let identityDescription = json["identityDescription"] as? String ?? "A personalized aesthetic crafted from your inspirations."
            let styleTags = json["styleTags"] as? [String] ?? []
            let moodTags = json["moodTags"] as? [String] ?? []
            let materialTags = json["materialTags"] as? [String] ?? []
            let roomTags = json["roomTags"] as? [String] ?? []
            let warmth = json["warmth"] as? Double ?? 0.5
            let modern = json["modern"] as? Double ?? 0.5
            let minimalist = json["minimalist"] as? Double ?? 0.5
            let swatchHexes = json["swatchHexColors"] as? [String] ?? ["#C4A882", "#8B6F47", "#F5F0E8", "#D4B896"]

            let swatches = swatchHexes.map { Color(hex: $0) }
            let fingerprint = buildFingerprint(vibeText: vibeText, colorTokens: colorTokens)
            let confidence = min(0.6 + Double(images.count) * 0.08 + (vibeText.isEmpty ? 0 : 0.15), 1.0)

            return MoodboardStyleProfile(
                styleTags: styleTags,
                moodTags: moodTags,
                materialTags: materialTags,
                colorPalette: colorTokens,
                roomTags: roomTags,
                confidence: confidence,
                identityName: identityName,
                identityDescription: identityDescription,
                swatches: swatches,
                warmth: warmth,
                modern: modern,
                minimalist: minimalist,
                inputFingerprint: fingerprint
            )
        } catch {
            print("Gemini moodboard analysis error: \(error)")
            return nil
        }
    }

    // MARK: - Local Fallback Analysis

    private static func buildLocalProfile(
        colorTokens: [String],
        textKeywords: [String],
        vibeText: String,
        imageCount: Int
    ) -> MoodboardStyleProfile {
        let styleTags = extractStyleTags(from: textKeywords)
        let moodTags = extractMoodTags(from: textKeywords)
        let materialTags = extractMaterialTags(from: textKeywords)
        let roomTags = extractRoomTags(from: textKeywords)

        // ── Dynamic Identity Name ──
        // Build from detected tags, not hardcoded
        let identityName = buildDynamicIdentityName(
            styleTags: styleTags, moodTags: moodTags,
            materialTags: materialTags, colorTokens: colorTokens,
            textKeywords: textKeywords
        )

        // ── Dynamic Description ──
        let identityDescription = buildDynamicDescription(
            styleTags: styleTags, moodTags: moodTags,
            materialTags: materialTags, roomTags: roomTags
        )

        // ── Dynamic Swatches ──
        let swatches = buildDynamicSwatches(colorTokens: colorTokens, moodTags: moodTags)

        // ── Dynamic Scores ──
        let warmth = computeWarmthScore(colorTokens: colorTokens, moodTags: moodTags, textKeywords: textKeywords)
        let modern = computeModernScore(styleTags: styleTags, textKeywords: textKeywords)
        let minimalist = computeMinimalistScore(styleTags: styleTags, textKeywords: textKeywords)

        let confidence = computeConfidence(
            imageCount: imageCount,
            textLength: vibeText.count,
            tagCount: styleTags.count + materialTags.count + moodTags.count
        )
        let fingerprint = buildFingerprint(vibeText: vibeText, colorTokens: colorTokens)

        return MoodboardStyleProfile(
            styleTags: styleTags,
            moodTags: moodTags,
            materialTags: materialTags,
            colorPalette: colorTokens,
            roomTags: roomTags,
            confidence: confidence,
            identityName: identityName,
            identityDescription: identityDescription,
            swatches: swatches,
            warmth: warmth,
            modern: modern,
            minimalist: minimalist,
            inputFingerprint: fingerprint
        )
    }

    // MARK: - Dynamic Identity Builders

    private static func buildDynamicIdentityName(
        styleTags: [String], moodTags: [String],
        materialTags: [String], colorTokens: [String],
        textKeywords: [String]
    ) -> String {
        // Adjective from mood or color
        let adjectives: [String: String] = [
            "warm": "Sunlit", "cool": "Serene", "intimate": "Curated",
            "dramatic": "Bold", "serene": "Tranquil", "energetic": "Vibrant",
            "luxurious": "Opulent", "cozy": "Gathered", "refined": "Polished"
        ]
        let colorAdj: [String: String] = [
            "warm": "Golden", "cool": "Silvered", "dark": "Twilight", "neutral": "Ivory"
        ]

        // Noun from style
        let styleNouns: [String: String] = [
            "organic-modern": "Naturalism", "coastal": "Shoreline",
            "scandinavian": "Stillness", "minimalist": "Clarity",
            "industrial": "Foundry", "parisian": "Atelier",
            "bohemian": "Wanderlust", "rustic": "Hearth",
            "contemporary": "Edge", "traditional": "Heritage",
            "mid-century": "Revival", "japandi": "Harmony"
        ]

        // Material qualifier
        let matQual: [String: String] = [
            "linen": "& Linen", "ceramic": "in Clay", "wood": "& Oak",
            "brass": "& Brass", "glass": "& Glass", "marble": "in Stone",
            "metal": "& Steel", "leather": "& Hide", "rattan": "& Rattan",
            "copper": "& Copper", "cotton": "& Cotton", "stone": "in Stone"
        ]

        let adj = moodTags.compactMap({ adjectives[$0] }).first
            ?? colorTokens.compactMap({ colorAdj[$0] }).first
            ?? "Refined"
        let noun = styleTags.compactMap({ styleNouns[$0] }).first ?? "Living"
        let qualifier = materialTags.compactMap({ matQual[$0] }).first ?? ""

        let name = "\(adj) \(noun) \(qualifier)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Your Curated Aesthetic" : name
    }

    private static func buildDynamicDescription(
        styleTags: [String], moodTags: [String],
        materialTags: [String], roomTags: [String]
    ) -> String {
        let styleDesc: [String: String] = [
            "organic-modern": "grounded in natural materials and clean forms",
            "coastal": "inspired by oceanic calm and sunlit spaces",
            "scandinavian": "rooted in functional beauty and quiet restraint",
            "minimalist": "defined by intentional simplicity and curated objects",
            "industrial": "drawn to raw textures and architectural honesty",
            "parisian": "layered with eclectic charm and refined elegance",
            "bohemian": "alive with global textures and collected warmth",
            "rustic": "anchored in weathered authenticity and countryside charm",
            "contemporary": "sharpened by sleek lines and current sensibilities",
            "traditional": "enriched by timeless patterns and classic grace"
        ]
        let moodDesc: [String: String] = [
            "warm": "warmth radiates through every detail",
            "cool": "a crisp clarity brings each piece into focus",
            "intimate": "personal touches create sanctuary",
            "dramatic": "bold contrasts command attention",
            "serene": "tranquility flows through the space",
            "luxurious": "opulence meets purposeful design"
        ]

        let style = styleTags.compactMap({ styleDesc[$0] }).first ?? "attuned to beauty and function"
        let mood = moodTags.compactMap({ moodDesc[$0] }).first ?? "your space tells your story"

        let materials = materialTags.prefix(2).joined(separator: " and ")
        let matPhrase = materials.isEmpty ? "" : " With \(materials) as your foundation,"

        return "Your aesthetic is \(style).\(matPhrase) \(mood.prefix(1).uppercased() + mood.dropFirst())."
    }

    private static func buildDynamicSwatches(colorTokens: [String], moodTags: [String]) -> [Color] {
        let warmPalette = [Color(hex: "#C4A882"), Color(hex: "#8B6F47"), Color(hex: "#F5F0E8"), Color(hex: "#D4B896")]
        let coolPalette = [Color(hex: "#B8D4E3"), Color(hex: "#7BA7BC"), Color(hex: "#F5F9FC"), Color(hex: "#94B8C9")]
        let darkPalette = [Color(hex: "#2C2C2C"), Color(hex: "#5C5C5C"), Color(hex: "#B5A68B"), Color(hex: "#1A1A1A")]
        let neutralPalette = [Color(hex: "#F2EFEA"), Color(hex: "#C8C0B4"), Color(hex: "#8C8278"), Color(hex: "#3C3530")]
        let dramaticPalette = [Color(hex: "#8B2635"), Color(hex: "#C4A882"), Color(hex: "#2C2416"), Color(hex: "#F0E6D0")]
        let serenePalette = [Color(hex: "#D4E6D9"), Color(hex: "#A8C5B2"), Color(hex: "#F7FAF8"), Color(hex: "#6B9B7D")]

        if moodTags.contains("dramatic") { return dramaticPalette }
        if moodTags.contains("serene") { return serenePalette }

        let dominant = colorTokens.first ?? "neutral"
        switch dominant {
        case "warm": return warmPalette
        case "cool": return coolPalette
        case "dark": return darkPalette
        default: return neutralPalette
        }
    }

    private static func computeWarmthScore(colorTokens: [String], moodTags: [String], textKeywords: [String]) -> Double {
        var score = 0.5
        let warmCount = colorTokens.filter { $0 == "warm" }.count
        let coolCount = colorTokens.filter { $0 == "cool" }.count
        score += Double(warmCount) * 0.12
        score -= Double(coolCount) * 0.1
        if moodTags.contains("warm") || moodTags.contains("cozy") { score += 0.15 }
        if moodTags.contains("cool") || moodTags.contains("serene") { score -= 0.1 }
        if textKeywords.containsAny(["oak", "brass", "copper", "candle"]) { score += 0.1 }
        return max(0.1, min(score, 0.95))
    }

    private static func computeModernScore(styleTags: [String], textKeywords: [String]) -> Double {
        var score = 0.5
        if styleTags.contains("contemporary") || styleTags.contains("minimalist") || styleTags.contains("industrial") { score += 0.25 }
        if styleTags.contains("scandinavian") || styleTags.contains("organic-modern") { score += 0.15 }
        if styleTags.contains("traditional") || styleTags.contains("rustic") { score -= 0.2 }
        if textKeywords.containsAny(["sleek", "modern", "clean", "contemporary"]) { score += 0.1 }
        return max(0.1, min(score, 0.95))
    }

    private static func computeMinimalistScore(styleTags: [String], textKeywords: [String]) -> Double {
        var score = 0.5
        if styleTags.contains("minimalist") || styleTags.contains("scandinavian") || styleTags.contains("japandi") { score += 0.3 }
        if styleTags.contains("bohemian") || styleTags.contains("parisian") { score -= 0.2 }
        if textKeywords.containsAny(["minimal", "simple", "clean", "spare", "pared"]) { score += 0.15 }
        if textKeywords.containsAny(["layered", "eclectic", "collected", "textured"]) { score -= 0.15 }
        return max(0.1, min(score, 0.95))
    }

    // MARK: - Tag Extraction Dictionaries

    private static let styleDictionary: [String: [String]] = [
        "organic-modern": ["organic", "modern", "natural", "earthy", "grounded"],
        "coastal": ["coastal", "ocean", "beach", "airy", "fresh", "seaside", "nautical"],
        "scandinavian": ["scandinavian", "scandi", "nordic", "hygge", "calm"],
        "minimalist": ["minimal", "minimalist", "clean", "simple", "spare", "pared"],
        "industrial": ["industrial", "raw", "concrete", "metal", "urban", "loft"],
        "parisian": ["parisian", "french", "eclectic", "chic", "bistro"],
        "bohemian": ["boho", "bohemian", "layered", "collected", "global", "textured"],
        "rustic": ["rustic", "farmhouse", "country", "cottage", "weathered"],
        "contemporary": ["contemporary", "sleek", "streamlined", "current", "refined"],
        "traditional": ["traditional", "classic", "timeless", "heritage", "elegant"]
    ]

    private static let moodDictionary: [String: [String]] = [
        "warm": ["warm", "cozy", "inviting", "snug", "toasty"],
        "cool": ["cool", "crisp", "fresh", "bright", "light"],
        "intimate": ["intimate", "personal", "quiet", "private"],
        "dramatic": ["dramatic", "bold", "moody", "dark", "rich"],
        "serene": ["serene", "peaceful", "calm", "tranquil", "zen"],
        "energetic": ["energetic", "vibrant", "lively", "dynamic"],
        "luxurious": ["luxurious", "luxury", "premium", "opulent", "sumptuous"]
    ]

    private static let materialDictionary: [String: [String]] = [
        "linen": ["linen", "flax"],
        "ceramic": ["ceramic", "porcelain", "stoneware", "earthenware", "pottery"],
        "wood": ["wood", "oak", "walnut", "maple", "acacia", "teak", "timber"],
        "brass": ["brass", "gold", "gilded", "golden"],
        "copper": ["copper", "bronze"],
        "glass": ["glass", "crystal"],
        "marble": ["marble", "stone", "granite", "quartz"],
        "cotton": ["cotton", "canvas", "muslin"],
        "leather": ["leather", "suede", "hide"],
        "rattan": ["rattan", "wicker", "woven", "cane"],
        "metal": ["metal", "steel", "iron", "silver", "chrome"]
    ]

    private static let roomDictionary: [String: [String]] = [
        "kitchen": ["kitchen", "cooking", "baking", "culinary", "chef"],
        "dining": ["dining", "table", "dinner", "brunch", "hosting", "entertaining"],
        "living": ["living", "lounge", "sitting", "family"],
        "bedroom": ["bedroom", "bed", "sleep", "rest"],
        "bathroom": ["bathroom", "bath", "spa"],
        "outdoor": ["outdoor", "patio", "garden", "terrace", "balcony"]
    ]

    private static func extractStyleTags(from keywords: [String]) -> [String] {
        extractTags(from: keywords, using: styleDictionary)
    }

    private static func extractMoodTags(from keywords: [String]) -> [String] {
        extractTags(from: keywords, using: moodDictionary)
    }

    private static func extractMaterialTags(from keywords: [String]) -> [String] {
        extractTags(from: keywords, using: materialDictionary)
    }

    private static func extractRoomTags(from keywords: [String]) -> [String] {
        extractTags(from: keywords, using: roomDictionary)
    }

    private static func extractTags(from keywords: [String], using dictionary: [String: [String]]) -> [String] {
        var matched: [String] = []
        for (tag, triggers) in dictionary {
            if keywords.contains(where: { kw in triggers.contains(where: { kw.contains($0) }) }) {
                matched.append(tag)
            }
        }
        return matched
    }

    // MARK: - Weighted Product Scoring

    private static func scoreProducts(
        _ products: [ProductItem],
        profile: MoodboardStyleProfile,
        textKeywords: [String]
    ) -> [ScoredProduct] {

        let seasonalKW = SeasonalContextEngine.seasonalKeywords()
        let allKeywords = textKeywords + seasonalKW

        return products.map { product in
            var score: Double = 0
            var reasons: [String] = []
            let lowerName = product.name.lowercased()
            let lowerType = product.productType?.lowercased() ?? ""
            let lowerMaterial = product.material?.lowercased() ?? ""
            let lowerBrand = product.brand?.lowercased() ?? ""
            let lowerCollection = product.collection?.lowercased() ?? ""
            let lowerPattern = product.pattern?.lowercased() ?? ""

            // Build a searchable blob from all product metadata
            let allPropsText = (product.allProperties?.values.joined(separator: " ") ?? "").lowercased()
            let searchBlob = "\(lowerName) \(lowerType) \(lowerMaterial) \(lowerBrand) \(lowerCollection) \(lowerPattern) \(allPropsText)"

            // 1) Style tag match (weight: 15)
            for tag in profile.styleTags {
                if let triggers = styleDictionary[tag] {
                    if triggers.contains(where: { searchBlob.contains($0) }) {
                        score += 15
                        reasons.append("style:\(tag)")
                    }
                }
            }

            // 2) Material match (weight: 12)
            for tag in profile.materialTags {
                if let triggers = materialDictionary[tag] {
                    if triggers.contains(where: { searchBlob.contains($0) }) {
                        score += 12
                        reasons.append("material:\(tag)")
                    }
                }
            }

            // 3) Color palette match (weight: 10)
            for colorToken in profile.colorPalette {
                let warmWords = ["ceramic", "linen", "wood", "brass", "copper", "terracotta", "amber", "honey", "walnut", "oak", "teak", "golden"]
                let coolWords = ["glass", "blue", "white", "porcelain", "crystal", "silver", "chrome", "steel", "ice", "frost"]
                let darkWords = ["dark", "black", "iron", "matte", "charcoal", "ebony", "midnight", "noir", "espresso"]
                let neutralWords = ["natural", "ivory", "cream", "beige", "sand", "oat", "stone", "flax", "bone"]

                let matchWords: [String]
                switch colorToken {
                case "warm": matchWords = warmWords
                case "cool": matchWords = coolWords
                case "dark": matchWords = darkWords
                default: matchWords = neutralWords
                }

                if matchWords.contains(where: { searchBlob.contains($0) }) {
                    score += 10
                    reasons.append("color:\(colorToken)")
                }
            }

            // 4) Room/category relevance (weight: 10)
            for tag in profile.roomTags {
                if let triggers = roomDictionary[tag] {
                    if triggers.contains(where: { searchBlob.contains($0) }) {
                        score += 10
                        reasons.append("room:\(tag)")
                    }
                }
            }

            // 5) Direct keyword match in product name (weight: 12 — highest signal)
            for kw in allKeywords {
                let lkw = kw.lowercased()
                if lkw.count > 2 && lowerName.contains(lkw) {
                    score += 12
                    reasons.append("kw-name:\(lkw)")
                }
            }

            // 6) Keyword match in type/brand/collection (weight: 8)
            for kw in allKeywords {
                let lkw = kw.lowercased()
                if lkw.count > 2 && (lowerType.contains(lkw) || lowerBrand.contains(lkw) || lowerCollection.contains(lkw)) {
                    score += 8
                    reasons.append("kw-meta:\(lkw)")
                }
            }

            // 7) Keyword match in all properties blob (weight: 4)
            for kw in allKeywords {
                let lkw = kw.lowercased()
                if lkw.count > 3 && allPropsText.contains(lkw) && !lowerName.contains(lkw) {
                    score += 4
                    reasons.append("kw-props:\(lkw)")
                }
            }

            // 8) Mood/atmosphere bonus
            if profile.moodTags.contains("warm") {
                if searchBlob.contains("candle") || searchBlob.contains("copper") || searchBlob.contains("brass") || searchBlob.contains("fireplace") {
                    score += 6; reasons.append("mood:warm")
                }
            }
            if profile.moodTags.contains("luxurious") {
                if searchBlob.contains("marble") || searchBlob.contains("crystal") || searchBlob.contains("gold") || searchBlob.contains("cashmere") {
                    score += 6; reasons.append("mood:luxury")
                }
            }
            if profile.moodTags.contains("serene") || profile.moodTags.contains("cool") {
                if searchBlob.contains("linen") || searchBlob.contains("white") || searchBlob.contains("cotton") || searchBlob.contains("light") {
                    score += 6; reasons.append("mood:serene")
                }
            }

            return ScoredProduct(product: product, score: score, reasons: reasons)
        }
        .filter { $0.score > 0 }
        .sorted { $0.score > $1.score }
    }

    // MARK: - MMR Diversity Reranking

    private static func diversityRerank(_ scored: [ScoredProduct], topN: Int) -> [ScoredProduct] {
        guard !scored.isEmpty else { return [] }

        var result: [ScoredProduct] = []
        var remaining = scored
        var categoryPenalties: [String: Int] = [:]

        while result.count < topN && !remaining.isEmpty {
            var bestIndex = 0
            var bestAdjustedScore: Double = -1

            for (index, candidate) in remaining.enumerated() {
                let category = candidate.product.productType?.lowercased() ?? "unknown"
                let penalty = Double(categoryPenalties[category, default: 0]) * 8.0
                let adjusted = candidate.score - penalty

                if adjusted > bestAdjustedScore {
                    bestAdjustedScore = adjusted
                    bestIndex = index
                }
            }

            let selected = remaining.remove(at: bestIndex)
            let category = selected.product.productType?.lowercased() ?? "unknown"
            categoryPenalties[category, default: 0] += 1
            result.append(selected)
        }

        return result
    }

    // MARK: - Confidence

    private static func computeConfidence(imageCount: Int, textLength: Int, tagCount: Int) -> Double {
        var c: Double = 0.3
        c += min(Double(imageCount) * 0.1, 0.3)
        c += min(Double(textLength) / 100.0 * 0.2, 0.2)
        c += min(Double(tagCount) * 0.04, 0.2)
        return min(c, 1.0)
    }

    // MARK: - Fingerprint

    private static func buildFingerprint(vibeText: String, colorTokens: [String]) -> String {
        let combined = vibeText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) + "|" + colorTokens.sorted().joined(separator: ",")
        let digest = SHA256.hash(data: Data(combined.utf8))
        return digest.prefix(8).map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Debug Log

    private static func logAnalysis(profile: MoodboardStyleProfile, topProducts: [ScoredProduct]) {
        print("━━━ MoodboardStyleAnalyzer ━━━")
        print("  Identity: \(profile.identityName)")
        print("  Fingerprint: \(profile.inputFingerprint)")
        print("  Confidence: \(String(format: "%.2f", profile.confidence))")
        print("  Style: \(profile.styleTags.joined(separator: ", "))")
        print("  Mood: \(profile.moodTags.joined(separator: ", "))")
        print("  Material: \(profile.materialTags.joined(separator: ", "))")
        print("  Room: \(profile.roomTags.joined(separator: ", "))")
        print("  Top \(topProducts.count) products:")
        for (i, sp) in topProducts.prefix(5).enumerated() {
            print("    \(i+1). \(sp.product.name) — score: \(String(format: "%.1f", sp.score)) — \(sp.reasons.joined(separator: ", "))")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}
