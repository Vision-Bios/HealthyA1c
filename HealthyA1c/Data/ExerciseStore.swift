import Foundation

final class ExerciseStore {
    static let shared = ExerciseStore()

    private let fileName = "exercise_entries.json"

    private var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }

    func load() -> [ExerciseEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([ExerciseEntry].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ entries: [ExerciseEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Keep flow calm if save fails.
        }
    }
}
