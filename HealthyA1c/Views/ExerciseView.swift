import SwiftUI

struct ExerciseView: View {
    @StateObject private var viewModel = ExerciseViewModel()
    @State private var minutesText = ""
    @State private var date = Date()
    @State private var showSaveError = false
    @FocusState private var isMinutesFocused: Bool
    @State private var editingEntry: ExerciseEntry?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

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

                            Button("Add") {
                                addMinutes()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.selectedPalette.glow)
                            .disabled(parsedMinutes == nil)
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

                        ExerciseGraphView(entries: viewModel.entries,
                                          theme: viewModel.selectedTheme,
                                          palette: viewModel.selectedPalette)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        Picker("Theme", selection: $viewModel.selectedTheme) {
                            ForEach(ExerciseGraphTheme.allCases) { theme in
                                Text(theme.title).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(viewModel.selectedPalette.glow)

                        Picker("Palette", selection: $viewModel.selectedPalette) {
                            ForEach(ExercisePalette.allCases) { palette in
                                Text(palette.title).tag(palette)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(viewModel.selectedPalette.glow)
                    }

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
        } else {
            showSaveError = true
        }
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
