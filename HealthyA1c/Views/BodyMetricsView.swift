import SwiftUI

struct BodyMetricsView: View {
    @StateObject private var viewModel = BodyMetricsViewModel()
    @State private var weightText = ""
    @State private var date = Date()
    @FocusState private var focusedField: Field?
    @State private var editingEntry: BodyMetricsEntry?
    @State private var isEditingGraph = false
    @State private var addPulse = false

    private enum Field {
        case weight
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

                            Button("Add") { addEntry() }
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.selectedPalette.glow)
                            .disabled(parsedWeight == nil)
                            .scaleEffect(addPulse ? 1.06 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: addPulse)
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

                        BodyGraphView(entries: viewModel.entries,
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

    private func addEntry() {
        guard let weight = parsedWeight else { return }
        viewModel.addEntry(date: date, weight: weight, bodyFat: 0)
        weightText = ""
        focusedField = nil
        FunFeedback.shared.success()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
            addPulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            addPulse = false
        }
    }

    private func nextPalette(from palette: BodyPalette) -> BodyPalette {
        let all = BodyPalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        return all[(index + 1) % all.count]
    }

    private func previousPalette(from palette: BodyPalette) -> BodyPalette {
        let all = BodyPalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
    }

    private func nextTheme(from theme: BodyGraphTheme) -> BodyGraphTheme {
        let all = BodyGraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        return all[(index + 1) % all.count]
    }

    private func previousTheme(from theme: BodyGraphTheme) -> BodyGraphTheme {
        let all = BodyGraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
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
