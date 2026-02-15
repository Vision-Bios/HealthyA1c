import Foundation

final class SleepStore {
    static let shared = SleepStore()

    private let fileName = "sleep_entries.json"

    private var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }

    func load() -> [SleepEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([SleepEntry].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ entries: [SleepEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Keep flow calm if save fails.
        }
    }
}
