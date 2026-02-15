import SwiftUI

enum SleepGraphTheme: String, CaseIterable, Identifiable {
    case pulse
    case steps
    case bars
    case orbit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pulse: return "Pulse"
        case .steps: return "Steps"
        case .bars: return "Bars"
        case .orbit: return "Orbit"
        }
    }
}

enum SleepPalette: String, CaseIterable, Identifiable {
    case dawn
    case mist
    case ember
    case neon

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dawn: return "Dawn"
        case .mist: return "Mist"
        case .ember: return "Ember"
        case .neon: return "Neon"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .dawn:
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.55, blue: 0.35),
                         Color(red: 0.95, green: 0.75, blue: 0.50),
                         Color(red: 0.55, green: 0.70, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .mist:
            return LinearGradient(
                colors: [Color(red: 0.20, green: 0.75, blue: 0.70),
                         Color(red: 0.55, green: 0.85, blue: 0.75),
                         Color(red: 0.25, green: 0.60, blue: 0.95)],
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
        case .neon:
            return LinearGradient(
                colors: [Color(red: 0.20, green: 0.90, blue: 0.80),
                         Color(red: 0.35, green: 0.55, blue: 0.98),
                         Color(red: 0.95, green: 0.40, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var background: LinearGradient {
        switch self {
        case .dawn:
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.96, blue: 0.94),
                         Color(red: 0.95, green: 0.94, blue: 0.98)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .mist:
            return LinearGradient(
                colors: [Color(red: 0.94, green: 0.98, blue: 0.98),
                         Color(red: 0.92, green: 0.96, blue: 0.93)],
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
        case .neon:
            return LinearGradient(
                colors: [Color(red: 0.04, green: 0.05, blue: 0.10),
                         Color(red: 0.08, green: 0.06, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    var glow: Color {
        switch self {
        case .dawn: return Color(red: 0.25, green: 0.60, blue: 0.95)
        case .mist: return Color(red: 0.30, green: 0.75, blue: 0.75)
        case .ember: return Color(red: 0.25, green: 0.60, blue: 0.95)
        case .neon: return Color(red: 0.30, green: 0.90, blue: 0.85)
        }
    }

    var textColor: Color {
        switch self {
        case .dawn, .mist:
            return .black
        case .ember, .neon:
            return .white
        }
    }

    var cardBackground: Color {
        switch self {
        case .dawn, .mist:
            return .white.opacity(0.85)
        case .ember, .neon:
            return .white.opacity(0.08)
        }
    }

    var inputBackground: Color {
        switch self {
        case .dawn, .mist:
            return .white.opacity(0.9)
        case .ember, .neon:
            return .white.opacity(0.12)
        }
    }

    var preferredScheme: ColorScheme {
        switch self {
        case .dawn, .mist:
            return .light
        case .ember, .neon:
            return .dark
        }
    }
}
