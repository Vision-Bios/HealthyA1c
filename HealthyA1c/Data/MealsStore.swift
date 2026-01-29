import Foundation

final class MealsStore {
    static let shared = MealsStore()

    private let fileName = "meal_day_entries.json"

    private var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }

    func load() -> [MealEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([MealEntry].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ entries: [MealEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Keep flow calm if save fails.
        }
    }
}
