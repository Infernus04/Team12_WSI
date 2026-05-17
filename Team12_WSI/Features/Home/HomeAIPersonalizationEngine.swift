// HomeAIPersonalizationEngine.swift
// Team12_WSI — Color analysis + style identity + keyword product scoring

import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Style Identity

struct StyleIdentity {
    let name: String
    let description: String
    let warmth: Double      // 0.0–1.0
    let modern: Double      // 0.0–1.0
    let minimalist: Double  // 0.0–1.0
    let swatches: [Color]
}

// MARK: - Engine

struct HomeAIPersonalizationEngine {

    // MARK: Color Extraction

    /// Extracts the average dominant color from a UIImage using Core Image.
    static func dominantColor(from image: UIImage) -> Color? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let filter = CIFilter.areaAverage()
        filter.inputImage = ciImage
        filter.extent = ciImage.extent
        guard let output = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: NSNull()])
        context.render(output,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        return Color(red: Double(bitmap[0]) / 255,
                     green: Double(bitmap[1]) / 255,
                     blue: Double(bitmap[2]) / 255)
    }

    // MARK: Color Token Classification

    /// Returns "warm", "cool", "dark", or "neutral"
    static func classifyColor(_ color: Color) -> String {
        let ui = UIColor(color)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

        if b < 0.25 { return "dark" }
        if s < 0.12 { return "neutral" }

        // Hue wheel: 0–0.20 = warm (red/orange/yellow), 0.20–0.55 = cool (green/cyan/blue), else = warm (purple-red)
        if (h >= 0.0 && h < 0.20) || h >= 0.85 { return "warm" }
        if h >= 0.20 && h < 0.55 { return "cool" }
        return "warm"
    }

    // MARK: Style Identity Generation

    static func generateStyleIdentity(colorTokens: [String], textKeywords: [String]) -> StyleIdentity {
        let warm    = colorTokens.filter { $0 == "warm" }.count
        let cool    = colorTokens.filter { $0 == "cool" }.count
        let dark    = colorTokens.filter { $0 == "dark" }.count
        let neutral = colorTokens.filter { $0 == "neutral" }.count

        let isMinimal  = textKeywords.containsAny(["minimal", "minimalist", "clean", "simple", "spare", "pared"])
        let isOrganic  = textKeywords.containsAny(["organic", "natural", "wood", "linen", "oak", "rattan", "cotton"])
        let isCoastal  = textKeywords.containsAny(["coastal", "ocean", "beach", "airy", "fresh", "light"])
        let isIndustrial = textKeywords.containsAny(["industrial", "raw", "concrete", "metal", "dark", "moody"])

        if warm >= 2 && isOrganic {
            return StyleIdentity(
                name: "Modern Organic Warmth",
                description: "You gravitate toward warm woods, organic textures, and earthy tones that make spaces feel grounded and deeply inviting.",
                warmth: 0.82, modern: 0.55, minimalist: 0.60,
                swatches: [Color(hex: "#C4A882"), Color(hex: "#8B6F47"), Color(hex: "#F5F0E8"), Color(hex: "#D4B896")]
            )
        } else if cool >= 2 || isCoastal {
            return StyleIdentity(
                name: "California Coastal",
                description: "Light, airy, and effortlessly relaxed — your aesthetic draws from natural light and oceanic calm.",
                warmth: 0.40, modern: 0.70, minimalist: 0.75,
                swatches: [Color(hex: "#B8D4E3"), Color(hex: "#F5F9FC"), Color(hex: "#7BA7BC"), Color(hex: "#E8EFF3")]
            )
        } else if (dark >= 2 || isIndustrial) && cool >= 1 {
            return StyleIdentity(
                name: "Refined Industrial",
                description: "You balance raw materials with precision — dark tones and structured forms define your elevated aesthetic.",
                warmth: 0.25, modern: 0.80, minimalist: 0.65,
                swatches: [Color(hex: "#2C2C2C"), Color(hex: "#5C5C5C"), Color(hex: "#B5A68B"), Color(hex: "#F0EDE8")]
            )
        } else if isMinimal && neutral >= 1 {
            return StyleIdentity(
                name: "Parisian Minimal",
                description: "Restraint is your luxury — quiet tones, considered objects, and elegant simplicity define your home.",
                warmth: 0.50, modern: 0.65, minimalist: 0.90,
                swatches: [Color(hex: "#F2EFEA"), Color(hex: "#C8C0B4"), Color(hex: "#8C8278"), Color(hex: "#3C3530")]
            )
        } else if warm >= 1 && dark >= 1 {
            return StyleIdentity(
                name: "Parisian Eclecticism",
                description: "Rich contrasts and layered textures — your home tells stories through curated objects and bold warmth.",
                warmth: 0.70, modern: 0.45, minimalist: 0.35,
                swatches: [Color(hex: "#8B2635"), Color(hex: "#C4A882"), Color(hex: "#2C2416"), Color(hex: "#F0E6D0")]
            )
        } else {
            return StyleIdentity(
                name: "Scandinavian Minimal",
                description: "Pure form and thoughtful function — your aesthetic values calm, purposeful spaces with honest materials.",
                warmth: 0.55, modern: 0.75, minimalist: 0.85,
                swatches: [Color(hex: "#F9F7F4"), Color(hex: "#E0DBD4"), Color(hex: "#A8A09A"), Color(hex: "#4A4540")]
            )
        }
    }

    // MARK: Product Scoring

    static func scoreProducts(_ products: [ProductItem],
                               keywords: [String],
                               colorTokens: [String]) -> [ProductItem] {
        struct Scored { let product: ProductItem; let score: Int }

        let lowerKW = keywords.map { $0.lowercased() }

        let scored = products.map { product -> Scored in
            var score = 0
            let lowerName = product.name.lowercased()

            for kw in lowerKW where lowerName.contains(kw) { score += 10 }
            if let type = product.productType?.lowercased() {
                for kw in lowerKW where type.contains(kw) { score += 5 }
            }
            if colorTokens.contains("warm"),
               (lowerName.contains("ceramic") || lowerName.contains("linen") || lowerName.contains("wood")) {
                score += 3
            }
            return Scored(product: product, score: score)
        }

        return scored.sorted { $0.score > $1.score }.map { $0.product }
    }

    // MARK: Text Tokenization

    static func tokenize(_ text: String) -> [String] {
        let stopwords = Set(["a", "an", "the", "and", "or", "but", "in", "on", "at", "to",
                             "for", "of", "with", "my", "i", "want", "need", "like", "feel",
                             "more", "very", "that", "this", "is", "are", "was", "be"])
        return text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 && !stopwords.contains($0) }
    }
}

// MARK: - Array Helper

private extension Array where Element == String {
    func containsAny(_ targets: [String]) -> Bool {
        targets.contains { target in self.contains { $0.contains(target) } }
    }
}
