import SwiftUI

struct SleepView: View {
    @StateObject private var viewModel = SleepViewModel()
    @State private var hoursText = ""
    @State private var date = Date()
    @State private var showSaveError = false
    @FocusState private var isHoursFocused: Bool
    @State private var editingEntry: SleepEntry?
    @State private var isEditingGraph = false
    @State private var addPulse = false

    private let quickHours = Array(1...9)
    private let quickGridColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        ZStack {
            SleepThemeBackgroundView(palette: viewModel.selectedPalette)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sleep")
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        HStack(spacing: 10) {
                            TextField("Hours", text: $hoursText)
                                .keyboardType(.decimalPad)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(viewModel.selectedPalette.inputBackground,
                                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                )
                                .focused($isHoursFocused)

                            Button("Add") { addHours() }
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.selectedPalette.glow)
                            .disabled(parsedHours == nil)
                            .scaleEffect(addPulse ? 1.06 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: addPulse)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick add")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(viewModel.selectedPalette.textColor)

                            LazyVGrid(columns: quickGridColumns, spacing: 8) {
                                ForEach(quickHours, id: \.self) { hours in
                                    Button("\(hours)") {
                                        hoursText = String(hours)
                                        isHoursFocused = false
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

                        SleepGraphView(entries: viewModel.entries,
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
                                    Text("\(formatHours(entry.hours)) hrs")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(viewModel.selectedPalette.textColor)
                                    Text(dateFormatter.string(from: entry.date))
                                        .font(.caption)
                                        .foregroundStyle(viewModel.selectedPalette.textColor.opacity(0.65))
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

                }
                .padding()
            }
        }
        .environment(\.colorScheme, viewModel.selectedPalette.preferredScheme)
        .alert("Couldn’t save", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter hours greater than zero.")
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isHoursFocused = false
                }
            }
        }
        .sheet(item: $editingEntry) { entry in
            SleepEditSheet(entry: entry,
                           palette: viewModel.selectedPalette,
                           onDelete: {
                               viewModel.deleteEntry(entry)
                           }) { updated in
                viewModel.updateEntry(id: updated.id,
                                      date: updated.date,
                                      hours: updated.hours)
            }
        }
    }

    private var parsedHours: Double? {
        Double(hoursText.trimmingCharacters(in: .whitespaces))
    }

    private var remainingText: String {
        let total = viewModel.entries
            .first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })?.hours ?? 0
        let remaining = max(7.0 - total, 0)
        return "\(formatHours(remaining)) hrs"
    }

    private func addHours() {
        guard let hours = parsedHours else { return }
        let saved = viewModel.addHours(date: date, hours: hours)
        if saved {
            hoursText = ""
            isHoursFocused = false
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

    private func nextPalette(from palette: SleepPalette) -> SleepPalette {
        let all = SleepPalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        return all[(index + 1) % all.count]
    }

    private func previousPalette(from palette: SleepPalette) -> SleepPalette {
        let all = SleepPalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
    }

    private func nextTheme(from theme: SleepGraphTheme) -> SleepGraphTheme {
        let all = SleepGraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        return all[(index + 1) % all.count]
    }

    private func previousTheme(from theme: SleepGraphTheme) -> SleepGraphTheme {
        let all = SleepGraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
    }

    private func formatHours(_ hours: Double) -> String {
        if abs(hours.rounded() - hours) < 0.01 {
            return String(format: "%.0f", hours)
        }
        return String(format: "%.1f", hours)
    }
}

#Preview {
    SleepView()
}

private struct SleepEditSheet: View {
    let entry: SleepEntry
    let palette: SleepPalette
    let onDelete: () -> Void
    let onSave: (SleepEntry) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var hoursText: String
    @State private var date: Date

    init(entry: SleepEntry,
         palette: SleepPalette,
         onDelete: @escaping () -> Void,
         onSave: @escaping (SleepEntry) -> Void) {
        self.entry = entry
        self.palette = palette
        self.onDelete = onDelete
        self.onSave = onSave
        _hoursText = State(initialValue: String(entry.hours))
        _date = State(initialValue: entry.date)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Hours", text: $hoursText)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Edit Sleep")
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
                        guard let hours = Double(hoursText) else { return }
                        onSave(SleepEntry(id: entry.id, date: date, hours: hours))
                        dismiss()
                    }
                }
            }
        }
        .tint(palette.glow)
    }
}
