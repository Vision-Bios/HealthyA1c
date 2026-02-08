import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            TodaysFocusView()
                .tabItem {
                    Label("Focus", systemImage: "target")
                }

            PointsView()
                .tabItem {
                    Label("Points", systemImage: "star.circle")
                }

            ContentView()
                .tabItem {
                    Label("A1c", systemImage: "waveform.path.ecg")
                }

            MoreNativeView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle")
                }
        }
    }
}

#Preview {
    RootView()
}
