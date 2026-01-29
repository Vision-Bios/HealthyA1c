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
                colors: [Color(red: 0.94, green: 0.98, blue: 0.99),
                         Color(red: 0.92, green: 0.96, blue: 0.98)],
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
                colors: [Color(red: 0.95, green: 0.96, blue: 0.99),
                         Color(red: 0.94, green: 0.95, blue: 0.98)],
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
        switch self {
        case .aurora, .prism:
            return .black
        case .ember, .deep:
            return .white
        }
    }

    var cardBackground: Color {
        switch self {
        case .aurora, .prism:
            return .white.opacity(0.85)
        case .ember, .deep:
            return .white.opacity(0.08)
        }
    }

    var inputBackground: Color {
        switch self {
        case .aurora, .prism:
            return .white.opacity(0.90)
        case .ember, .deep:
            return .white.opacity(0.10)
        }
    }

    var preferredScheme: ColorScheme {
        switch self {
        case .aurora, .prism:
            return .light
        case .ember, .deep:
            return .dark
        }
    }
}
