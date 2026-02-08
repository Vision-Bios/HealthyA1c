import SwiftUI

enum GraphTheme: String, CaseIterable, Identifiable {
    case journey
    case ladder
    case river

    var id: String { rawValue }

    var title: String {
        switch self {
        case .journey: return "Journey"
        case .ladder: return "Ladder"
        case .river: return "River"
        }
    }
}

enum GraphPalette: String, CaseIterable, Identifiable {
    case warm
    case ocean
    case dusk
    case neon

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warm: return "Warm"
        case .ocean: return "Ocean"
        case .dusk: return "Dusk"
        case .neon: return "Neon"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .warm:
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.45, blue: 0.55),
                         Color(red: 0.98, green: 0.70, blue: 0.40),
                         Color(red: 0.55, green: 0.83, blue: 0.62)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ocean:
            return LinearGradient(
                colors: [Color(red: 0.18, green: 0.63, blue: 0.90),
                         Color(red: 0.24, green: 0.75, blue: 0.72),
                         Color(red: 0.14, green: 0.56, blue: 0.86)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dusk:
            return LinearGradient(
                colors: [Color(red: 0.39, green: 0.28, blue: 0.74),
                         Color(red: 0.62, green: 0.36, blue: 0.80),
                         Color(red: 0.12, green: 0.15, blue: 0.28)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .neon:
            return LinearGradient(
                colors: [Color(red: 0.35, green: 0.90, blue: 0.88),
                         Color(red: 0.92, green: 0.38, blue: 0.92),
                         Color(red: 0.22, green: 0.56, blue: 0.98)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var background: LinearGradient {
        switch self {
        case .warm:
            return LinearGradient(
                colors: [Color(red: 0.99, green: 0.96, blue: 0.94),
                         Color(red: 0.96, green: 0.93, blue: 0.98)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .ocean:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.98, blue: 1.00),
                         Color(red: 0.93, green: 0.98, blue: 0.97)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .dusk:
            return LinearGradient(
                colors: [Color(red: 0.09, green: 0.10, blue: 0.15),
                         Color(red: 0.16, green: 0.12, blue: 0.20)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .neon:
            return LinearGradient(
                colors: [Color(red: 0.06, green: 0.07, blue: 0.12),
                         Color(red: 0.10, green: 0.08, blue: 0.16)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    var glow: Color {
        switch self {
        case .warm: return Color(red: 0.98, green: 0.64, blue: 0.55)
        case .ocean: return Color(red: 0.30, green: 0.75, blue: 0.92)
        case .dusk: return Color(red: 0.32, green: 0.62, blue: 0.95)
        case .neon: return Color(red: 0.33, green: 0.90, blue: 0.86)
        }
    }

    var textColor: Color {
        switch self {
        case .warm, .ocean:
            return .black
        case .dusk, .neon:
            return .white
        }
    }

    var cardBackground: Color {
        switch self {
        case .warm, .ocean:
            return .white.opacity(0.85)
        case .dusk, .neon:
            return .white.opacity(0.08)
        }
    }

    var inputBackground: Color {
        switch self {
        case .warm, .ocean:
            return .white.opacity(0.9)
        case .dusk, .neon:
            return .white.opacity(0.12)
        }
    }

    var preferredScheme: ColorScheme {
        switch self {
        case .warm, .ocean:
            return .light
        case .dusk, .neon:
            return .dark
        }
    }
}
