import SwiftUI
import Charts

struct SleepGraphView: View {
    let entries: [SleepEntry]
    let theme: SleepGraphTheme
    let palette: SleepPalette

    private let goalHours = 7.0
    @State private var selectedEntry: SleepEntry?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if entries.isEmpty {
                Text("No data")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .background(palette.cardBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else {
                Chart {
                    goalLine

                    switch theme {
                    case .pulse:
                        pulseMarks
                    case .steps:
                        stepMarks
                    case .bars:
                        barMarks
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
                .chartYScale(domain: yDomain, range: .plotDimension(padding: 0))
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
                                            selectedEntry = nearestEntry(to: date)
                                        }
                                    }
                            )

                        if let selectedEntry,
                           let plotFrameAnchor = proxy.plotFrame,
                           let xPos = proxy.position(forX: selectedEntry.date),
                           let yPos = proxy.position(forY: selectedEntry.hours) {
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
                                Text(selectedEntry.date, style: .date)
                                    .font(.caption.weight(.semibold))
                                Text("\(formatHours(selectedEntry.hours)) hrs")
                                    .font(.caption)
                                    .foregroundStyle(palette.glow)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(palette.cardBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .position(x: min(point.x + 80, plotFrame.maxX - 70),
                                      y: max(point.y - 44, plotFrame.minY + 24))
                        }
                    }
                }
            }
        }
    }

    private var yDomain: ClosedRange<Double> {
        let values = entries.map { $0.hours }
        let minValue = min(values.min() ?? 0, goalHours)
        let maxValue = max(values.max() ?? 1, goalHours)
        let padding = max(0.5, (maxValue - minValue) * 0.08)
        return (minValue - padding)...(maxValue + padding)
    }

    private var goalLine: some ChartContent {
        RuleMark(y: .value("Goal", goalHours))
            .lineStyle(StrokeStyle(lineWidth: 1.2, dash: [6, 4]))
            .foregroundStyle(palette.glow.opacity(0.8))
            .annotation(position: .topTrailing, alignment: .trailing) {
                Text("Goal 7 hrs")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.textColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(palette.cardBackground, in: Capsule())
            }
    }

    private var pulseMarks: some ChartContent {
        ForEach(entries) { entry in
            AreaMark(
                x: .value("Date", entry.date),
                yStart: .value("Floor", yDomain.lowerBound),
                yEnd: .value("Hours", entry.hours)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(palette.gradient.opacity(0.45))

            LineMark(
                x: .value("Date", entry.date),
                y: .value("Hours", entry.hours)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
            .foregroundStyle(palette.gradient)
            .shadow(color: palette.glow.opacity(0.35), radius: 8, x: 0, y: 6)
        }
    }

    private var stepMarks: some ChartContent {
        ForEach(entries) { entry in
            LineMark(
                x: .value("Date", entry.date),
                y: .value("Hours", entry.hours)
            )
            .interpolationMethod(.stepCenter)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
            .foregroundStyle(palette.gradient)

            PointMark(
                x: .value("Date", entry.date),
                y: .value("Hours", entry.hours)
            )
            .symbolSize(60)
            .foregroundStyle(palette.glow)
        }
    }

    private var barMarks: some ChartContent {
        ForEach(entries) { entry in
            BarMark(
                x: .value("Date", entry.date),
                yStart: .value("Floor", yDomain.lowerBound),
                yEnd: .value("Hours", entry.hours)
            )
            .foregroundStyle(palette.gradient.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }

    private var orbitMarks: some ChartContent {
        ForEach(entries) { entry in
            LineMark(
                x: .value("Date", entry.date),
                y: .value("Hours", entry.hours)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2.4, lineCap: .round))
            .foregroundStyle(palette.gradient)

            PointMark(
                x: .value("Date", entry.date),
                y: .value("Hours", entry.hours)
            )
            .symbolSize(70)
            .foregroundStyle(palette.glow)
        }
    }

    private func nearestEntry(to date: Date) -> SleepEntry? {
        entries.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
    }

    private func formatHours(_ hours: Double) -> String {
        if abs(hours.rounded() - hours) < 0.01 {
            return String(format: "%.0f", hours)
        }
        return String(format: "%.1f", hours)
    }
}
