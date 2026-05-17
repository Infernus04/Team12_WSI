import SwiftUI

struct RegistryTheme {
    struct Colors {
        static let background = Color(white: 0.98)
        static let cardBackground = Color.white
        static let primaryText = Color.black
        static let secondaryText = Color(white: 0.4)
        static let accent = Color(red: 0.7, green: 0.2, blue: 0.2) // Subtle romantic red
        static let separator = Color(white: 0.9)
        static let goldAccent = Color(red: 0.85, green: 0.75, blue: 0.45) // Premium gold
    }
    
    struct Typography {
        static let heroTitle = Font.custom("Georgia", size: 36).weight(.regular)
        static let sectionTitle = Font.custom("Georgia", size: 24).weight(.regular)
        static let headline = Font.system(size: 18, weight: .semibold, design: .serif)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let caption = Font.system(size: 14, weight: .medium, design: .default)
        static let small = Font.system(size: 12, weight: .regular, design: .default)
    }
    
    struct Spacing {
        static let small: CGFloat = 8
        static let standard: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 40
    }
    
    struct CornerRadius {
        static let standard: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    struct Shadows {
        static let light = Shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - View Modifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(RegistryTheme.Colors.cardBackground)
            .cornerRadius(RegistryTheme.CornerRadius.standard)
            .shadow(color: RegistryTheme.Shadows.light.color,
                    radius: RegistryTheme.Shadows.light.radius,
                    x: RegistryTheme.Shadows.light.x,
                    y: RegistryTheme.Shadows.light.y)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(RegistryTheme.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(RegistryTheme.Spacing.standard)
            .background(RegistryTheme.Colors.primaryText)
            .cornerRadius(RegistryTheme.CornerRadius.standard)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(RegistryTheme.Typography.headline)
            .foregroundColor(RegistryTheme.Colors.primaryText)
            .frame(maxWidth: .infinity)
            .padding(RegistryTheme.Spacing.standard)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: RegistryTheme.CornerRadius.standard)
                    .stroke(RegistryTheme.Colors.separator, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
}
