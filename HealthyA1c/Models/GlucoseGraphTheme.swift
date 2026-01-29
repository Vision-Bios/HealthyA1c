import SwiftUI

enum GlucoseGraphTheme: String, CaseIterable, Identifiable {
    case ribbon
    case steps
    case bars
    case orbit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ribbon: return "Ribbon"
        case .steps: return "Steps"
        case .bars: return "Bars"
        case .orbit: return "Orbit"
        }
    }
}

enum GlucosePalette: String, CaseIterable, Identifiable {
    case solar
    case aurora
    case magma
    case prism

    var id: String { rawValue }

    var title: String {
        switch self {
        case .solar: return "Solar"
        case .aurora: return "Aurora"
        case .magma: return "Magma"
        case .prism: return "Prism"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .solar:
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.55, blue: 0.22),
                         Color(red: 0.98, green: 0.80, blue: 0.35),
                         Color(red: 0.92, green: 0.36, blue: 0.58)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .aurora:
            return LinearGradient(
                colors: [Color(red: 0.25, green: 0.80, blue: 0.92),
                         Color(red: 0.55, green: 0.45, blue: 0.92),
                         Color(red: 0.90, green: 0.40, blue: 0.70)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .magma:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.30, blue: 0.35),
                         Color(red: 0.92, green: 0.50, blue: 0.20),
                         Color(red: 0.70, green: 0.15, blue: 0.35)],
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
        }
    }

    var background: LinearGradient {
        switch self {
        case .solar:
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.96, blue: 0.93),
                         Color(red: 0.96, green: 0.94, blue: 0.98)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .aurora:
            return LinearGradient(
                colors: [Color(red: 0.94, green: 0.98, blue: 0.99),
                         Color(red: 0.92, green: 0.96, blue: 0.98)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .magma:
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
        }
    }

    var glow: Color {
        switch self {
        case .solar: return Color(red: 0.98, green: 0.65, blue: 0.35)
        case .aurora: return Color(red: 0.40, green: 0.85, blue: 0.95)
        case .magma: return Color(red: 0.95, green: 0.40, blue: 0.38)
        case .prism: return Color(red: 0.45, green: 0.82, blue: 0.90)
        }
    }

    var textColor: Color {
        switch self {
        case .solar, .aurora:
            return .black
        case .magma, .prism:
            return .white
        }
    }

    var cardBackground: Color {
        switch self {
        case .solar, .aurora:
            return .white.opacity(0.85)
        case .magma, .prism:
            return .white.opacity(0.08)
        }
    }

    var inputBackground: Color {
        switch self {
        case .solar, .aurora:
            return .white.opacity(0.90)
        case .magma, .prism:
            return .white.opacity(0.10)
        }
    }

    var preferredScheme: ColorScheme {
        switch self {
        case .solar, .aurora:
            return .light
        case .magma, .prism:
            return .dark
        }
    }
}
