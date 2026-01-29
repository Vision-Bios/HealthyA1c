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
    func addEntry(date: Date, count: Int, carbs: CarbStatus) -> Bool {
        guard count > 0 else { return false }
        let day = Calendar.current.startOfDay(for: date)
        if let index = entries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
            withAnimation {
                if carbs == .zeroCarbs {
                    entries[index].zeroCarbsCount += count
                } else {
                    entries[index].carbsCount += count
                }
            }
        } else {
            let zero = carbs == .zeroCarbs ? count : 0
            let carbsCount = carbs == .carbsPresent ? count : 0
            let entry = MealEntry(date: day, zeroCarbsCount: zero, carbsCount: carbsCount)
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

    func updateEntry(id: UUID, date: Date, zeroCarbs: Int, carbs: Int) {
        guard zeroCarbs >= 0, carbs >= 0 else { return }
        let newDay = Calendar.current.startOfDay(for: date)
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }

        if let existingIndex = entries.firstIndex(where: {
            $0.id != id && Calendar.current.isDate($0.date, inSameDayAs: newDay)
        }) {
            withAnimation {
                entries[existingIndex].zeroCarbsCount += zeroCarbs
                entries[existingIndex].carbsCount += carbs
                entries.remove(at: index)
            }
        } else {
            entries[index] = MealEntry(id: id,
                                       date: newDay,
                                       zeroCarbsCount: zeroCarbs,
                                       carbsCount: carbs)
        }
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }
}
