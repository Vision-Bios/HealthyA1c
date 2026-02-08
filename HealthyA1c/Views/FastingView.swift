import SwiftUI

struct FastingView: View {
    @StateObject private var viewModel = FastingViewModel()
    @AppStorage("fastingGoalHours") private var goalHoursRaw = FastingGoal.hour24.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var editingEntry: FastingEntry?
    @State private var isEditingGraph = false
    @State private var actionPulse = false

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
                                triggerActionFeedback()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.selectedPalette.glow)
                            .scaleEffect(actionPulse ? 1.06 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: actionPulse)
                        } else {
                            Button("End & Save") {
                                _ = viewModel.endFast()
                                triggerActionFeedback()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.selectedPalette.glow)
                            .scaleEffect(actionPulse ? 1.06 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: actionPulse)
                        }
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

                        FastingGraphView(entries: viewModel.entries,
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

    private func triggerActionFeedback() {
        FunFeedback.shared.heavyPulse()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
            actionPulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            actionPulse = false
        }
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

    private func nextPalette(from palette: FastingPalette) -> FastingPalette {
        let all = FastingPalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        return all[(index + 1) % all.count]
    }

    private func previousPalette(from palette: FastingPalette) -> FastingPalette {
        let all = FastingPalette.allCases
        guard let index = all.firstIndex(of: palette) else { return palette }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
    }

    private func nextTheme(from theme: FastingGraphTheme) -> FastingGraphTheme {
        let all = FastingGraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        return all[(index + 1) % all.count]
    }

    private func previousTheme(from theme: FastingGraphTheme) -> FastingGraphTheme {
        let all = FastingGraphTheme.allCases
        guard let index = all.firstIndex(of: theme) else { return theme }
        let newIndex = (index - 1 + all.count) % all.count
        return all[newIndex]
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
