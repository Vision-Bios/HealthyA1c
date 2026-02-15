import Foundation
import Combine
import SwiftUI

final class SleepViewModel: ObservableObject {
    @Published private(set) var entries: [SleepEntry] = []
    @Published var selectedTheme: SleepGraphTheme {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: "sleepGraphTheme") }
    }
    @Published var selectedPalette: SleepPalette {
        didSet { UserDefaults.standard.set(selectedPalette.rawValue, forKey: "sleepGraphPalette") }
    }

    private let store = SleepStore.shared

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "sleepGraphTheme")
        let savedPalette = UserDefaults.standard.string(forKey: "sleepGraphPalette")
        self.selectedTheme = SleepGraphTheme(rawValue: savedTheme ?? "") ?? .pulse
        self.selectedPalette = SleepPalette(rawValue: savedPalette ?? "") ?? .dawn
        load()
    }

    func load() {
        entries = store.load().sorted { $0.date < $1.date }
    }

    @discardableResult
    func addHours(date: Date, hours: Double) -> Bool {
        guard hours > 0 else { return false }
        let day = Calendar.current.startOfDay(for: date)
        if let index = entries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
            withAnimation {
                entries[index].hours += hours
            }
        } else {
            let entry = SleepEntry(date: day, hours: hours)
            withAnimation {
                entries.append(entry)
            }
        }
        entries.sort { $0.date < $1.date }
        store.save(entries)
        return true
    }

    func deleteEntry(_ entry: SleepEntry) {
        entries.removeAll { $0.id == entry.id }
        store.save(entries)
    }

    func updateEntry(id: UUID, date: Date, hours: Double) {
        guard hours >= 0 else { return }
        let newDay = Calendar.current.startOfDay(for: date)
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }

        if let existingIndex = entries.firstIndex(where: {
            $0.id != id && Calendar.current.isDate($0.date, inSameDayAs: newDay)
        }) {
            withAnimation {
                entries[existingIndex].hours += hours
                entries.remove(at: index)
            }
        } else {
            entries[index] = SleepEntry(id: id, date: newDay, hours: hours)
        }
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }
}
