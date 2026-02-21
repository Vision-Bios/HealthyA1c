import SwiftUI
import Charts

struct MealsGraphView: View {
    let entries: [MealEntry]
    let itemName: String
    let theme: MealsGraphTheme
    let palette: MealsPalette
    @State private var selectedDay: DailyItemCount?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if entries.isEmpty {
                Text("No data")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .background(palette.cardBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else {
                Chart {
                    switch theme {
                    case .stacks:
                        stacksMarks
                    case .flow:
                        flowMarks
                    case .orbit:
                        orbitMarks
                    }
                }
                .chartXAxis {
                    AxisMarks()
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartPlotStyle { plotArea in
                    plotArea
                        .padding(.top, 6)
                        .padding(.bottom, 6)
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                }
                .frame(height: 260)
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        guard let plotFrameAnchor = proxy.plotFrame else { return }
                                        let plotFrame = geo[plotFrameAnchor]
                                        let xPos = value.location.x - plotFrame.minX
                                        if let date: Date = proxy.value(atX: xPos) {
                                            selectedDay = nearestDay(to: date)
                                        }
                                    }
                            )

                        if let selectedDay,
                           let plotFrameAnchor = proxy.plotFrame,
                           let xPos = proxy.position(forX: selectedDay.date),
                           let yPos = proxy.position(forY: Double(selectedDay.count)) {
                            let plotFrame = geo[plotFrameAnchor]
                            let point = CGPoint(x: plotFrame.minX + xPos,
                                                y: plotFrame.minY + yPos)

                            Rectangle()
                                .fill(palette.glow.opacity(0.35))
                                .frame(width: 1, height: plotFrame.height)
                                .position(x: point.x, y: plotFrame.midY)

                            Circle()
                                .stroke(palette.glow.opacity(0.6), lineWidth: 6)
                                .frame(width: 26, height: 26)
                                .position(point)

                            Circle()
                                .fill(palette.glow)
                                .frame(width: 10, height: 10)
                                .position(point)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedDay.date, style: .date)
                                    .font(.caption.weight(.semibold))
                                Text("\(selectedDay.count) \(itemLabel(for: selectedDay.count))")
                                    .font(.caption)
                                    .foregroundStyle(palette.glow)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(palette.cardBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .position(x: min(point.x + 80, plotFrame.maxX - 80),
                                      y: max(point.y - 44, plotFrame.minY + 24))
                        }
                    }
                }
            }
        }
    }

    private var dailyStats: [DailyItemCount] {
        entries.sorted { $0.date < $1.date }.map {
            DailyItemCount(date: $0.date, count: $0.zeroCarbsCount + $0.carbsCount)
        }
    }

    private var stacksMarks: some ChartContent {
        ForEach(dailyStats) { day in
            BarMark(
                x: .value("Date", day.date),
                y: .value("Count", day.count)
            )
            .foregroundStyle(palette.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }

    private var flowMarks: some ChartContent {
        ForEach(dailyStats) { day in
            AreaMark(
                x: .value("Date", day.date),
                yStart: .value("Floor", 0),
                yEnd: .value("Count", day.count)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(palette.gradient.opacity(0.35))

            LineMark(
                x: .value("Date", day.date),
                y: .value("Count", day.count)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
            .foregroundStyle(palette.gradient)
        }
    }

    private var orbitMarks: some ChartContent {
        ForEach(dailyStats) { day in
            LineMark(
                x: .value("Date", day.date),
                y: .value("Count", day.count)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2.6, lineCap: .round))
            .foregroundStyle(palette.gradient)

            PointMark(
                x: .value("Date", day.date),
                y: .value("Count", day.count)
            )
            .symbolSize(70)
            .foregroundStyle(palette.glow)
        }
    }

    private func nearestDay(to date: Date) -> DailyItemCount? {
        dailyStats.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
    }

    private func itemLabel(for count: Int) -> String {
        let trimmed = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = trimmed.isEmpty ? "item" : trimmed
        if count == 1 { return base }
        if base.lowercased().hasSuffix("s") { return base }
        return "\(base)s"
    }
}

private struct DailyItemCount: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
