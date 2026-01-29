import SwiftUI

struct BodyMetricsView: View {
    @StateObject private var viewModel = BodyMetricsViewModel()
    @State private var weightText = ""
    @State private var date = Date()
    @AppStorage("bodyHeightValue") private var heightText = ""
    @AppStorage("bodyHeightFeet") private var heightFeetText = ""
    @AppStorage("bodyHeightInches") private var heightInchesText = ""
    @AppStorage("bodyHeightUnit") private var heightUnitRaw = HeightUnit.meters.rawValue
    @FocusState private var focusedField: Field?
    @State private var editingEntry: BodyMetricsEntry?

    private enum Field {
        case weight
        case height
    }

    private enum HeightUnit: String, CaseIterable, Identifiable {
        case meters
        case feetInches

        var id: String { rawValue }
        var title: String {
            switch self {
            case .meters: return "m"
            case .feetInches: return "ft & in"
            }
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        ZStack {
            BodyThemeBackgroundView(palette: viewModel.selectedPalette)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Body Weight")
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        HStack(spacing: 10) {
                            TextField("Weight", text: $weightText)
                                .keyboardType(.decimalPad)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(viewModel.selectedPalette.inputBackground,
                                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                )
                                .focused($focusedField, equals: .weight)

                            Button("Add") {
                                addEntry()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.selectedPalette.glow)
                            .disabled(parsedWeight == nil)
                        }

                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                if heightUnit == .meters {
                                    TextField("Height", text: $heightText)
                                        .keyboardType(.decimalPad)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(viewModel.selectedPalette.inputBackground,
                                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                        )
                                        .focused($focusedField, equals: .height)
                                } else {
                                    TextField("ft", text: $heightFeetText)
                                        .keyboardType(.numberPad)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(viewModel.selectedPalette.inputBackground,
                                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                        )
                                        .focused($focusedField, equals: .height)

                                    TextField("in", text: $heightInchesText)
                                        .keyboardType(.numberPad)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(viewModel.selectedPalette.inputBackground,
                                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                        )
                                        .focused($focusedField, equals: .height)
                                }
                            }

                            Picker("Unit", selection: $heightUnitRaw) {
                                ForEach(HeightUnit.allCases) { unit in
                                    Text(unit.title).tag(unit.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                            .tint(viewModel.selectedPalette.glow)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Graph")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        BodyGraphView(entries: viewModel.entries,
                                      theme: viewModel.selectedTheme,
                                      palette: viewModel.selectedPalette,
                                      healthyWeightRange: healthyWeightRange)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        Picker("Theme", selection: $viewModel.selectedTheme) {
                            ForEach(BodyGraphTheme.allCases) { theme in
                                Text(theme.title).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(viewModel.selectedPalette.glow)

                        Picker("Palette", selection: $viewModel.selectedPalette) {
                            ForEach(BodyPalette.allCases) { palette in
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

                        ForEach(viewModel.entries.reversed()) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(String(format: "%.1f lb", entry.weight))
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
                        Text("BMI = weight(kg) / height(m)²")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)
                        Text("Healthy range: 18.5–24.9. Dashed lines show your weight range.")
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
                    focusedField = nil
                }
            }
        }
        .sheet(item: $editingEntry) { entry in
            BodyWeightEditSheet(entry: entry,
                                palette: viewModel.selectedPalette,
                                onDelete: {
                                    viewModel.deleteEntry(entry)
                                }) { updated in
                viewModel.updateEntry(id: updated.id,
                                      date: updated.date,
                                      weight: updated.weight)
            }
        }
    }

    private var parsedWeight: Double? {
        Double(weightText.replacingOccurrences(of: ",", with: "."))
    }

    private var parsedHeight: Double? {
        Double(heightText.replacingOccurrences(of: ",", with: "."))
    }

    private var parsedFeet: Double? {
        Double(heightFeetText.replacingOccurrences(of: ",", with: "."))
    }

    private var parsedInches: Double? {
        Double(heightInchesText.replacingOccurrences(of: ",", with: "."))
    }

    private var heightUnit: HeightUnit {
        HeightUnit(rawValue: heightUnitRaw) ?? .meters
    }

    private var healthyWeightRange: ClosedRange<Double>? {
        let heightMeters: Double
        switch heightUnit {
        case .meters:
            guard let heightValue = parsedHeight, heightValue > 0 else { return nil }
            heightMeters = heightValue
        case .feetInches:
            guard let feet = parsedFeet, feet >= 0 else { return nil }
            let inches = parsedInches ?? 0
            let totalInches = (feet * 12.0) + inches
            guard totalInches > 0 else { return nil }
            heightMeters = totalInches * 0.0254
        }
        let lowerKg = 18.5 * heightMeters * heightMeters
        let upperKg = 24.9 * heightMeters * heightMeters
        let lowerLb = lowerKg * 2.20462
        let upperLb = upperKg * 2.20462
        return lowerLb...upperLb
    }

    private func addEntry() {
        guard let weight = parsedWeight else { return }
        viewModel.addEntry(date: date, weight: weight, bodyFat: 0)
        weightText = ""
        focusedField = nil
    }
}

#Preview {
    BodyMetricsView()
}

private struct BodyWeightEditSheet: View {
    let entry: BodyMetricsEntry
    let palette: BodyPalette
    let onDelete: () -> Void
    let onSave: (BodyMetricsEntry) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var weightText: String
    @State private var date: Date

    init(entry: BodyMetricsEntry,
         palette: BodyPalette,
         onDelete: @escaping () -> Void,
         onSave: @escaping (BodyMetricsEntry) -> Void) {
        self.entry = entry
        self.palette = palette
        self.onDelete = onDelete
        self.onSave = onSave
        _weightText = State(initialValue: String(format: "%.1f", entry.weight))
        _date = State(initialValue: entry.date)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Weight (lb)", text: $weightText)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Edit Weight")
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
                        guard let weight = Double(weightText.replacingOccurrences(of: ",", with: ".")) else { return }
                        onSave(BodyMetricsEntry(id: entry.id, date: date, weight: weight, bodyFat: 0))
                        dismiss()
                    }
                }
            }
        }
        .tint(palette.glow)
    }
}
