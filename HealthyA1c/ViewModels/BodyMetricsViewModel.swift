import Foundation
import Combine

final class BodyMetricsViewModel: ObservableObject {
    @Published private(set) var entries: [BodyMetricsEntry] = []
    @Published var selectedTheme: BodyGraphTheme {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: "bodyGraphTheme") }
    }
    @Published var selectedPalette: BodyPalette {
        didSet { UserDefaults.standard.set(selectedPalette.rawValue, forKey: "bodyGraphPalette") }
    }

    private let store = BodyMetricsStore.shared

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "bodyGraphTheme")
        let savedPalette = UserDefaults.standard.string(forKey: "bodyGraphPalette")
        self.selectedTheme = BodyGraphTheme(rawValue: savedTheme ?? "") ?? .pulse
        self.selectedPalette = BodyPalette(rawValue: savedPalette ?? "") ?? .aurora
        load()
    }

    func load() {
        entries = store.load().sorted { $0.date < $1.date }
    }

    func addEntry(date: Date, weight: Double, bodyFat: Double) {
        let entry = BodyMetricsEntry(date: date, weight: weight, bodyFat: bodyFat)
        entries.append(entry)
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }

    func deleteEntry(_ entry: BodyMetricsEntry) {
        entries.removeAll { $0.id == entry.id }
        store.save(entries)
    }

    func updateEntry(id: UUID, date: Date, weight: Double) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index] = BodyMetricsEntry(id: id, date: date, weight: weight, bodyFat: 0)
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }
}
