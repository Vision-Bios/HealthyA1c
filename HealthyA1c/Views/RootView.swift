import SwiftUI

struct RootView: View {
    private enum ActiveGroup {
        case primary
        case secondary
    }

    private enum PrimaryTab: String, CaseIterable, Identifiable {
        case a1c
        case body
        case glucose

        var id: String { rawValue }
        var title: String {
            switch self {
            case .a1c: return "A1c"
            case .body: return "Body"
            case .glucose: return "Glucose"
            }
        }
    }

    private enum SecondaryTab: String, CaseIterable, Identifiable {
        case meals
        case walking
        case fasting

        var id: String { rawValue }
        var title: String {
            switch self {
            case .meals: return "Meals"
            case .walking: return "Walking"
            case .fasting: return "Fasting"
            }
        }
    }

    @State private var activeGroup: ActiveGroup = .primary
    @State private var primaryTab: PrimaryTab = .a1c
    @State private var secondaryTab: SecondaryTab = .meals

    var body: some View {
        ZStack {
            ZStack {
                switch activeGroup {
                case .primary:
                    primaryContent
                case .secondary:
                    secondaryContent
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                toggleBar(items: PrimaryTab.allCases,
                          selection: $primaryTab,
                          title: \.title,
                          symbol: primarySymbol(_:)) {
                    activeGroup = .primary
                }

                toggleBar(items: SecondaryTab.allCases,
                          selection: $secondaryTab,
                          title: \.title,
                          symbol: secondarySymbol(_:)) {
                    activeGroup = .secondary
                }
            }
            .padding(10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 6)
        }
    }

    @ViewBuilder
    private var primaryContent: some View {
        switch primaryTab {
        case .a1c:
            ContentView()
        case .body:
            BodyMetricsView()
        case .glucose:
            GlucoseView()
        }
    }

    @ViewBuilder
    private var secondaryContent: some View {
        switch secondaryTab {
        case .meals:
            MealsView()
        case .walking:
            ExerciseView()
        case .fasting:
            FastingView()
        }
    }

    private func toggleBar<T: Hashable>(items: [T],
                                        selection: Binding<T>,
                                        title: KeyPath<T, String>,
                                        symbol: @escaping (T) -> String,
                                        onSelect: @escaping () -> Void) -> some View {
        HStack(spacing: 10) {
            ForEach(items, id: \.self) { item in
                let isSelected = selection.wrappedValue == item
                Button {
                    selection.wrappedValue = item
                    onSelect()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: symbol(item))
                            .font(.system(size: 16, weight: .semibold))
                        Text(item[keyPath: title])
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(isSelected ? Color.white.opacity(0.18) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(
            LinearGradient(colors: [Color.black.opacity(0.35), Color.white.opacity(0.05)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func primarySymbol(_ tab: PrimaryTab) -> String {
        switch tab {
        case .a1c: return "waveform.path.ecg"
        case .body: return "figure.walk"
        case .glucose: return "drop.fill"
        }
    }

    private func secondarySymbol(_ tab: SecondaryTab) -> String {
        switch tab {
        case .meals: return "fork.knife"
        case .walking: return "figure.walk.circle"
        case .fasting: return "timer"
        }
    }
}

#Preview {
    RootView()
}
