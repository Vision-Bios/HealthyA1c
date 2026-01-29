import Foundation
import Combine

final class GlucoseViewModel: ObservableObject {
    @Published private(set) var entries: [GlucoseEntry] = []
    @Published var selectedType: GlucoseType = .fasting
    @Published var selectedTheme: GlucoseGraphTheme {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: "glucoseGraphTheme") }
    }
    @Published var selectedPalette: GlucosePalette {
        didSet { UserDefaults.standard.set(selectedPalette.rawValue, forKey: "glucoseGraphPalette") }
    }

    private let store = GlucoseStore.shared

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "glucoseGraphTheme")
        let savedPalette = UserDefaults.standard.string(forKey: "glucoseGraphPalette")
        self.selectedTheme = GlucoseGraphTheme(rawValue: savedTheme ?? "") ?? .ribbon
        self.selectedPalette = GlucosePalette(rawValue: savedPalette ?? "") ?? .aurora
        load()
    }

    func load() {
        entries = store.load().sorted { $0.date < $1.date }
    }

    func addEntry(date: Date, value: Double, type: GlucoseType) {
        let entry = GlucoseEntry(date: date, value: value, type: type)
        entries.append(entry)
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }

    func deleteEntry(_ entry: GlucoseEntry) {
        entries.removeAll { $0.id == entry.id }
        store.save(entries)
    }

    func updateEntry(id: UUID, date: Date, value: Double, type: GlucoseType) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index] = GlucoseEntry(id: id, date: date, value: value, type: type)
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }

    var filteredEntries: [GlucoseEntry] {
        entries.filter { $0.type == selectedType }
    }
}
