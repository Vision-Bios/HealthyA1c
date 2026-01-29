import Foundation

final class BodyMetricsStore {
    static let shared = BodyMetricsStore()

    private let fileName = "body_metrics_entries.json"

    private var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }

    func load() -> [BodyMetricsEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([BodyMetricsEntry].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ entries: [BodyMetricsEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Fail silently to keep the flow calm.
        }
    }
}
