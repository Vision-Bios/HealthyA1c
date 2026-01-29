import SwiftUI

enum FastingGraphTheme: String, CaseIterable, Identifiable {
    case pulse
    case layers
    case prism
    case arc

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pulse: return "Pulse"
        case .layers: return "Layers"
        case .prism: return "Prism"
        case .arc: return "Arc"
        }
    }
}

enum FastingPalette: String, CaseIterable, Identifiable {
    case eclipse
    case bloom
    case neon
    case ember

    var id: String { rawValue }

    var title: String {
        switch self {
        case .eclipse: return "Eclipse"
        case .bloom: return "Bloom"
        case .neon: return "Neon"
        case .ember: return "Ember"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .eclipse:
            return LinearGradient(
                colors: [Color(red: 0.20, green: 0.40, blue: 0.95),
                         Color(red: 0.80, green: 0.30, blue: 0.85),
                         Color(red: 0.20, green: 0.75, blue: 0.90)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .bloom:
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.45, blue: 0.55),
                         Color(red: 0.95, green: 0.75, blue: 0.30),
                         Color(red: 0.60, green: 0.40, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .neon:
            return LinearGradient(
                colors: [Color(red: 0.20, green: 0.90, blue: 0.80),
                         Color(red: 0.35, green: 0.55, blue: 0.98),
                         Color(red: 0.95, green: 0.40, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ember:
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.50, blue: 0.20),
                         Color(red: 0.98, green: 0.75, blue: 0.30),
                         Color(red: 0.90, green: 0.20, blue: 0.45)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var background: LinearGradient {
        switch self {
        case .eclipse:
            return LinearGradient(
                colors: [Color(red: 0.05, green: 0.06, blue: 0.10),
                         Color(red: 0.10, green: 0.07, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .bloom:
            return LinearGradient(
                colors: [Color(red: 0.07, green: 0.06, blue: 0.10),
                         Color(red: 0.12, green: 0.08, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .neon:
            return LinearGradient(
                colors: [Color(red: 0.04, green: 0.05, blue: 0.10),
                         Color(red: 0.08, green: 0.06, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .ember:
            return LinearGradient(
                colors: [Color(red: 0.08, green: 0.05, blue: 0.06),
                         Color(red: 0.16, green: 0.08, blue: 0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    var glow: Color {
        switch self {
        case .eclipse: return Color(red: 0.45, green: 0.70, blue: 0.98)
        case .bloom: return Color(red: 0.98, green: 0.60, blue: 0.50)
        case .neon: return Color(red: 0.30, green: 0.90, blue: 0.85)
        case .ember: return Color(red: 0.98, green: 0.55, blue: 0.35)
        }
    }

    var textColor: Color { .white }
    var cardBackground: Color { .white.opacity(0.08) }
    var inputBackground: Color { .white.opacity(0.10) }
    var preferredScheme: ColorScheme { .dark }
}
