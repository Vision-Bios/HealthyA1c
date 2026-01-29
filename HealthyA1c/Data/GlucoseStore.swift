import Foundation

final class GlucoseStore {
    static let shared = GlucoseStore()

    private let fileName = "glucose_entries.json"

    private var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }

    func load() -> [GlucoseEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([GlucoseEntry].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ entries: [GlucoseEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Keep flow calm if save fails.
        }
    }
}
