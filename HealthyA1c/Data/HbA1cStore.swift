import Foundation

final class HbA1cStore {
    static let shared = HbA1cStore()

    private let fileName = "hba1c_entries.json"

    private var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }

    func load() -> [HbA1cEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([HbA1cEntry].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ entries: [HbA1cEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Fail silently to avoid interrupting the user flow.
        }
    }
}
