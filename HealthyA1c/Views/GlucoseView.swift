import SwiftUI

struct GlucoseView: View {
    @StateObject private var viewModel = GlucoseViewModel()
    @State private var valueText = ""
    @State private var date = Date()
    @FocusState private var isValueFocused: Bool
    @State private var editingEntry: GlucoseEntry?

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

                            Button("Add") {
                                addEntry()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.selectedPalette.glow)
                            .disabled(parsedValue == nil)
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

                        GlucoseGraphView(entries: viewModel.filteredEntries,
                                         type: viewModel.selectedType,
                                         theme: viewModel.selectedTheme,
                                         palette: viewModel.selectedPalette)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        Picker("Theme", selection: $viewModel.selectedTheme) {
                            ForEach(GlucoseGraphTheme.allCases) { theme in
                                Text(theme.title).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(viewModel.selectedPalette.glow)

                        Picker("Palette", selection: $viewModel.selectedPalette) {
                            ForEach(GlucosePalette.allCases) { palette in
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

                        ForEach(viewModel.filteredEntries.reversed()) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(String(format: "%.0f mg/dL", entry.value))
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(viewModel.selectedPalette.textColor)
                                    Text(entry.type.title)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(dateFormatter.string(from: entry.date))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
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
                        Text("Fasting: no calories for 8+ hours.")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)
                        Text("Post‑meal: 2 hours after eating.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("Random: any time of day.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text("Ranges:")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)
                        Text("Fasting: Normal 70–99, Prediabetes 100–125, Diabetes ≥126 (2 tests).")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("Post‑meal: Normal <140, Prediabetes 140–199, Diabetes ≥200.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("Random: Normal typically <140, Diabetes likely ≥200.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
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
