import Foundation

final class GlucosuriaStore {
    static let shared = GlucosuriaStore()

    private let fileName = "glucosuria_entries.json"

    private var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }

    func load() -> [GlucosuriaEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([GlucosuriaEntry].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ entries: [GlucosuriaEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Fail silently to avoid interrupting the user flow.
        }
    }
}
