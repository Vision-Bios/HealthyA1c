import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    FastingView()
                } label: {
                    HStack {
                        Image(systemName: "timer")
                        Text("Fasting")
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("More")
        }
    }
}

#Preview {
    MoreView()
}
