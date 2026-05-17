//
//  AuraDesign.swift
//  Team12_WSI
//

import SwiftUI

struct AuraDesign {
    struct Colors {
        static let ivory = Color(hex: "F9F8F6")
        static let cream = Color(hex: "F2EFE9")
        static let walnut = Color(hex: "4A3B32")
        static let charcoal = Color(hex: "2A2A2A")
        static let mutedGold = Color(hex: "C5B382")
        static let errorRed = Color(hex: "8A3A3A")
        static let successGreen = Color(hex: "4A5B4A")
    }
    
    struct Fonts {
        static func serif(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            // Using Georgia as a fallback premium serif font available on iOS
            return Font.custom("Georgia", size: size).weight(weight)
        }
        
        static func sansSerif(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            // Using system SF Pro but structured for premium feel
            return Font.system(size: size, weight: weight, design: .default)
        }
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
