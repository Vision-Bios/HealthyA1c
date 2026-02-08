import SwiftUI

struct MealsView: View {
    @StateObject private var viewModel = MealsViewModel()
    @State private var date = Date()
    @State private var carbs: CarbStatus = .zeroCarbs
    @State private var showSaveError = false
    @State private var editingEntry: MealEntry?
    @State private var isEditingGraph = false
    @State private var addPulse = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        ZStack {
            MealsThemeBackgroundView(palette: viewModel.selectedPalette)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Diet")
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        Picker("Carbs", selection: $carbs) {
                            ForEach(CarbStatus.allCases) { status in
                                Text(status.title).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(viewModel.selectedPalette.glow)

                        Button("Add") { addEntry() }
                        .buttonStyle(.borderedProminent)
                        .tint(viewModel.selectedPalette.glow)
                        .scaleEffect(addPulse ? 1.06 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.55), value: addPulse)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Graph")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        HStack(spacing: 8) {
                            Spacer()
                            if isEditingGraph {
                                Button("Done") {
                                    isEditingGraph = false
                                }
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(viewModel.selectedPalette.cardBackground,
                                            in: Capsule())
                                .foregroundStyle(viewModel.selectedPalette.textColor)
                            }

                            Button {
                                isEditingGraph.toggle()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "paintpalette.fill")
                                    Text("Customize")
                                }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(viewModel.selectedPalette.textColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(viewModel.selectedPalette.cardBackground,
                                            in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }

                        MealsGraphView(entries: viewModel.entries,
                                       theme: viewModel.selectedTheme,
                                       palette: viewModel.selectedPalette)
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 20)
                                .onEnded { value in
                                    guard isEditingGraph else { return }
                                    let dx = value.translation.width
                                    let dy = value.translation.height
                                    if abs(dx) > abs(dy) {
                                        if dx > 0 {
                                            viewModel.selectedPalette = nextPalette(from: viewModel.selectedPalette)
                                        } else {
                                            viewModel.selectedPalette = previousPalette(from: viewModel.selectedPalette)
                                        }
                                    } else {
                                        if dy < 0 {
                                            viewModel.selectedTheme = nextTheme(from: viewModel.selectedTheme)
                                        } else {
                                            viewModel.selectedTheme = previousTheme(from: viewModel.selectedTheme)
                                        }
                                    }
                                }
                        )
                    }

                    Text(isEditingGraph
                         ? "Swipe left/right to change color. Swipe up/down to change style."
                         : "Tap Customize to edit color and style.")
                        .font(.caption)
                        .foregroundStyle(viewModel.selectedPalette.textColor.opacity(0.75))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedPalette.cardBackground.opacity(0.9),
                                    in: Capsule())

                    VStack(alignment: .leading, spacing: 12) {
                        Text("History")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        ForEach(viewModel.entries.sorted(by: { $0.date > $1.date })) { entry in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(entry.zeroCarbsCount) zero · \(entry.carbsCount) carbs")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(viewModel.selectedPalette.textColor)
                                    Text(dateFormatter.string(from: entry.date))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(viewModel.selectedPalette.cardBackground,
                                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .onTapGesture {
                                editingEntry = entry
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deleteEntry(entry)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Goal: zero‑carb meals.")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)
                        Text("Track meals per day and mark carbs or zero carbs.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
        }
        .environment(\.colorScheme, viewModel.selectedPalette.preferredScheme)
        .alert("Couldn’t save the meal", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please try again.")
        }
        .sheet(item: $editingEntry) { entry in
            MealsEditSheet(entry: entry,
                           palette: viewModel.selectedPalette,
                           onDelete: {
                               viewModel.deleteEntry(entry)
                           }) { updated in
                viewModel.updateEntry(id: updated.id,
                                      date: updated.date,
                                      zeroCarbs: updated.zeroCarbsCount,
                                      carbs: updated.carbsCount)
            }
        }
    }

    private func addEntry() {
        let saved = viewModel.addEntry(date: date, count: 1, carbs: carbs)
        if saved {
            FunFeedback.shared.success()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                addPulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                addPulse = false
            }
        } else {
            showSaveError = true
            FunFeedback.shared.warning()
        }
    }

    private func nextPalette(from palette: MealsPalette) -> MealsPalette {
        let all = MealsPalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        return all[(index + 1) % all.count]
    }

    private func previousPalette(from palette: MealsPalette) -> MealsPalette {
        let all = MealsPalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
    }

    private func nextTheme(from theme: MealsGraphTheme) -> MealsGraphTheme {
        let all = MealsGraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        return all[(index + 1) % all.count]
    }

    private func previousTheme(from theme: MealsGraphTheme) -> MealsGraphTheme {
        let all = MealsGraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
    }
}

#Preview {
    MealsView()
}

private struct MealsEditSheet: View {
    let entry: MealEntry
    let palette: MealsPalette
    let onDelete: () -> Void
    let onSave: (MealEntry) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var date: Date
    @State private var zeroText: String
    @State private var carbsText: String

    init(entry: MealEntry,
         palette: MealsPalette,
         onDelete: @escaping () -> Void,
         onSave: @escaping (MealEntry) -> Void) {
        self.entry = entry
        self.palette = palette
        self.onDelete = onDelete
        self.onSave = onSave
        _date = State(initialValue: entry.date)
        _zeroText = State(initialValue: String(entry.zeroCarbsCount))
        _carbsText = State(initialValue: String(entry.carbsCount))
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Zero‑carb meals", text: $zeroText)
                    .keyboardType(.numberPad)
                TextField("Carb meals", text: $carbsText)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Edit Diet")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Delete", role: .destructive) {
                        onDelete()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let zero = Int(zeroText), let carbs = Int(carbsText) else { return }
                        onSave(MealEntry(id: entry.id, date: date, zeroCarbsCount: zero, carbsCount: carbs))
                        dismiss()
                    }
                }
            }
        }
        .tint(palette.glow)
    }
}
