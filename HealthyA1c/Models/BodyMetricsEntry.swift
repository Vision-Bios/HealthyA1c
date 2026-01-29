import Foundation

struct BodyMetricsEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let weight: Double
    let bodyFat: Double

    init(id: UUID = UUID(), date: Date, weight: Double, bodyFat: Double) {
        self.id = id
        self.date = date
        self.weight = weight
        self.bodyFat = bodyFat
    }
}
