import SwiftUI

enum MealsGraphTheme: String, CaseIterable, Identifiable {
    case stacks
    case flow
    case orbit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stacks: return "Stacks"
        case .flow: return "Flow"
        case .orbit: return "Orbit"
        }
    }
}

enum MealsPalette: String, CaseIterable, Identifiable {
    case aurora
    case ember
    case prism
    case glass

    var id: String { rawValue }

    var title: String {
        switch self {
        case .aurora: return "Aurora"
        case .ember: return "Ember"
        case .prism: return "Prism"
        case .glass: return "Glass"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .aurora:
            return LinearGradient(
                colors: [Color(red: 0.20, green: 0.85, blue: 0.90),
                         Color(red: 0.55, green: 0.45, blue: 0.95),
                         Color(red: 0.90, green: 0.40, blue: 0.70)],
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
        case .prism:
            return LinearGradient(
                colors: [Color(red: 0.20, green: 0.90, blue: 0.70),
                         Color(red: 0.25, green: 0.55, blue: 0.98),
                         Color(red: 0.95, green: 0.40, blue: 0.88)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .glass:
            return LinearGradient(
                colors: [Color(red: 0.30, green: 0.80, blue: 0.95),
                         Color(red: 0.90, green: 0.45, blue: 0.80),
                         Color(red: 0.98, green: 0.75, blue: 0.30)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var background: LinearGradient {
        switch self {
        case .aurora:
            return LinearGradient(
                colors: [Color(red: 0.05, green: 0.06, blue: 0.10),
                         Color(red: 0.10, green: 0.07, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .ember:
            return LinearGradient(
                colors: [Color(red: 0.08, green: 0.05, blue: 0.06),
                         Color(red: 0.14, green: 0.06, blue: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .prism:
            return LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.10),
                         Color(red: 0.09, green: 0.06, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .glass:
            return LinearGradient(
                colors: [Color(red: 0.07, green: 0.08, blue: 0.12),
                         Color(red: 0.10, green: 0.08, blue: 0.16)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    var glow: Color {
        switch self {
        case .aurora: return Color(red: 0.40, green: 0.85, blue: 0.95)
        case .ember: return Color(red: 0.98, green: 0.60, blue: 0.45)
        case .prism: return Color(red: 0.45, green: 0.82, blue: 0.90)
        case .glass: return Color(red: 0.55, green: 0.80, blue: 0.95)
        }
    }

    var textColor: Color { .white }
    var cardBackground: Color { .white.opacity(0.08) }
    var inputBackground: Color { .white.opacity(0.10) }
    var preferredScheme: ColorScheme { .dark }
}
