import SwiftUI
import Charts

struct MealsGraphView: View {
    let entries: [MealEntry]
    let theme: MealsGraphTheme
    let palette: MealsPalette
    @State private var selectedDay: DailyMeals?

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
                           let yPos = proxy.position(forY: Double(selectedDay.zeroCarbs + selectedDay.carbs)) {
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
                                Text("\(selectedDay.zeroCarbs) zero · \(selectedDay.carbs) carbs")
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

    private var dailyStats: [DailyMeals] {
        entries.sorted { $0.date < $1.date }.map {
            DailyMeals(date: $0.date, zeroCarbs: $0.zeroCarbsCount, carbs: $0.carbsCount)
        }
    }

    private var stacksMarks: some ChartContent {
        ForEach(dailyStats) { day in
            BarMark(
                x: .value("Date", day.date),
                y: .value("Zero", day.zeroCarbs)
            )
            .foregroundStyle(palette.gradient)
            .position(by: .value("Type", "Zero"))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            BarMark(
                x: .value("Date", day.date),
                y: .value("Carbs", day.carbs)
            )
            .foregroundStyle(palette.glow.opacity(0.7))
            .position(by: .value("Type", "Carbs"))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }

    private var flowMarks: some ChartContent {
        ForEach(dailyStats) { day in
            LineMark(
                x: .value("Date", day.date),
                y: .value("Zero", day.zeroCarbs)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
            .foregroundStyle(palette.gradient)

            LineMark(
                x: .value("Date", day.date),
                y: .value("Carbs", day.carbs)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 4]))
            .foregroundStyle(palette.glow.opacity(0.8))
        }
    }

    private var orbitMarks: some ChartContent {
        ForEach(dailyStats) { day in
            PointMark(
                x: .value("Date", day.date),
                y: .value("Zero", day.zeroCarbs)
            )
            .symbolSize(80)
            .foregroundStyle(palette.gradient)

            PointMark(
                x: .value("Date", day.date),
                y: .value("Carbs", day.carbs)
            )
            .symbolSize(50)
            .foregroundStyle(palette.glow.opacity(0.8))
        }
    }

    private func nearestDay(to date: Date) -> DailyMeals? {
        dailyStats.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
    }
}

private struct DailyMeals: Identifiable {
    let id = UUID()
    let date: Date
    let zeroCarbs: Int
    let carbs: Int
}
