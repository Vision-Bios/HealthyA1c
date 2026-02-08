import Foundation

final class AccomplishedGoalsStore {
    static let shared = AccomplishedGoalsStore()

    private let fileName = "accomplished_goals.json"

    private var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }

    func load() -> [AccomplishedGoal] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([AccomplishedGoal].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ goals: [AccomplishedGoal]) {
        do {
            let data = try JSONEncoder().encode(goals)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Fail silently to avoid interrupting the user flow.
        }
    }
}
