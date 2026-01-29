import Foundation
import Combine

final class FastingViewModel: ObservableObject {
    @Published private(set) var entries: [FastingEntry] = []
    @Published var selectedTheme: FastingGraphTheme {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: "fastingGraphTheme") }
    }
    @Published var selectedPalette: FastingPalette {
        didSet { UserDefaults.standard.set(selectedPalette.rawValue, forKey: "fastingGraphPalette") }
    }

    @Published var activeStartDate: Date? {
        didSet { storeActiveStart(activeStartDate) }
    }

    private let store = FastingStore.shared
    private let activeKey = "fastingActiveStart"
    private let formatter = ISO8601DateFormatter()

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "fastingGraphTheme")
        let savedPalette = UserDefaults.standard.string(forKey: "fastingGraphPalette")
        self.selectedTheme = FastingGraphTheme(rawValue: savedTheme ?? "") ?? .pulse
        self.selectedPalette = FastingPalette(rawValue: savedPalette ?? "") ?? .eclipse
        self.activeStartDate = loadActiveStart()
        load()
    }

    func load() {
        entries = store.load().sorted { $0.date < $1.date }
    }

    func addEntry(date: Date, hours: Double) {
        let entry = FastingEntry(date: date, hours: hours)
        entries.append(entry)
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }

    func deleteEntry(_ entry: FastingEntry) {
        entries.removeAll { $0.id == entry.id }
        store.save(entries)
    }

    func updateEntry(id: UUID, date: Date, hours: Double) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index] = FastingEntry(id: id, date: date, hours: hours)
        entries.sort { $0.date < $1.date }
        store.save(entries)
    }

    func startFast(at date: Date = Date()) {
        activeStartDate = date
    }

    func endFast(at date: Date = Date()) -> Double? {
        guard let start = activeStartDate else { return nil }
        let hours = max(0, date.timeIntervalSince(start) / 3600.0)
        activeStartDate = nil
        addEntry(date: date, hours: hours)
        return hours
    }

    func elapsedHours(now: Date) -> Double {
        guard let start = activeStartDate else { return 0 }
        return max(0, now.timeIntervalSince(start) / 3600.0)
    }

    private func storeActiveStart(_ date: Date?) {
        if let date {
            UserDefaults.standard.set(formatter.string(from: date), forKey: activeKey)
        } else {
            UserDefaults.standard.removeObject(forKey: activeKey)
        }
    }

    private func loadActiveStart() -> Date? {
        guard let raw = UserDefaults.standard.string(forKey: activeKey) else { return nil }
        return formatter.date(from: raw)
    }
}
