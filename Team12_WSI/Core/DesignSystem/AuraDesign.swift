//
//  AuraDesign.swift
//  Team12_WSI
//

import SwiftUI

struct AuraDesign {
    struct Colors {
        static let ivory = Color(hex: "F9F4EB") // exact WSRegistryPalette.ivory
        static let cream = Color(hex: "FDFBF5") // exact WSRegistryPalette.cream
        static let porcelain = Color(hex: "FFFDF9") // exact WSRegistryPalette.porcelain
        static let charcoal = Color(hex: "2F2016") // exact WSRegistryPalette.espresso (main text/titles)
        static let cocoa = Color(hex: "5A4230") // exact WSRegistryPalette.cocoa
        static let mutedGold = Color(hex: "AD8B49") // exact WSRegistryPalette.gold (accent/confidence meter)
        static let warmGray = Color(hex: "7F776C") // exact WSRegistryPalette.warmGray
        static let hairline = Color(hex: "DAD3C4") // exact WSRegistryPalette.hairline
        static let errorRed = Color(hex: "8A3A3A")
        static let successGreen = Color(hex: "798B6B") // exact WSRegistryPalette.sage
    }
    
    struct Fonts {
        static func serif(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            // Using system serif matching the Registry tab's native typography
            return Font.system(size: size, weight: weight, design: .serif)
        }
        
        static func sansSerif(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            // Using system SF Pro standard font
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
