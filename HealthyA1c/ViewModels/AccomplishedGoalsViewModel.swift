import Foundation
import Combine

final class AccomplishedGoalsViewModel: ObservableObject {
    @Published private(set) var goals: [AccomplishedGoal] = []

    private let store = AccomplishedGoalsStore.shared

    init() {
        load()
    }

    func load() {
        goals = store.load().sorted { $0.date > $1.date }
    }

    func addGoal(title: String, detail: String, symbol: String, date: Date = Date()) {
        guard !hasCompletedToday(title: title, on: date) else { return }
        let goal = AccomplishedGoal(date: date, title: title, detail: detail, symbol: symbol)
        goals.insert(goal, at: 0)
        store.save(goals)
    }

    func updateNotes(id: UUID, notes: String) {
        guard let index = goals.firstIndex(where: { $0.id == id }) else { return }
        goals[index].notes = notes
        store.save(goals)
    }

    func hasCompletedToday(title: String, on date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        return goals.contains { calendar.isDate($0.date, inSameDayAs: date) && $0.title == title }
    }
}
