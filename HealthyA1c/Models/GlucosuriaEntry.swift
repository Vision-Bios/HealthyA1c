import Foundation

struct GlucosuriaEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let mmol: Double
    let levelRaw: String

    init(id: UUID = UUID(), date: Date, level: GlucosuriaLevel) {
        self.id = id
        self.date = date
        self.mmol = level.mmol
        self.levelRaw = level.rawValue
    }

    init(id: UUID = UUID(), date: Date, mmol: Double, levelRaw: String) {
        self.id = id
        self.date = date
        self.mmol = mmol
        self.levelRaw = levelRaw
    }

    var level: GlucosuriaLevel {
        GlucosuriaLevel(rawValue: levelRaw) ?? .negative
    }
}
