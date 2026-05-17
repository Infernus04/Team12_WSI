// ProfileModels.swift
// Team12_WSI — Data models & static mock data for the Profile Tab

import SwiftUI

// MARK: - Style Genome

struct StyleGenome {
    let identityName: String
    let identitySubtitle: String
    let warmth: Double          // 0–1
    let minimalism: Double
    let hostingPersonality: Double
    let luxuryTier: Double
    let textureDensity: Double
    let modernVsClassic: Double // 0 = classic, 1 = modern
    let colorPalette: [Color]
    let materialAffinities: [String]
    let keywords: [String]

    static let mock = StyleGenome(
        identityName: "Modern Organic Warmth",
        identitySubtitle: "Curated around layered textures, intimate hosting, and warm natural materials.",
        warmth: 0.82,
        minimalism: 0.65,
        hostingPersonality: 0.78,
        luxuryTier: 0.71,
        textureDensity: 0.60,
        modernVsClassic: 0.58,
        colorPalette: [
            Color(hex: "#C8A882"), Color(hex: "#8B6F4E"),
            Color(hex: "#E8DCC8"), Color(hex: "#4A3728"), Color(hex: "#D4B896")
        ],
        materialAffinities: ["Oak", "Linen", "Ceramic", "Brass", "Stone"],
        keywords: ["ORGANIC", "WARM", "LAYERED", "INTIMATE", "ARTISANAL"]
    )
}

// MARK: - Order Journey

struct OrderJourney: Identifiable {
    let id = UUID()
    let collectionTitle: String
    let emotionalLabel: String
    let deliveryStatus: String
    let dateString: String
    let itemNames: [String]
    let imageName: String
    let aiInsight: String
    let accentColor: Color

    static let mock: [OrderJourney] = [
        OrderJourney(
            collectionTitle: "The Warm Hosting Collection",
            emotionalLabel: "Entertaining Elevated",
            deliveryStatus: "Delivered",
            dateString: "April 12, 2026",
            itemNames: ["Ceramic Dinnerware Set", "Brass Candle Holders", "Belgian Linen Runners"],
            imageName: "warm_hosting",
            aiInsight: "Your recent purchases suggest a transition toward elevated hosting and layered dining experiences.",
            accentColor: Color(hex: "#B5A68B")
        ),
        OrderJourney(
            collectionTitle: "The Autumn Kitchen Edit",
            emotionalLabel: "Slow Morning Ritual",
            deliveryStatus: "Delivered",
            dateString: "March 3, 2026",
            itemNames: ["Handcrafted French Press", "Oak Serving Board", "Ceramic Spice Set"],
            imageName: "warm_kitchen",
            aiInsight: "Organic morning rituals are becoming central to your home identity.",
            accentColor: Color(hex: "#8B6F4E")
        ),
        OrderJourney(
            collectionTitle: "Intimate Dinner Essentials",
            emotionalLabel: "Candlelit Gathering",
            deliveryStatus: "In Transit",
            dateString: "Expected May 20, 2026",
            itemNames: ["Taper Candlesticks", "Napkin Ring Set", "Merlot Wine Carafe"],
            imageName: "dinner_scene",
            aiInsight: "You are building a complete candlelit dining experience over multiple collections.",
            accentColor: Color(hex: "#4A3728")
        )
    ]
}

// MARK: - Registry Snapshot

struct RegistrySnapshot: Identifiable {
    let id = UUID()
    let registryName: String
    let occasion: String
    let completionPercent: Double
    let totalItems: Int
    let purchasedItems: Int
    let insights: [String]
    let categories: [(name: String, count: Int, color: Color)]

    static let mock: [RegistrySnapshot] = [
        RegistrySnapshot(
            registryName: "Wedding Registry",
            occasion: "JUNE 2026",
            completionPercent: 0.62,
            totalItems: 48,
            purchasedItems: 30,
            insights: [
                "Your cookware collection has strong gifting potential.",
                "Consider adding more accessible gifts between $50–$100.",
                "Linen & textiles are under-represented for your aesthetic."
            ],
            categories: [
                ("Cookware", 12, Color(hex: "#B5A68B")),
                ("Dining", 10, Color(hex: "#8B6F4E")),
                ("Textiles", 4, Color(hex: "#C8A882")),
                ("Décor", 8, Color(hex: "#4A3728")),
                ("Serveware", 6, Color(hex: "#D4B896"))
            ]
        ),
        RegistrySnapshot(
            registryName: "New Home Registry",
            occasion: "ONGOING",
            completionPercent: 0.34,
            totalItems: 62,
            purchasedItems: 21,
            insights: [
                "Kitchen essentials are well covered.",
                "Bedroom & bath categories are empty — a great gifting signal.",
                "Add a few statement pieces to anchor each room."
            ],
            categories: [
                ("Kitchen", 18, Color(hex: "#B5A68B")),
                ("Living", 14, Color(hex: "#8B6F4E")),
                ("Bedroom", 2, Color(hex: "#C8A882")),
                ("Bath", 3, Color(hex: "#4A3728")),
                ("Outdoor", 5, Color(hex: "#D4B896"))
            ]
        )
    ]
}

