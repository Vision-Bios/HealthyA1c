import Foundation

struct HbA1cEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let value: Double
    let onMeds: Bool

    init(id: UUID = UUID(), date: Date, value: Double, onMeds: Bool) {
        self.id = id
        self.date = date
        self.value = value
        self.onMeds = onMeds
    }
}
