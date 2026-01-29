import Foundation
import Combine
import SwiftUI

final class ExerciseViewModel: ObservableObject {
    @Published private(set) var entries: [ExerciseEntry] = []
    @Published var selectedTheme: ExerciseGraphTheme {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: "exerciseGraphTheme") }
    }
    @Published var selectedPalette: ExercisePalette {
        didSet { UserDefaults.standard.set(selectedPalette.rawValue, forKey: "exerciseGraphPalette") }
    }

    private let store = ExerciseStore.shared

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "exerciseGraphTheme")
        let savedPalette = UserDefaults.standard.string(forKey: "exerciseGraphPalette")
        self.selectedTheme = ExerciseGraphTheme(rawValue: savedTheme ?? "") ?? .pulse
        self.selectedPalette = ExercisePalette(rawValue: savedPalette ?? "") ?? .dawn
        load()
    }

    func load() {
        entries = store.load().sorted { $0.date < $1.date }
    }

    @discardableResult
    func addMinutes(date: Date, minutes: Int) -> Bool {
        guard minutes > 0 else { return false }
        let day = Calendar.current.startOfDay(for: date)
        if let index = entries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
            withAnimation {
                entries[index].minutes += minutes
            }
        } else {
            let entry = ExerciseEntry(date: day, minutes: minutes)
            withAnimation {
                entries.append(entry)
            }
        }
        entries.sort { $0.date < $1.date }
        store.save(entries)
        return true
    }

    func deleteEntry(_ entry: ExerciseEntry) {
        entries.removeAll { $0.id == entry.id }
        store.save(entries)
    }

    func updateEntry(id: UUID, date: Date, minutes: Int) {
        guard minutes >= 0 else { return }
        let newDay = Calendar.current.startOfDay(for: date)
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }

        if let existingIndex = entries.firstIndex(where: {
            $0.id != id && Calendar.current.isDate($0.date, inSameDayAs: newDay)
        }) {
            withAnimation {
                entries[existingIndex].minutes += minutes
                entries.remove(at: index)
            }
        } else {
            entries[index] = ExerciseEntry(id: id, date: newDay, minutes: minutes)
        }
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }
}
