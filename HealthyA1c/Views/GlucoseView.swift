import SwiftUI

struct GlucoseView: View {
    @StateObject private var viewModel = GlucoseViewModel()
    @State private var valueText = ""
    @State private var date = Date()
    @FocusState private var isValueFocused: Bool
    @State private var editingEntry: GlucoseEntry?
    @State private var isEditingGraph = false
    @State private var addPulse = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        ZStack {
            GlucoseThemeBackgroundView(palette: viewModel.selectedPalette)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Glucose")
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        HStack(spacing: 10) {
                            TextField("mg/dL", text: $valueText)
                                .keyboardType(.decimalPad)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(viewModel.selectedPalette.inputBackground,
                                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                )
                                .focused($isValueFocused)

                            Button("Add") { addEntry() }
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.selectedPalette.glow)
                            .disabled(parsedValue == nil)
                            .scaleEffect(addPulse ? 1.06 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: addPulse)
                        }

                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        Picker("Type", selection: $viewModel.selectedType) {
                            ForEach(GlucoseType.allCases) { type in
                                Text(type.title).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(viewModel.selectedPalette.glow)
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

                        GlucoseGraphView(entries: viewModel.filteredEntries,
                                         type: viewModel.selectedType,
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

                        ForEach(viewModel.filteredEntries.reversed()) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(String(format: "%.0f mg/dL", entry.value))
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(viewModel.selectedPalette.textColor)
                                    Text(entry.type.title)
                                        .font(.caption)
                                        .foregroundStyle(viewModel.selectedPalette.textColor.opacity(0.75))
                                }
                                Spacer()
                                Text(dateFormatter.string(from: entry.date))
                                    .font(.caption2)
                                    .foregroundStyle(viewModel.selectedPalette.textColor.opacity(0.65))
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

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Definitions")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        Text("Fasting: no calories for 8+ hours.")
                            .font(.caption2)
                            .foregroundStyle(viewModel.selectedPalette.textColor.opacity(0.75))
                        Text("Post‑meal: 2 hours after eating (withouth eating anything after that).")
                            .font(.caption2)
                            .foregroundStyle(viewModel.selectedPalette.textColor.opacity(0.75))
                        Text("Random: any time of day.")
                            .font(.caption2)
                            .foregroundStyle(viewModel.selectedPalette.textColor.opacity(0.75))

                        Text("Ranges:")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)
                        HStack(spacing: 6) {
                            Text("Fasting: Normal <100 mg/dL.")
                                .font(.caption2)
                                .foregroundStyle(viewModel.selectedPalette.textColor.opacity(0.75))
                            Link("View citation",
                                 destination: URL(string: "https://diabetes.org/about-diabetes/diagnosis")!)
                                .font(.caption2)
                                .foregroundStyle(viewModel.selectedPalette.glow)
                        }
                        HStack(spacing: 6) {
                            Text("Post‑meal: Normal <180 mg/dL.")
                                .font(.caption2)
                                .foregroundStyle(viewModel.selectedPalette.textColor.opacity(0.75))
                            Link("View citation",
                                 destination: URL(string: "https://diabetes.org/living-with-diabetes/treatment-care/checking-your-blood-sugar")!)
                                .font(.caption2)
                                .foregroundStyle(viewModel.selectedPalette.glow)
                        }
                    }
                }
                .padding()
            }
        }
        .environment(\.colorScheme, viewModel.selectedPalette.preferredScheme)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isValueFocused = false
                }
            }
        }
        .sheet(item: $editingEntry) { entry in
            GlucoseEditSheet(entry: entry,
                             palette: viewModel.selectedPalette,
                             onDelete: {
                                 viewModel.deleteEntry(entry)
                             }) { updated in
                viewModel.updateEntry(id: updated.id,
                                      date: updated.date,
                                      value: updated.value,
                                      type: updated.type)
            }
        }
    }

    private var parsedValue: Double? {
        Double(valueText.replacingOccurrences(of: ",", with: "."))
    }

    private func addEntry() {
        guard let value = parsedValue else { return }
        viewModel.addEntry(date: date, value: value, type: viewModel.selectedType)
        valueText = ""
        isValueFocused = false
        FunFeedback.shared.success()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
            addPulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            addPulse = false
        }
    }

    private func nextPalette(from palette: GlucosePalette) -> GlucosePalette {
        let all = GlucosePalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        return all[(index + 1) % all.count]
    }

    private func previousPalette(from palette: GlucosePalette) -> GlucosePalette {
        let all = GlucosePalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
    }

    private func nextTheme(from theme: GlucoseGraphTheme) -> GlucoseGraphTheme {
        let all = GlucoseGraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        return all[(index + 1) % all.count]
    }

    private func previousTheme(from theme: GlucoseGraphTheme) -> GlucoseGraphTheme {
        let all = GlucoseGraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
    }
}

#Preview {
    GlucoseView()
}

private struct GlucoseEditSheet: View {
    let entry: GlucoseEntry
    let palette: GlucosePalette
    let onDelete: () -> Void
    let onSave: (GlucoseEntry) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var valueText: String
    @State private var date: Date
    @State private var type: GlucoseType

    init(entry: GlucoseEntry,
         palette: GlucosePalette,
         onDelete: @escaping () -> Void,
         onSave: @escaping (GlucoseEntry) -> Void) {
        self.entry = entry
        self.palette = palette
        self.onDelete = onDelete
        self.onSave = onSave
        _valueText = State(initialValue: String(format: "%.0f", entry.value))
        _date = State(initialValue: entry.date)
        _type = State(initialValue: entry.type)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("mg/dL", text: $valueText)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Picker("Type", selection: $type) {
                    ForEach(GlucoseType.allCases) { t in
                        Text(t.title).tag(t)
                    }
                }
            }
            .navigationTitle("Edit Glucose")
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
                        guard let value = Double(valueText.replacingOccurrences(of: ",", with: ".")) else { return }
                        onSave(GlucoseEntry(id: entry.id, date: date, value: value, type: type))
                        dismiss()
                    }
                }
            }
        }
        .tint(palette.glow)
    }
}
