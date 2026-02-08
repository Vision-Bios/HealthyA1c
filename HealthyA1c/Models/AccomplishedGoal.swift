import Foundation

struct AccomplishedGoal: Identifiable, Codable {
    let id: UUID
    let date: Date
    let title: String
    let detail: String
    let symbol: String
    var notes: String

    init(id: UUID = UUID(),
         date: Date = Date(),
         title: String,
         detail: String,
         symbol: String,
         notes: String = "") {
        self.id = id
        self.date = date
        self.title = title
        self.detail = detail
        self.symbol = symbol
        self.notes = notes
    }
}
