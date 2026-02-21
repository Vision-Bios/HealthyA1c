import Foundation
import Combine
import SwiftUI

final class MealsViewModel: ObservableObject {
    @Published private(set) var entries: [MealEntry] = []
    @Published var selectedTheme: MealsGraphTheme {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: "mealsGraphTheme") }
    }
    @Published var selectedPalette: MealsPalette {
        didSet { UserDefaults.standard.set(selectedPalette.rawValue, forKey: "mealsGraphPalette") }
    }

    private let store = MealsStore.shared

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "mealsGraphTheme")
        let savedPalette = UserDefaults.standard.string(forKey: "mealsGraphPalette")
        self.selectedTheme = MealsGraphTheme(rawValue: savedTheme ?? "") ?? .stacks
        self.selectedPalette = MealsPalette(rawValue: savedPalette ?? "") ?? .aurora
        load()
    }

    func load() {
        entries = store.load().sorted { $0.date < $1.date }
    }

    @discardableResult
    func addItemCount(date: Date, count: Int) -> Bool {
        guard count > 0 else { return false }
        let day = Calendar.current.startOfDay(for: date)
        if let index = entries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
            withAnimation {
                entries[index].carbsCount += count
                entries[index].zeroCarbsCount = 0
            }
        } else {
            let entry = MealEntry(date: day, zeroCarbsCount: 0, carbsCount: count)
            withAnimation {
                entries.append(entry)
            }
        }
        entries.sort { $0.date < $1.date }
        store.save(entries)
        return true
    }

    func deleteEntry(_ entry: MealEntry) {
        entries.removeAll { $0.id == entry.id }
        store.save(entries)
    }

    func updateEntry(id: UUID, date: Date, count: Int) {
        guard count >= 0 else { return }
        let newDay = Calendar.current.startOfDay(for: date)
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }

        if let existingIndex = entries.firstIndex(where: {
            $0.id != id && Calendar.current.isDate($0.date, inSameDayAs: newDay)
        }) {
            withAnimation {
                entries[existingIndex].carbsCount += count
                entries[existingIndex].zeroCarbsCount = 0
                entries.remove(at: index)
            }
        } else {
            entries[index] = MealEntry(id: id,
                                       date: newDay,
                                       zeroCarbsCount: 0,
                                       carbsCount: count)
        }
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }
}
