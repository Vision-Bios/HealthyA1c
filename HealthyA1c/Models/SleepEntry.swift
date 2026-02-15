import Foundation

struct SleepEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var hours: Double

    init(id: UUID = UUID(), date: Date, hours: Double) {
        self.id = id
        self.date = date
        self.hours = hours
    }
}
