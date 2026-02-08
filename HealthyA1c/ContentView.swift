//
//  ContentView.swift
//  HealthyA1c
//
//  Created by Mohamad Alayouni on 1/20/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HbA1cViewModel()
    @State private var valueText = ""
    @State private var date = Date()
    @State private var onMeds = false
    @FocusState private var isValueFocused: Bool
    @State private var editingEntry: HbA1cEntry?
    @State private var isEditingGraph = false
    @State private var addPulse = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        ZStack {
            ThemeBackgroundView(palette: viewModel.selectedPalette)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("HbA1c")
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        HStack(spacing: 10) {
                            TextField("A1c", text: $valueText)
                                .keyboardType(.decimalPad)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(viewModel.selectedPalette.inputBackground,
                                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(.white.opacity(0.25), lineWidth: 0.5)
                                )
                                .focused($isValueFocused)

                            Button("Add") { addEntry() }
                            .buttonStyle(.borderedProminent)
                            .disabled(parsedValue == nil)
                            .scaleEffect(addPulse ? 1.06 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: addPulse)
                        }

                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        HStack {
                            Toggle("Meds", isOn: $onMeds)
                                .toggleStyle(.switch)
                                .tint(viewModel.selectedPalette.glow)
                                .foregroundStyle(viewModel.selectedPalette.textColor)
                        }
                        .padding(.horizontal, 12)
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

                        GraphView(entries: viewModel.entries,
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
                                    Text(String(format: "%.1f", entry.value))
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(viewModel.selectedPalette.textColor)
                                    Text(dateFormatter.string(from: entry.date))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if entry.onMeds {
                                    Text("Meds")
                                        .font(.caption2.weight(.semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(viewModel.selectedPalette.gradient.opacity(0.25),
                                                    in: Capsule())
                                }
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
                    isValueFocused = false
                }
            }
        }
        .sheet(item: $editingEntry) { entry in
            HbA1cEditSheet(entry: entry,
                           palette: viewModel.selectedPalette,
                           onDelete: {
                               viewModel.deleteEntry(entry)
                           }) { updated in
                viewModel.updateEntry(id: updated.id,
                                      date: updated.date,
                                      value: updated.value,
                                      onMeds: updated.onMeds)
            }
        }
    }

    private var parsedValue: Double? {
        Double(valueText.replacingOccurrences(of: ",", with: "."))
    }

    private func addEntry() {
        guard let value = parsedValue else { return }
        viewModel.addEntry(date: date, value: value, onMeds: onMeds)
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

    private func nextPalette(from palette: GraphPalette) -> GraphPalette {
        let all = GraphPalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        return all[(index + 1) % all.count]
    }

    private func previousPalette(from palette: GraphPalette) -> GraphPalette {
        let all = GraphPalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
    }

    private func nextTheme(from theme: GraphTheme) -> GraphTheme {
        let all = GraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        return all[(index + 1) % all.count]
    }

    private func previousTheme(from theme: GraphTheme) -> GraphTheme {
        let all = GraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
    }
}

#Preview {
    ContentView()
}

private struct HbA1cEditSheet: View {
    let entry: HbA1cEntry
    let palette: GraphPalette
    let onDelete: () -> Void
    let onSave: (HbA1cEntry) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var valueText: String
    @State private var date: Date
    @State private var onMeds: Bool

    init(entry: HbA1cEntry,
         palette: GraphPalette,
         onDelete: @escaping () -> Void,
         onSave: @escaping (HbA1cEntry) -> Void) {
        self.entry = entry
        self.palette = palette
        self.onDelete = onDelete
        self.onSave = onSave
        _valueText = State(initialValue: String(format: "%.1f", entry.value))
        _date = State(initialValue: entry.date)
        _onMeds = State(initialValue: entry.onMeds)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("HbA1c", text: $valueText)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Toggle("Meds", isOn: $onMeds)
            }
            .navigationTitle("Edit A1c")
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
                        onSave(HbA1cEntry(id: entry.id, date: date, value: value, onMeds: onMeds))
                        dismiss()
                    }
                }
            }
        }
        .tint(palette.glow)
    }
}
