import SwiftUI

struct TodaysFocusView: View {
    @StateObject private var viewModel = HbA1cViewModel()
    @StateObject private var goalsViewModel = AccomplishedGoalsViewModel()
    @AppStorage("todaysFocusDifficulty") private var difficultyRaw = Difficulty.medium.rawValue
    @AppStorage("todaysFocusCategory") private var categoryRaw = FocusCategory.walking.rawValue
    @State private var focusPulse = false

    private struct FocusItem {
        let title: String
        let detail: String
        let symbol: String
        let category: FocusCategory
    }

    private enum Difficulty: String, CaseIterable, Identifiable {
        case hardest
        case medium
        case easy
        case superEasy
        case justDoIt

        var id: String { rawValue }

        var title: String {
            switch self {
            case .hardest: return "Hard"
            case .medium: return "Medium"
            case .easy: return "Easy"
            case .superEasy: return "Super easy"
            case .justDoIt: return "Just do it"
            }
        }
    }

    private enum FocusCategory: String, CaseIterable, Identifiable {
        case fasting
        case diet
        case walking

        var id: String { rawValue }

        var title: String {
            switch self {
            case .fasting: return "Fasting"
            case .diet: return "Diet"
            case .walking: return "Walking"
            }
        }
    }

    private var latestEntry: HbA1cEntry? {
        viewModel.entries.max(by: { $0.date < $1.date })
    }

    private var hasEntry: Bool {
        latestEntry != nil
    }

    private var needsFocus: Bool {
        guard let value = latestEntry?.value else { return true }
        return value >= 6.5
    }

    private var selectedDifficulty: Difficulty {
        Difficulty(rawValue: difficultyRaw) ?? .medium
    }

    private var selectedCategory: FocusCategory {
        FocusCategory(rawValue: categoryRaw) ?? .walking
    }

    private func stepDifficulty(_ direction: Int) {
        let all = Difficulty.allCases
        guard let index = all.firstIndex(of: selectedDifficulty) else { return }
        let nextIndex = (index + direction + all.count) % all.count
        difficultyRaw = all[nextIndex].rawValue
    }

    private func stepCategory(_ direction: Int) {
        let all = FocusCategory.allCases
        guard let index = all.firstIndex(of: selectedCategory) else { return }
        let nextIndex = (index + direction + all.count) % all.count
        categoryRaw = all[nextIndex].rawValue
    }

    private var todayFocus: FocusItem {
        let options = focusOptions(for: selectedDifficulty, category: selectedCategory)
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return options[day % options.count]
    }

    private var isCompletedToday: Bool {
        goalsViewModel.hasCompletedToday(title: todayFocus.title)
    }

    private func focusOptions(for difficulty: Difficulty, category: FocusCategory) -> [FocusItem] {
        let allOptions: [FocusItem]
        switch difficulty {
        case .hardest:
            allOptions = [
                FocusItem(title: "Walk 60 minutes",
                          detail: "Split it up if you need to.",
                          symbol: "figure.walk",
                          category: .walking),
                FocusItem(title: "Fast 24 hours",
                          detail: "Hydrate well and keep it calm and steady.",
                          symbol: "timer",
                          category: .fasting),
                FocusItem(title: "Zero-carb meals only",
                          detail: "Stay clean and simple today.",
                          symbol: "leaf",
                          category: .diet)
            ]
        case .medium:
            allOptions = [
                FocusItem(title: "Walk 30 minutes",
                          detail: "Two short walks works great.",
                          symbol: "figure.walk",
                          category: .walking),
                FocusItem(title: "Fast 16 hours",
                          detail: "Keep your eating window tight today.",
                          symbol: "hourglass",
                          category: .fasting),
                FocusItem(title: "Max 1 meal with carbs",
                          detail: "The rest zero-carb if you can.",
                          symbol: "leaf",
                          category: .diet)
            ]
        case .easy:
            allOptions = [
                FocusItem(title: "Fast 8 hours",
                          detail: "Overnight counts.",
                          symbol: "hourglass",
                          category: .fasting),
                FocusItem(title: "Walk fast 15 minutes",
                          detail: "Short, brisk, and done.",
                          symbol: "figure.walk",
                          category: .walking),
                FocusItem(title: "Up to 2 carb meals + 1 treat",
                          detail: "One sugary snack or drink max.",
                          symbol: "cup.and.saucer",
                          category: .diet)
            ]
        case .superEasy:
            allOptions = [
                FocusItem(title: "Fast 4 hours",
                          detail: "Keep it light and easy.",
                          symbol: "hourglass",
                          category: .fasting),
                FocusItem(title: "Walk fast 10 minutes",
                          detail: "A quick burst today.",
                          symbol: "figure.walk",
                          category: .walking),
                FocusItem(title: "Max 2 carb meals + 2 snacks",
                          detail: "Two sugary snacks or drinks max.",
                          symbol: "takeoutbag.and.cup.and.straw",
                          category: .diet)
            ]
        case .justDoIt:
            allOptions = [
                FocusItem(title: "Run 5 minutes (safely)",
                          detail: "Go easy and listen to your body.",
                          symbol: "figure.run",
                          category: .walking),
                FocusItem(title: "Fast 1 hour",
                          detail: "A small win still counts.",
                          symbol: "timer",
                          category: .fasting),
                FocusItem(title: "Max 2 carb meals + 3 snacks",
                          detail: "Three sugary snacks or drinks max.",
                          symbol: "fork.knife",
                          category: .diet)
            ]
        }

        let filtered = allOptions.filter { $0.category == category }
        return filtered.isEmpty ? allOptions : filtered
    }

