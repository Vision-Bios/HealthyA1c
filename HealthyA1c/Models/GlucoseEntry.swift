import Foundation

enum GlucoseType: String, CaseIterable, Identifiable, Codable {
    case fasting
    case postMeal
    case random

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fasting: return "Fasting"
        case .postMeal: return "Post-meal"
        case .random: return "Random"
        }
    }
}

struct GlucoseEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let value: Double
    let type: GlucoseType

    init(id: UUID = UUID(), date: Date, value: Double, type: GlucoseType) {
        self.id = id
        self.date = date
        self.value = value
        self.type = type
    }
}
