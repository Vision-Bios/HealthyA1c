import Foundation
import Combine

final class GlucosuriaViewModel: ObservableObject {
    @Published private(set) var entries: [GlucosuriaEntry] = []

    private let store = GlucosuriaStore.shared

    init() {
        load()
    }

    func load() {
        entries = store.load().sorted { $0.date < $1.date }
    }

    func addEntry(date: Date, level: GlucosuriaLevel) {
        let entry = GlucosuriaEntry(date: date, level: level)
        entries.append(entry)
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }

    func deleteEntry(_ entry: GlucosuriaEntry) {
        entries.removeAll { $0.id == entry.id }
        store.save(entries)
    }

    func updateEntry(id: UUID, date: Date, level: GlucosuriaLevel) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index] = GlucosuriaEntry(id: id, date: date, level: level)
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }
}
