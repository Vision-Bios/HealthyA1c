import SwiftUI

struct MainTabsView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("A1c", systemImage: "waveform.path.ecg")
                }

            BodyMetricsView()
                .tabItem {
                    Label("Body", systemImage: "figure.walk")
                }

            GlucoseView()
                .tabItem {
                    Label("Glucose", systemImage: "drop.fill")
                }

            MealsView()
                .tabItem {
                    Label("Diet", systemImage: "fork.knife")
                }

            ExerciseView()
                .tabItem {
                    Label("Walk", systemImage: "figure.walk.circle")
                }

            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle")
                }
        }
    }
}

#Preview {
    MainTabsView()
}
