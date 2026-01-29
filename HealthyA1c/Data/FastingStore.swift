import Foundation

final class FastingStore {
    static let shared = FastingStore()

    private let fileName = "fasting_entries.json"

    private var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }

    func load() -> [FastingEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([FastingEntry].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ entries: [FastingEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Keep flow calm if save fails.
        }
    }
}
