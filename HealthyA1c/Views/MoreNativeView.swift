import SwiftUI

struct MoreNativeView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: BodyMetricsView()) {
                    Label("Body", systemImage: "figure.walk")
                }
                NavigationLink(destination: GlucoseView()) {
                    Label("Glucose", systemImage: "drop.fill")
                }
                NavigationLink(destination: GlucosuriaView()) {
                    Label("Glucosuria", systemImage: "testtube.2")
                }
                NavigationLink(destination: MealsView()) {
                    Label("Diet", systemImage: "fork.knife")
                }
                NavigationLink(destination: ExerciseView()) {
                    Label("Walking", systemImage: "figure.walk.circle")
                }
                NavigationLink(destination: FastingView()) {
                    Label("Fasting", systemImage: "timer")
                }
                NavigationLink(destination: AccomplishedGoalsView()) {
                    Label("Goals", systemImage: "checkmark.seal")
                }
            }
            .navigationTitle("More")
        }
    }
}

#Preview {
    MoreNativeView()
}
