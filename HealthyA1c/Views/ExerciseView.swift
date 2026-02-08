import SwiftUI

struct ExerciseView: View {
    @StateObject private var viewModel = ExerciseViewModel()
    @State private var minutesText = ""
    @State private var date = Date()
    @State private var showSaveError = false
    @FocusState private var isMinutesFocused: Bool
    @State private var editingEntry: ExerciseEntry?
    @State private var isEditingGraph = false
    @State private var addPulse = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    private let quickMinutes = [60, 55, 50, 45, 40, 35, 30, 25, 20, 15, 10, 5]
    private let quickGridColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        ZStack {
            ExerciseThemeBackgroundView(palette: viewModel.selectedPalette)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Walking")
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        HStack(spacing: 10) {
                            TextField("Minutes", text: $minutesText)
                                .keyboardType(.numberPad)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(viewModel.selectedPalette.inputBackground,
                                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                )
                                .focused($isMinutesFocused)

                            Button("Add") { addMinutes() }
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.selectedPalette.glow)
                            .disabled(parsedMinutes == nil)
                            .scaleEffect(addPulse ? 1.06 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: addPulse)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick add")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(viewModel.selectedPalette.textColor)

                            LazyVGrid(columns: quickGridColumns, spacing: 8) {
                                ForEach(quickMinutes, id: \.self) { minutes in
                                    Button("\(minutes)") {
                                        minutesText = String(minutes)
                                        isMinutesFocused = false
                                    }
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(viewModel.selectedPalette.textColor)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(viewModel.selectedPalette.inputBackground,
                                                in: Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(.white.opacity(0.15), lineWidth: 0.5)
                                    )
                                }
                            }
                        }

                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        HStack {
                            Text("Goal 60 min/day")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(viewModel.selectedPalette.textColor)
                            Spacer()
                            Text("Remaining \(remainingText)")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(viewModel.selectedPalette.textColor)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedPalette.cardBackground,
                                    in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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

                        ExerciseGraphView(entries: viewModel.entries,
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
                                    Text("\(entry.minutes) min")
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
                        Text("Goal: 60 minutes per day.")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)
                        Text("Add walks throughout the day; totals update for the same date.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
        }
        .environment(\.colorScheme, viewModel.selectedPalette.preferredScheme)
        .alert("Couldn’t save", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter minutes greater than zero.")
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isMinutesFocused = false
                }
            }
        }
        .sheet(item: $editingEntry) { entry in
            ExerciseEditSheet(entry: entry,
                              palette: viewModel.selectedPalette,
                              onDelete: {
                                  viewModel.deleteEntry(entry)
                              }) { updated in
                viewModel.updateEntry(id: updated.id,
                                      date: updated.date,
                                      minutes: updated.minutes)
            }
        }
    }

    private var parsedMinutes: Int? {
        Int(minutesText.trimmingCharacters(in: .whitespaces))
    }

    private var remainingText: String {
        let total = viewModel.entries
            .first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })?.minutes ?? 0
        return "\(max(60 - total, 0)) min"
    }

    private func addMinutes() {
        guard let minutes = parsedMinutes else { return }
        let saved = viewModel.addMinutes(date: date, minutes: minutes)
        if saved {
            minutesText = ""
            isMinutesFocused = false
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

    private func nextPalette(from palette: ExercisePalette) -> ExercisePalette {
        let all = ExercisePalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        return all[(index + 1) % all.count]
    }

    private func previousPalette(from palette: ExercisePalette) -> ExercisePalette {
        let all = ExercisePalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
    }

    private func nextTheme(from theme: ExerciseGraphTheme) -> ExerciseGraphTheme {
        let all = ExerciseGraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        return all[(index + 1) % all.count]
    }

    private func previousTheme(from theme: ExerciseGraphTheme) -> ExerciseGraphTheme {
        let all = ExerciseGraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
    }
}

#Preview {
    ExerciseView()
}

private struct ExerciseEditSheet: View {
    let entry: ExerciseEntry
    let palette: ExercisePalette
    let onDelete: () -> Void
    let onSave: (ExerciseEntry) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var minutesText: String
    @State private var date: Date

    init(entry: ExerciseEntry,
         palette: ExercisePalette,
         onDelete: @escaping () -> Void,
         onSave: @escaping (ExerciseEntry) -> Void) {
        self.entry = entry
        self.palette = palette
        self.onDelete = onDelete
        self.onSave = onSave
        _minutesText = State(initialValue: String(entry.minutes))
        _date = State(initialValue: entry.date)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Minutes", text: $minutesText)
                    .keyboardType(.numberPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Edit Walk")
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
                        guard let minutes = Int(minutesText) else { return }
                        onSave(ExerciseEntry(id: entry.id, date: date, minutes: minutes))
                        dismiss()
                    }
                }
            }
        }
        .tint(palette.glow)
    }
}
