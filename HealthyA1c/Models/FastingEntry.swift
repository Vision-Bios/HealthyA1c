import Foundation

struct FastingEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let hours: Double

    init(id: UUID = UUID(), date: Date, hours: Double) {
        self.id = id
        self.date = date
        self.hours = hours
    }
}
