import SwiftUI

struct FastingView: View {
    @StateObject private var viewModel = FastingViewModel()
    @AppStorage("fastingGoalHours") private var goalHoursRaw = FastingGoal.hour24.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var editingEntry: FastingEntry?

    private enum FastingGoal: String, CaseIterable, Identifiable {
        case hour24
        case hour16
        case custom

        var id: String { rawValue }

        var title: String {
            switch self {
            case .hour24: return "24h"
            case .hour16: return "16h"
            case .custom: return "Timer"
            }
        }

        var hours: Double? {
            switch self {
            case .hour24: return 24
            case .hour16: return 16
            case .custom: return nil
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
            FastingThemeBackgroundView(palette: viewModel.selectedPalette)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Capsule()
                        .fill(.white.opacity(0.25))
                        .frame(width: 46, height: 5)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Fasting")
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        Picker("Goal", selection: $goalHoursRaw) {
                            ForEach(FastingGoal.allCases) { goal in
                                Text(goal.title).tag(goal.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(viewModel.selectedPalette.glow)

                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            let elapsed = viewModel.elapsedHours(now: context.date)
                            let goalHours = selectedGoal.hours
                            let remaining = goalHours.map { max($0 - elapsed, 0) }

                            VStack(alignment: .leading, spacing: 8) {
                                Text(viewModel.activeStartDate == nil ? "Not fasting" : "Fasting now")
                                    .font(.headline)
                                    .foregroundStyle(viewModel.selectedPalette.textColor)

                                if let remaining {
                                    Text("Remaining \(formatDuration(remaining))")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(viewModel.selectedPalette.textColor)

                                    Text(formatCountdown(remaining))
                                        .font(.title2.weight(.semibold))
                                        .foregroundStyle(viewModel.selectedPalette.textColor)

                                    ProgressView(value: min(elapsed / max(remaining + elapsed, 0.01), 1.0))
                                        .tint(viewModel.selectedPalette.glow)
                                } else {
                                    Text("Elapsed \(formatDuration(elapsed))")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(viewModel.selectedPalette.textColor)

                                    Text(formatCountdown(elapsed))
                                        .font(.title2.weight(.semibold))
                                        .foregroundStyle(viewModel.selectedPalette.textColor)
                                }
                            }
                            .padding(12)
                            .background(viewModel.selectedPalette.cardBackground,
                                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }

                        if viewModel.activeStartDate == nil {
                            Button("Start") {
                                viewModel.startFast()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.selectedPalette.glow)
                        } else {
                            Button("End & Save") {
                                _ = viewModel.endFast()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.selectedPalette.glow)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Graph")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        FastingGraphView(entries: viewModel.entries,
                                         theme: viewModel.selectedTheme,
                                         palette: viewModel.selectedPalette)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)

                        Picker("Theme", selection: $viewModel.selectedTheme) {
                            ForEach(FastingGraphTheme.allCases) { theme in
                                Text(theme.title).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(viewModel.selectedPalette.glow)

                        Picker("Palette", selection: $viewModel.selectedPalette) {
                            ForEach(FastingPalette.allCases) { palette in
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
                                    Text(formatDuration(entry.hours))
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
                        Text("Goal rhythms:")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(viewModel.selectedPalette.textColor)
                        Text("24h fasts 2–3x / week or 16h fasts 5–6x / week.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
        }
        .environment(\.colorScheme, viewModel.selectedPalette.preferredScheme)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.height > 80 {
                        dismiss()
                    }
                }
        )
        .sheet(item: $editingEntry) { entry in
            FastingEditSheet(entry: entry,
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

    private var selectedGoal: FastingGoal {
        FastingGoal(rawValue: goalHoursRaw) ?? .hour24
    }

    private func formatDuration(_ hours: Double) -> String {
        let totalMinutes = max(0, Int(hours * 60))
        if totalMinutes < 60 {
            return "\(totalMinutes) min"
        }
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        if m == 0 {
            return "\(h) h"
        }
        return "\(h) h \(m) m"
    }

    private func formatCountdown(_ hours: Double) -> String {
        let totalSeconds = max(0, Int(hours * 3600))
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

#Preview {
    FastingView()
}

private struct FastingEditSheet: View {
    let entry: FastingEntry
    let palette: FastingPalette
    let onDelete: () -> Void
    let onSave: (FastingEntry) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var hoursText: String
    @State private var date: Date

    init(entry: FastingEntry,
         palette: FastingPalette,
         onDelete: @escaping () -> Void,
         onSave: @escaping (FastingEntry) -> Void) {
        self.entry = entry
        self.palette = palette
        self.onDelete = onDelete
        self.onSave = onSave
        _hoursText = State(initialValue: String(format: "%.1f", entry.hours))
        _date = State(initialValue: entry.date)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Hours", text: $hoursText)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Edit Fast")
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
                        guard let hours = Double(hoursText.replacingOccurrences(of: ",", with: ".")) else { return }
                        onSave(FastingEntry(id: entry.id, date: date, hours: hours))
                        dismiss()
                    }
                }
            }
        }
        .tint(palette.glow)
    }
}
