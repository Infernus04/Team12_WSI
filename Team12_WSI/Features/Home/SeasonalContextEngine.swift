// SeasonalContextEngine.swift
// Team12_WSI — Detects current season and provides mood copy

import Foundation
import SwiftUI

enum AppSeason {
    case spring, summer, autumn, winter
}

struct SeasonalMood: Identifiable {
    let id = UUID()
    let headline: String
    let subtitle: String
    let cta: String
}

struct SeasonalContextEngine {

    // MARK: - Season Detection

    static func currentSeason() -> AppSeason {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3...5:  return .spring
        case 6...8:  return .summer
        case 9...11: return .autumn
        default:     return .winter
        }
    }

    // MARK: - Hero Moods (3 per season)

    static func heroMoods() -> [SeasonalMood] {
        switch currentSeason() {
        case .spring:
            return [
                SeasonalMood(headline: "The Spring\nBrunch Edit", subtitle: "Airy tablescapes for new beginnings.", cta: "EXPLORE THE COLLECTION"),
                SeasonalMood(headline: "Airy Mornings\nAt Home", subtitle: "Ritual objects for slow, intentional living.", cta: "CURATE YOUR SPACE"),
                SeasonalMood(headline: "The Fresh\nTablescape", subtitle: "Light and luminous entertaining essentials.", cta: "COMPLETE YOUR HOME")
            ]
        case .summer:
            return [
                SeasonalMood(headline: "Modern Coastal\nHosting", subtitle: "Light, fresh, and effortlessly elegant.", cta: "EXPLORE THE COLLECTION"),
                SeasonalMood(headline: "Outdoor\nEntertaining", subtitle: "The season of al fresco luxury.", cta: "CURATE YOUR DINING SPACE"),
                SeasonalMood(headline: "The Summer\nTable", subtitle: "Crisp whites and warm evenings.", cta: "COMPLETE YOUR HOME")
            ]
        case .autumn:
            return [
                SeasonalMood(headline: "Warm Autumn\nEntertaining", subtitle: "Curated for layered hosting this season.", cta: "EXPLORE THE COLLECTION"),
                SeasonalMood(headline: "The Art of\nIntimate Dining", subtitle: "Elevated tablescapes for cherished moments.", cta: "CURATE YOUR DINING SPACE"),
                SeasonalMood(headline: "Layered\nHosting", subtitle: "Warm textures and copper tones for the season.", cta: "COMPLETE YOUR HOME")
            ]
        case .winter:
            return [
                SeasonalMood(headline: "A Luxurious\nHoliday Table", subtitle: "Timeless gifting for the people you love.", cta: "EXPLORE THE COLLECTION"),
                SeasonalMood(headline: "Winter\nEntertaining", subtitle: "The season of intimate gatherings.", cta: "CURATE YOUR SPACE"),
                SeasonalMood(headline: "The Gift of\nHome", subtitle: "Elevated gifting for every moment.", cta: "COMPLETE YOUR HOME")
            ]
        }
    }

    // MARK: - Seasonal Section

    static func seasonalSectionHeader() -> String {
        switch currentSeason() {
        case .spring: return "The Spring Brunch Edit"
        case .summer: return "Modern Coastal Collection"
        case .autumn: return "The Autumn Entertaining Edit"
        case .winter: return "A Luxurious Holiday Table"
        }
    }

    static func seasonalAccentColor() -> Color {
        switch currentSeason() {
        case .spring: return Color(hex: "#A8B5A0")
        case .summer: return Color(hex: "#7BA7BC")
        case .autumn: return Color(hex: "#B87333")
        case .winter: return Color(hex: "#6B2D3E")
        }
    }

    static func seasonalKeywords() -> [String] {
        switch currentSeason() {
        case .spring: return ["linen", "floral", "white", "glass", "porcelain", "brunch", "carafe", "spring"]
        case .summer: return ["coastal", "light", "white", "glass", "blue", "airy", "outdoor", "pitcher"]
        case .autumn: return ["ceramic", "linen", "copper", "candle", "warm", "brass", "serving", "autumn"]
        case .winter: return ["crystal", "silver", "holiday", "gift", "festive", "candle", "linen", "mug"]
        }
    }
}
