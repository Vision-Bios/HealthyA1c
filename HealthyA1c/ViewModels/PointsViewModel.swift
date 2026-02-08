import Foundation
import Combine

final class PointsViewModel: ObservableObject {
    @Published private(set) var goalPoints = 0
    @Published private(set) var healthDataPoints = 0
    @Published private(set) var lifestylePoints = 0
    @Published private(set) var dietPoints = 0

    func load() {
        let goals = AccomplishedGoalsStore.shared.load()
        goalPoints = goals.count

        let a1cCount = HbA1cStore.shared.load().count
        let bodyCount = BodyMetricsStore.shared.load().count
        let glucoseCount = GlucoseStore.shared.load().count
        healthDataPoints = a1cCount + bodyCount + glucoseCount

        let walkingCount = ExerciseStore.shared.load().count
        lifestylePoints = walkingCount

        let fastingCount = FastingStore.shared.load().count
        let meals = MealsStore.shared.load()
        let mealsCount = meals.reduce(0) { $0 + $1.zeroCarbsCount + $1.carbsCount }
        dietPoints = fastingCount + mealsCount
    }

    var dataEntryPoints: Int {
        healthDataPoints + lifestylePoints + dietPoints
    }

    var totalPoints: Int {
        goalPoints + dataEntryPoints
    }
}
