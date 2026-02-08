import SwiftUI

enum GlucosuriaLevel: String, CaseIterable, Identifiable, Codable {
    case negative
    case trace
    case mmol15
    case mmol30
    case mmol60
    case mmol110

    var id: String { rawValue }

    var title: String {
        switch self {
        case .negative: return "Negative"
        case .trace: return "5 mmol/L"
        case .mmol15: return "15 mmol/L"
        case .mmol30: return "30 mmol/L"
        case .mmol60: return "60 mmol/L"
        case .mmol110: return "110 mmol/L"
        }
    }

    var mmol: Double {
        switch self {
        case .negative: return 0
        case .trace: return 5
        case .mmol15: return 15
        case .mmol30: return 30
        case .mmol60: return 60
        case .mmol110: return 110
        }
    }

    var color: Color {
        switch self {
        case .negative:
            return Color(red: 0.52, green: 0.80, blue: 0.90)
        case .trace:
            return Color(red: 0.67, green: 0.84, blue: 0.55)
        case .mmol15:
            return Color(red: 0.32, green: 0.64, blue: 0.35)
        case .mmol30:
            return Color(red: 0.78, green: 0.63, blue: 0.27)
        case .mmol60:
            return Color(red: 0.70, green: 0.45, blue: 0.26)
        case .mmol110:
            return Color(red: 0.44, green: 0.26, blue: 0.16)
        }
    }

    var uiColor: UIColor {
        UIColor(color)
    }
}