// MARK: - Saved Collection

struct SavedCollection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let itemCount: Int
    let accentColor: Color
    let iconName: String

    static let mock: [SavedCollection] = [
        SavedCollection(title: "Warm Kitchen Ideas", subtitle: "Morning ritual objects & organic materials", itemCount: 14, accentColor: Color(hex: "#B5A68B"), iconName: "flame"),
        SavedCollection(title: "Future Dining Room", subtitle: "Layered autumn hosting & candlelight", itemCount: 22, accentColor: Color(hex: "#8B6F4E"), iconName: "fork.knife"),
        SavedCollection(title: "Holiday Hosting", subtitle: "Festive entertaining with restrained luxury", itemCount: 9, accentColor: Color(hex: "#4A3728"), iconName: "sparkles"),
        SavedCollection(title: "Minimal Entertaining", subtitle: "Clean lines, warm woods, perfect whites", itemCount: 17, accentColor: Color(hex: "#C8A882"), iconName: "square.grid.2x2")
    ]
}

// MARK: - Room Upload

struct RoomUpload: Identifiable {
    let id = UUID()
    let title: String
    let analysisResults: [String]
    let recommendedStyle: String

    static let mock: [RoomUpload] = [
        RoomUpload(
            title: "Living Room",
            analysisResults: ["Warm oak materiality detected", "Organic minimal aesthetic", "Layered natural textures", "Open atmosphere"],
            recommendedStyle: "Modern Organic Warmth"
        ),
        RoomUpload(
            title: "Kitchen",
            analysisResults: ["Natural stone surfaces", "Artisanal ceramic accents", "Warm brass hardware", "Slow-living atmosphere"],
            recommendedStyle: "California Organic"
        )
    ]
}

// MARK: - Concierge Memory

struct ConciergeMemory: Identifiable {
    let id = UUID()
    let topic: String
    let summary: String
    let dateString: String
    let iconName: String

    static let mock: [ConciergeMemory] = [
        ConciergeMemory(topic: "Autumn Hosting", summary: "Previously discussed intimate autumn hosting with warm ceramics and layered linen textures.", dateString: "May 10", iconName: "leaf"),
        ConciergeMemory(topic: "Registry Advice", summary: "Suggested adding accessible gifts between $50–$100 to maximize gifting probability.", dateString: "Apr 28", iconName: "gift"),
        ConciergeMemory(topic: "Kitchen Styling", summary: "You prefer hand-thrown ceramics and natural wood for morning ritual spaces.", dateString: "Apr 15", iconName: "cup.and.saucer"),
        ConciergeMemory(topic: "Dining Room Vision", summary: "Building a candlelit intimate dining room with brass accents and linen table settings.", dateString: "Mar 30", iconName: "flame")
    ]
}

// MARK: - Membership

enum MembershipTier: String {
    case curated = "Curated Living"
    case reserve = "Reserve Member"
    case circle = "Home Circle"

    var accentColor: Color {
        switch self {
        case .curated: return Color(hex: "#B5A68B")
        case .reserve: return Color(hex: "#D4AF37")
        case .circle:  return Color(hex: "#C0A060")
        }
    }

    var description: String {
        switch self {
        case .curated: return "Early access to editorial collections and seasonal previews."
        case .reserve: return "Exclusive concierge service and private sale access."
        case .circle:  return "White-glove lifestyle curation and bespoke gifting."
        }
    }
}

// MARK: - Service Card

struct ServiceCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String

    static let mock: [ServiceCard] = [
        ServiceCard(title: "Track Your Order", subtitle: "Real-time delivery updates", iconName: "shippingbox"),
        ServiceCard(title: "White Glove Delivery", subtitle: "Premium installation service", iconName: "hands.sparkles"),
        ServiceCard(title: "Schedule Installation", subtitle: "Book a home styling session", iconName: "calendar"),
        ServiceCard(title: "Easy Returns", subtitle: "Hassle-free returns & exchanges", iconName: "arrow.uturn.left"),
        ServiceCard(title: "Live Concierge", subtitle: "Speak with a design expert", iconName: "person.wave.2"),
        ServiceCard(title: "Gifting Services", subtitle: "Custom gift wrapping & notes", iconName: "gift")
    ]
}