    var body: some View {
        ZStack {
            ThemeBackgroundView(palette: viewModel.selectedPalette)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Today's Focus")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(viewModel.selectedPalette.textColor)

                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Difficulty")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(viewModel.selectedPalette.textColor)
                                .frame(maxWidth: .infinity, alignment: .center)

                            HStack {
                                Spacer()
                                Button {
                                    stepDifficulty(-1)
                                } label: {
                                    Image(systemName: "chevron.up")
                                        .font(.caption.weight(.semibold))
                                        .padding(8)
                                        .background(viewModel.selectedPalette.inputBackground,
                                                    in: Circle())
                                }
                                .buttonStyle(.plain)
                                Spacer()
                            }

                            Picker("Difficulty", selection: $difficultyRaw) {
                                ForEach(Difficulty.allCases) { level in
                                    Text(level.title).tag(level.rawValue)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 130)
                            .clipped()

                            HStack {
                                Spacer()
                                Button {
                                    stepDifficulty(1)
                                } label: {
                                    Image(systemName: "chevron.down")
                                        .font(.caption.weight(.semibold))
                                        .padding(8)
                                        .background(viewModel.selectedPalette.inputBackground,
                                                    in: Circle())
                                }
                                .buttonStyle(.plain)
                                Spacer()
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(viewModel.selectedPalette.cardBackground,
                                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Category")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(viewModel.selectedPalette.textColor)
                                .frame(maxWidth: .infinity, alignment: .center)

                            HStack {
                                Spacer()
                                Button {
                                    stepCategory(-1)
                                } label: {
                                    Image(systemName: "chevron.up")
                                        .font(.caption.weight(.semibold))
                                        .padding(8)
                                        .background(viewModel.selectedPalette.inputBackground,
                                                    in: Circle())
                                }
                                .buttonStyle(.plain)
                                Spacer()
                            }

                            Picker("Category", selection: $categoryRaw) {
                                ForEach(FocusCategory.allCases) { category in
                                    Text(category.title).tag(category.rawValue)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 130)
                            .clipped()

                            HStack {
                                Spacer()
                                Button {
                                    stepCategory(1)
                                } label: {
                                    Image(systemName: "chevron.down")
                                        .font(.caption.weight(.semibold))
                                        .padding(8)
                                        .background(viewModel.selectedPalette.inputBackground,
                                                    in: Circle())
                                }
                                .buttonStyle(.plain)
                                Spacer()
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(viewModel.selectedPalette.cardBackground,
                                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your last A1c")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        if let entry = latestEntry {
                            Text(String(format: "%.1f%%", entry.value))
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundStyle(viewModel.selectedPalette.glow)

                            if entry.value >= 6.5 {
                                Text("Goal: below 6.5%")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(viewModel.selectedPalette.textColor)
                            } else {
                                Text("Below 6.5% - keep it steady")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(viewModel.selectedPalette.textColor)
                            }
                        } else {
                            Text("Add your first A1c to unlock focus")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(viewModel.selectedPalette.textColor)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(viewModel.selectedPalette.cardBackground,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Focus for today")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        if !hasEntry {
                            Text("Add your first A1c to get a focus goal.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else if needsFocus {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: todayFocus.symbol)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(viewModel.selectedPalette.glow)

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(todayFocus.title)
                                            .font(.title3.weight(.semibold))
                                            .foregroundStyle(viewModel.selectedPalette.textColor)
                                        Text(todayFocus.detail)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Button {
                                    goalsViewModel.addGoal(title: todayFocus.title,
                                                           detail: todayFocus.detail,
                                                           symbol: todayFocus.symbol)
                                    FunFeedback.shared.success()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                                        focusPulse = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        focusPulse = false
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 18, weight: .semibold))
                                        Text(isCompletedToday ? "Completed today" : "Tap when done")
                                            .font(.headline.weight(.semibold))
                                    }
                                    .foregroundStyle(viewModel.selectedPalette.textColor)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(isCompletedToday
                                                  ? viewModel.selectedPalette.glow.opacity(0.25)
                                                  : viewModel.selectedPalette.inputBackground)
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(isCompletedToday)
                                .scaleEffect(focusPulse ? 1.03 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.55), value: focusPulse)
                            }
                        } else {
                            Text("You're under 6.5% - choose any habit you want to reinforce today.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(viewModel.selectedPalette.cardBackground,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.load()
            goalsViewModel.load()
        }
    }
}

#Preview {
    TodaysFocusView()
}
