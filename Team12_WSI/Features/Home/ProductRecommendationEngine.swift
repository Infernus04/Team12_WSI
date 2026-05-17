// ProductRecommendationEngine.swift
// Team12_WSI — Powers the 4 recommendation sections in ProductDetailView

import Foundation

struct ProductRecommendationEngine {

    let allProducts: [ProductItem]
    let selectedProduct: ProductItem

    // MARK: - Complementary Map

    private static let complementaryMap: [(triggers: [String], complements: [String])] = [
        (["plate", "dinnerware", "dish", "dinner"], ["napkin", "runner", "candle", "serving", "bowl", "glass", "placemat"]),
        (["cookware", "pan", "pot", "skillet", "wok"], ["utensil", "board", "knife", "towel", "mitt", "ladle", "spoon"]),
        (["serveware", "platter", "serving"], ["tray", "napkin", "ladle", "spoon", "fork", "bowl"]),
        (["mug", "cup", "coffee", "tea", "espresso"], ["tray", "canister", "spoon", "coaster", "kettle", "carafe"]),
        (["knife", "cutting", "carving"], ["board", "block", "sharpener", "stand", "honing"]),
        (["linen", "napkin", "runner", "placemat"], ["plate", "candle", "bowl", "vase", "ceramic"]),
        (["glass", "wine", "champagne", "cocktail"], ["decanter", "carafe", "tray", "coaster", "opener"]),
        (["candle", "candlestick", "taper"], ["tray", "vase", "match", "diffuser", "linen", "holder"]),
        (["vase", "vessel", "pitcher", "jug"], ["tray", "candle", "linen", "bowl", "runner"]),
        (["bowl", "salad", "serving bowl"], ["tong", "spoon", "ladle", "platter", "tray"])
    ]

    // MARK: 1. You May Also Need

    func youMayAlsoNeed() -> [ProductItem] {
        let lowerName = selectedProduct.name.lowercased()
        var complementKeywords: [String] = []

        for mapping in Self.complementaryMap {
            if mapping.triggers.contains(where: { lowerName.contains($0) }) {
                complementKeywords = mapping.complements
                break
            }
        }

        // Generic fallback
        if complementKeywords.isEmpty {
            complementKeywords = ["napkin", "tray", "candle", "linen", "bowl", "runner", "vase"]
        }

        let results = allProducts
            .filter { $0.id != selectedProduct.id }
            .filter { product in
                let n = product.name.lowercased()
                return complementKeywords.contains { n.contains($0) }
            }

        // Shuffle for variety, cap at 6
        return Array(results.shuffled().prefix(6))
    }

    // MARK: 2. Also In This Collection

    func alsoInThisCollection() -> [ProductItem] {
        // Try productType match
        if let type = selectedProduct.productType, !type.trimmingCharacters(in: .whitespaces).isEmpty {
            let byType = allProducts.filter {
                $0.id != selectedProduct.id &&
                $0.productType?.lowercased() == type.lowercased()
            }
            if byType.count >= 2 { return Array(byType.prefix(6)) }
        }

        // Try brand match
        if let brand = selectedProduct.brand, !brand.trimmingCharacters(in: .whitespaces).isEmpty {
            let byBrand = allProducts.filter {
                $0.id != selectedProduct.id &&
                $0.brand?.lowercased() == brand.lowercased()
            }
            if byBrand.count >= 2 { return Array(byBrand.prefix(6)) }
        }

        // Fallback: shared meaningful word in name
        let selectedWords = Set(
            selectedProduct.name.lowercased()
                .components(separatedBy: .whitespaces)
                .filter { $0.count > 3 }
        )

        return Array(
            allProducts
                .filter { $0.id != selectedProduct.id }
                .filter { product in
                    let words = product.name.lowercased()
                        .components(separatedBy: .whitespaces)
                        .filter { $0.count > 3 }
                    return !selectedWords.isDisjoint(with: Set(words))
                }
                .prefix(6)
        )
    }

    // MARK: 3. Similar Items

    func similarItems() -> [ProductItem] {
        let selectedTokens = Set(
            selectedProduct.name.lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { $0.count > 3 }
        )

        struct Scored { let product: ProductItem; let score: Int }

        return allProducts
            .filter { $0.id != selectedProduct.id }
            .map { product -> Scored in
                let tokens = Set(
                    product.name.lowercased()
                        .components(separatedBy: CharacterSet.alphanumerics.inverted)
                        .filter { $0.count > 3 }
                )
                return Scored(product: product, score: selectedTokens.intersection(tokens).count)
            }
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
            .prefix(6)
            .map { $0.product }
    }

    // MARK: 4. More To Consider

    func moreToConsider(excluding excludedIDs: Set<String>) -> [ProductItem] {
        let price = selectedProduct.price ?? 0
        let minP  = price * 0.70
        let maxP  = price * 1.30

        var results = allProducts
            .filter { $0.id != selectedProduct.id && !excludedIDs.contains($0.id) }
            .filter { p in
                guard let pp = p.price else { return false }
                return pp >= minP && pp <= maxP
            }
            .prefix(6)
            .map { $0 }

        // Pad if needed
        if results.count < 4 {
            let extra = allProducts
                .filter { $0.id != selectedProduct.id && !excludedIDs.contains($0.id) }
                .filter { p in !results.contains(where: { $0.id == p.id }) }
                .prefix(6 - results.count)
            results.append(contentsOf: extra)
        }

        return results
    }

    // MARK: Instagram Grid (6 unique products)

    func instagramGridProducts() -> [ProductItem] {
        var seen = Set<String>([selectedProduct.id])
        var result: [ProductItem] = []

        for pool in [youMayAlsoNeed(), alsoInThisCollection(), similarItems()] {
            for p in pool where !seen.contains(p.id) {
                seen.insert(p.id)
                result.append(p)
                if result.count == 6 { return result }
            }
        }

        // Fill remaining from allProducts
        for p in allProducts where !seen.contains(p.id) {
            result.append(p)
            if result.count == 6 { break }
        }

        return result
    }
}
