import Foundation

enum CarbStatus: String, CaseIterable, Identifiable, Codable {
    case zeroCarbs
    case carbsPresent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .zeroCarbs: return "Zero carbs"
        case .carbsPresent: return "Carbs"
        }
    }
}

struct MealEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var zeroCarbsCount: Int
    var carbsCount: Int

    init(id: UUID = UUID(), date: Date, zeroCarbsCount: Int, carbsCount: Int) {
        self.id = id
        self.date = date
        self.zeroCarbsCount = zeroCarbsCount
        self.carbsCount = carbsCount
    }
}
