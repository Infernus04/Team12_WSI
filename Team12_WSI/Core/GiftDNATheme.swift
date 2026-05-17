// GiftDNATheme.swift
// Team12_WSI
// Refined Luxury Design System for GiftDNA

import SwiftUI

extension Color {
    // Luxury Palette
    static let wsWarmIvory    = Color(hex: "#FAF9F6")
    static let wsIvory        = Color(hex: "#FAF9F6") // Compatibility Alias
    static let wsChampagne    = Color(hex: "#F3EFE0")
    static let wsCharcoal     = Color(hex: "#1A1A1A")
    static let wsPrimary      = Color(hex: "#1A1A1A") // Compatibility Alias
    static let wsMutedBrass   = Color(hex: "#B5A68B")
    static let wsSoftGold     = Color(hex: "#D4AF37")
    static let wsIvoryShadow  = Color(hex: "#E8E4D9")
    static let wsDivider      = Color(hex: "#E8E4D9") // Compatibility Alias
    
    // UI Colors
    static let wsSurface      = Color.white
    static let wsSecondary    = Color(hex: "#707070")
    static let wsCrimson      = Color(hex: "#C8102E") // WS Brand Accents
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

extension Font {
    // Serif Headlines
    static func wsDisplay(size: CGFloat) -> Font { .system(size: size, weight: .bold, design: .serif) }
    static func wsSerif(size: CGFloat, weight: Font.Weight = .regular) -> Font { .system(size: size, weight: weight, design: .serif) }
    
    // Sans-Serif Body
    static func wsBody(size: CGFloat, weight: Font.Weight = .regular) -> Font { .system(size: size, weight: weight, design: .default) }
    static func wsLabel(size: CGFloat, weight: Font.Weight = .semibold) -> Font { .system(size: size, weight: weight, design: .default) }
    
    // Compatibility Aliases
    static let wsDisplay  = Font.system(size: 26, weight: .bold,     design: .serif)
    static let wsTitle    = Font.system(size: 20, weight: .semibold,  design: .serif)
    static let wsHeadline = Font.system(size: 16, weight: .semibold,  design: .default)
    static let wsBody     = Font.system(size: 14, weight: .regular,   design: .default)
    static let wsCaption  = Font.system(size: 12, weight: .regular,   design: .default)
    static let wsLabel    = Font.system(size: 10, weight: .semibold,  design: .default)
}

struct WSShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func wsLuxuryShadow() -> some View { modifier(WSShadowModifier()) }
    func wsShadow() -> some View { modifier(WSShadowModifier()) } // Compatibility Alias
}

// MARK: - Reusable Luxury Components

struct WSDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.wsIvoryShadow)
            .frame(height: 1)
    }
}

struct WSBadge: View {
    let text: String
    var background: Color = .wsCharcoal
    var foreground: Color = .white
    
    var body: some View {
        Text(text.uppercased())
            .font(.wsLabel(size: 9))
            .tracking(1)
            .foregroundColor(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background)
            .cornerRadius(2)
    }
}

// MARK: - Button Styles

struct WSPrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.wsLabel(size: 12))
            .tracking(1.5)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isEnabled ? Color.wsCharcoal : Color.wsSecondary)
            .cornerRadius(2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct WSSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.wsLabel(size: 12))
            .tracking(1.5)
            .foregroundColor(.wsCharcoal)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .overlay(Rectangle().stroke(Color.wsCharcoal, lineWidth: 1))
            .background(Color.clear)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct WSGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.wsLabel(size: 12))
            .foregroundColor(.wsSecondary)
            .underline()
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}

// MARK: - Parallax Hero Image
// Reusable component — produces native iOS "image flooding" on overscroll
// and a subtle parallax as the user scrolls up. Drop this inside a ScrollView.

struct ParallaxHeroImage: View {
    let url: URL?
    /// Visible container height (e.g. 420). The image itself is rendered taller
    /// to provide parallax headroom; `parallaxFactor` controls how much.
    var height: CGFloat = 420
    /// 0.0 = no parallax, 0.5 = image moves at half scroll speed (recommended: 0.35–0.45)
    var parallaxFactor: CGFloat = 0.40

    var body: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            // Extra height added so the image never shows a gap during parallax scroll
            let parallaxHeadroom = height * parallaxFactor
            // When pulling down (minY > 0): rubber-band — image grows to flood the gap
            // When scrolling up (minY < 0): image moves up at (parallaxFactor) speed
            let extraHeight = minY > 0 ? minY : 0
            let offsetY: CGFloat = minY > 0
                ? -minY                        // Anchor top edge on pull-down
                : minY * parallaxFactor        // Slow upward parallax on scroll

            CustomAsyncImage(url: url)
                .frame(maxWidth: .infinity)
                .frame(height: height + parallaxHeadroom + extraHeight)
                .clipped()
                .offset(y: offsetY)
        }
        .frame(height: height)
        // Clip the GeometryReader container so extra height doesn't bleed
        .clipped()
    }
}
