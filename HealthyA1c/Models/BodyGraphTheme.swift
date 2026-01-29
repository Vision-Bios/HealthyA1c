import SwiftUI

enum BodyGraphTheme: String, CaseIterable, Identifiable {
    case pulse
    case tide
    case orbits
    case strata

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pulse: return "Pulse"
        case .tide: return "Tide"
        case .orbits: return "Orbits"
        case .strata: return "Strata"
        }
    }
}

enum BodyPalette: String, CaseIterable, Identifiable {
    case aurora
    case ember
    case deep
    case prism

    var id: String { rawValue }

    var title: String {
        switch self {
        case .aurora: return "Aurora"
        case .ember: return "Ember"
        case .deep: return "Deep"
        case .prism: return "Prism"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .aurora:
            return LinearGradient(
                colors: [Color(red: 0.25, green: 0.75, blue: 0.95),
                         Color(red: 0.62, green: 0.38, blue: 0.95),
                         Color(red: 0.95, green: 0.35, blue: 0.60)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ember:
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.45, blue: 0.28),
                         Color(red: 0.98, green: 0.68, blue: 0.35),
                         Color(red: 0.90, green: 0.22, blue: 0.50)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .deep:
            return LinearGradient(
                colors: [Color(red: 0.10, green: 0.15, blue: 0.40),
                         Color(red: 0.20, green: 0.35, blue: 0.85),
                         Color(red: 0.45, green: 0.15, blue: 0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .prism:
            return LinearGradient(
                colors: [Color(red: 0.18, green: 0.88, blue: 0.70),
                         Color(red: 0.20, green: 0.50, blue: 0.98),
                         Color(red: 0.95, green: 0.38, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var background: LinearGradient {
        switch self {
        case .aurora:
            return LinearGradient(
                colors: [Color(red: 0.05, green: 0.08, blue: 0.12),
                         Color(red: 0.10, green: 0.07, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .ember:
            return LinearGradient(
                colors: [Color(red: 0.10, green: 0.08, blue: 0.08),
                         Color(red: 0.18, green: 0.10, blue: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .deep:
            return LinearGradient(
                colors: [Color(red: 0.03, green: 0.04, blue: 0.08),
                         Color(red: 0.08, green: 0.06, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .prism:
            return LinearGradient(
                colors: [Color(red: 0.06, green: 0.05, blue: 0.10),
                         Color(red: 0.08, green: 0.06, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    var glow: Color {
        switch self {
        case .aurora: return Color(red: 0.40, green: 0.80, blue: 0.98)
        case .ember: return Color(red: 0.98, green: 0.55, blue: 0.40)
        case .deep: return Color(red: 0.50, green: 0.35, blue: 0.95)
        case .prism: return Color(red: 0.45, green: 0.82, blue: 0.90)
        }
    }

    var textColor: Color {
        return .white
    }

    var cardBackground: Color {
        return .white.opacity(0.08)
    }

    var inputBackground: Color {
        return .white.opacity(0.10)
    }

    var preferredScheme: ColorScheme {
        return .dark
    }
}
