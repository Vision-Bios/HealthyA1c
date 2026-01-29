import Foundation

struct ExerciseEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var minutes: Int

    init(id: UUID = UUID(), date: Date, minutes: Int) {
        self.id = id
        self.date = date
        self.minutes = minutes
    }
}
