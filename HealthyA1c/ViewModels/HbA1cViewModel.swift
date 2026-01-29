import Foundation
import SwiftUI
import Combine


final class HbA1cViewModel: ObservableObject {
    @Published private(set) var entries: [HbA1cEntry] = []
    @Published var selectedTheme: GraphTheme {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: "graphTheme") }
    }
    @Published var selectedPalette: GraphPalette {
        didSet { UserDefaults.standard.set(selectedPalette.rawValue, forKey: "graphPalette") }
    }

    private let store = HbA1cStore.shared

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "graphTheme")
        let savedPalette = UserDefaults.standard.string(forKey: "graphPalette")
        self.selectedTheme = GraphTheme(rawValue: savedTheme ?? "") ?? .journey
        self.selectedPalette = GraphPalette(rawValue: savedPalette ?? "") ?? .warm
        load()
    }

    func load() {
        entries = store.load().sorted { $0.date < $1.date }
    }

    func addEntry(date: Date, value: Double, onMeds: Bool) {
        let entry = HbA1cEntry(date: date, value: value, onMeds: onMeds)
        entries.append(entry)
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }

    func deleteEntry(_ entry: HbA1cEntry) {
        entries.removeAll { $0.id == entry.id }
        store.save(entries)
    }

    func updateEntry(id: UUID, date: Date, value: Double, onMeds: Bool) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index] = HbA1cEntry(id: id, date: date, value: value, onMeds: onMeds)
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }
}
