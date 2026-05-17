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


