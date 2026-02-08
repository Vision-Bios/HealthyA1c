import SwiftUI

struct AccomplishedGoalsView: View {
    @StateObject private var goalsViewModel = AccomplishedGoalsViewModel()
    @StateObject private var paletteViewModel = HbA1cViewModel()
    @State private var editingGoal: AccomplishedGoal?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        ZStack {
            ThemeBackgroundView(palette: paletteViewModel.selectedPalette)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Accomplished Goals")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(paletteViewModel.selectedPalette.textColor)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Points from goals")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(paletteViewModel.selectedPalette.textColor)

                        Text("\(goalsViewModel.goals.count)")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(paletteViewModel.selectedPalette.glow)

                        Text("Each accomplished goal = 1 point")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(paletteViewModel.selectedPalette.cardBackground,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    if goalsViewModel.goals.isEmpty {
                        Text("No goals completed yet.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(paletteViewModel.selectedPalette.cardBackground,
                                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    } else {
                        ForEach(goalsViewModel.goals) { goal in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    Image(systemName: goal.symbol)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(paletteViewModel.selectedPalette.glow)
                                    Text(goal.title)
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(paletteViewModel.selectedPalette.textColor)
                                    Spacer()
                                }

                                Text(goal.detail)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                if !goal.notes.isEmpty {
                                    Text(goal.notes)
                                        .font(.footnote)
                                        .foregroundStyle(paletteViewModel.selectedPalette.textColor.opacity(0.85))
                                        .padding(.top, 4)
                                }

                                Text(dateFormatter.string(from: goal.date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(paletteViewModel.selectedPalette.cardBackground,
                                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .onTapGesture {
                                editingGoal = goal
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            goalsViewModel.load()
            paletteViewModel.load()
        }
        .sheet(item: $editingGoal) { goal in
            GoalNotesSheet(goal: goal,
                           palette: paletteViewModel.selectedPalette,
                           onSave: { updatedNotes in
                goalsViewModel.updateNotes(id: goal.id, notes: updatedNotes)
            })
        }
    }
}

#Preview {
    AccomplishedGoalsView()
}

private struct GoalNotesSheet: View {
    let goal: AccomplishedGoal
    let palette: GraphPalette
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var notes: String

    init(goal: AccomplishedGoal, palette: GraphPalette, onSave: @escaping (String) -> Void) {
        self.goal = goal
        self.palette = palette
        self.onSave = onSave
        _notes = State(initialValue: goal.notes)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    Text(goal.title)
                        .font(.headline)
                    Text(goal.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 140)
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(notes.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                }
            }
        }
        .tint(palette.glow)
    }
}
