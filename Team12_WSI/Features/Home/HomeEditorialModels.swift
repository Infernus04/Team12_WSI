// HomeEditorialModels.swift
// Team12_WSI — Extended Editorial Data

import Foundation
import SwiftUI

// MARK: - Lifestyle Scene

struct LifestyleScene: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let reason: String
    let productOffset: Int // index offset into viewModel.products for this scene's product
}

// MARK: - Aesthetic Bundle

struct AestheticBundle: Identifiable {
    let id = UUID()
    let title: String
    let compatibilityScore: Int
    let imageName: String
    let description: String
    let aiReason: String
    let productOffsets: [Int] // 4 indices into viewModel.products
}

// MARK: - Editorial Article

struct EditorialArticle: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let readTime: String
    let body: String
    let imageName: String
    let productOffset: Int
}

// MARK: - Home Editorial Data

class HomeEditorialData {

    // MARK: Scenes
    static let scenes: [LifestyleScene] = [
        LifestyleScene(
            title: "Sunday Brunch Hosting",
            subtitle: "Warm light and organic textures for shared moments.",
            imageName: "brunch_scene",
            reason: "These ceramics complement your oak flooring and hosting frequency.",
            productOffset: 0
        ),
        LifestyleScene(
            title: "Intimate Evening Dining",
            subtitle: "Layered shadows and brass highlights.",
            imageName: "dinner_scene",
            reason: "Designed around your preference for modern minimal dining.",
            productOffset: 1
        ),
        LifestyleScene(
            title: "Layered Autumn Hosting",
            subtitle: "Warm textures and copper tones for the season.",
            imageName: "autumn_hosting",
            reason: "Matched to your warm wood and linen aesthetic.",
            productOffset: 2
        ),
        LifestyleScene(
            title: "The Warm Kitchen",
            subtitle: "Morning ritual objects for slow, intentional living.",
            imageName: "warm_kitchen",
            reason: "Hand-thrown ceramics aligned with your organic style DNA.",
            productOffset: 3
        )
    ]

    // MARK: Bundles
    static let bundles: [AestheticBundle] = [
        AestheticBundle(
            title: "Modern Autumn Hosting",
            compatibilityScore: 98,
            imageName: "bundle_autumn",
            description: "Ceramic dinnerware, linen napkins, brass decor, serving bowls.",
            aiReason: "These four pieces share a warm, earthy palette and complement each other's materiality — organic ceramics softened by natural linen and grounded by brass.",
            productOffsets: [0, 1, 2, 3]
        ),
        AestheticBundle(
            title: "Organic Minimalist Morning",
            compatibilityScore: 92,
            imageName: "bundle_morning",
            description: "Hand-thrown mugs, sustainable wood trays, linen placemats, glass carafe.",
            aiReason: "A morning ritual collection designed around slow living — each piece earns its place on a thoughtfully arranged kitchen counter.",
            productOffsets: [4, 5, 6, 7]
        ),
        AestheticBundle(
            title: "Intimate Dinner Collection",
            compatibilityScore: 88,
            imageName: "bundle_dinner",
            description: "Dark ceramics, taper candles, serving bowls, linen runner.",
            aiReason: "The interplay of matte dark ceramics and warm candlelight creates a dining atmosphere that feels considered and deeply personal.",
            productOffsets: [8, 9, 10, 11]
        ),
        AestheticBundle(
            title: "Spring Brunch Edit",
            compatibilityScore: 85,
            imageName: "bundle_spring",
            description: "White porcelain, floral napkins, glass carafes, rattan tray.",
            aiReason: "Light, airy materials that celebrate the season — this collection photographs beautifully and lives even better.",
            productOffsets: [12, 13, 14, 15]
        )
    ]

    // MARK: Articles
    static let articles: [EditorialArticle] = [
        EditorialArticle(
            title: "The Art of Layered Minimalism",
            subtitle: "How to create depth in neutral spaces.",
            category: "INTERIORS",
            readTime: "4 min read",
            body: "The most compelling minimal spaces are never truly empty — they are precisely edited. Layering begins with the understanding that restraint is not absence, but intention. Start with your largest surface: a dining table set with hand-thrown ceramics and unbleached linen creates the foundation. Add height through a single sculptural vase or taper candle. The final layer is texture — a loosely folded napkin, the grain of an oak board, the weight of a ceramic pitcher. Each object earns its place.",
            imageName: "article_minimalism",
            productOffset: 0
        ),
        EditorialArticle(
            title: "Hosting Elegantly This Season",
            subtitle: "Refined tablescapes for the season.",
            category: "HOSTING",
            readTime: "3 min read",
            body: "Seasonal hosting is less about occasion and more about atmosphere. This season, we gravitate toward warmth — copper candlesticks, deep-toned ceramics, and the unpretentious luxury of natural linen. A beautifully set table communicates care before a single word is spoken. Begin with placemats in warm jute or linen, layer with your finest ceramic dinner plates, and let the centerpiece breathe. Less arrangement, more composition.",
            imageName: "article_hosting",
            productOffset: 3
        ),
        EditorialArticle(
            title: "How To Build A Timeless Dining Table",
            subtitle: "The foundations of a forever tablescape.",
            category: "INTERIORS",
            readTime: "5 min read",
            body: "A timeless dining table is not assembled — it is accumulated. Begin with a dinner service you genuinely love: the weight, the glaze, the rim. Add serving pieces slowly. A great platter purchased on a trip. A set of wine glasses gifted. The tablescape that lasts decades is one built with intention over time, not purchased in a single moment of enthusiasm. Williams-Sonoma's founding belief was exactly this: that the kitchen and table are where culture, love, and craft intersect.",
            imageName: "article_dining",
            productOffset: 6
        ),
        EditorialArticle(
            title: "A Guide To Morning Ritual Objects",
            subtitle: "The ceramics that make slow mornings sacred.",
            category: "LIFESTYLE",
            readTime: "3 min read",
            body: "The morning ritual begins before coffee is brewed. It begins with objects — a mug whose weight feels right in your hand, a tray that organizes without constraining, a kettle whose form you admire as it heats. These are not luxury items; they are daily companions. The Japanese call this wabi-sabi: finding beauty in objects worn by use and time. Choose your morning pieces as though you will use them every day for the next decade — because you will.",
            imageName: "article_morning",
            productOffset: 9
        )
    ]
}
