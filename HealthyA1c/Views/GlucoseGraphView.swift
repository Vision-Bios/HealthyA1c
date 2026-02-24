import SwiftUI
import Charts

struct GlucoseGraphView: View {
    let entries: [GlucoseEntry]
    let type: GlucoseType
    let theme: GlucoseGraphTheme
    let palette: GlucosePalette
    @State private var selectedEntry: GlucoseEntry?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if entries.isEmpty {
                Text("No data")
                    .foregroundStyle(palette.textColor.opacity(0.75))
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .background(palette.cardBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else {
                Chart {
                    if type != .random {
                        rangeLines
                    }

                    switch theme {
                    case .ribbon:
                        ribbonMarks
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
                           let yPos = proxy.position(forY: selectedEntry.value) {
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
                                Text(String(format: "%.0f mg/dL", selectedEntry.value))
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

    private var thresholds: [Double] {
        switch type {
        case .postMeal:
            return [180]
        case .fasting:
            return [100]
        case .random:
            return [70, 139]
        }
    }

    private var yDomain: ClosedRange<Double> {
        let values = entries.map { $0.value }
        let minValue = min(values.min() ?? 0, thresholds.min() ?? 0)
        let maxValue = max(values.max() ?? 1, thresholds.max() ?? 1)
        let padding = max(10, (maxValue - minValue) * 0.08)
        return (minValue - padding)...(maxValue + padding)
    }

    @ChartContentBuilder
    private var rangeLines: some ChartContent {
        ForEach(thresholds, id: \.self) { value in
            RuleMark(y: .value("Threshold", value))
                .lineStyle(StrokeStyle(lineWidth: 1.1, dash: [6, 4]))
                .foregroundStyle(palette.glow.opacity(0.75))
        }
    }

    private var ribbonMarks: some ChartContent {
        ForEach(entries) { entry in
            AreaMark(
                x: .value("Date", entry.date),
                yStart: .value("Floor", yDomain.lowerBound),
                yEnd: .value("Glucose", entry.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(palette.gradient.opacity(0.45))

            LineMark(
                x: .value("Date", entry.date),
                y: .value("Glucose", entry.value)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .foregroundStyle(palette.gradient)
            .shadow(color: palette.glow.opacity(0.35), radius: 8, x: 0, y: 6)
        }
    }

    private var stepMarks: some ChartContent {
        ForEach(entries) { entry in
            LineMark(
                x: .value("Date", entry.date),
                y: .value("Glucose", entry.value)
            )
            .interpolationMethod(.stepCenter)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
            .foregroundStyle(palette.gradient)

            PointMark(
                x: .value("Date", entry.date),
                y: .value("Glucose", entry.value)
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
                yEnd: .value("Glucose", entry.value)
            )
            .foregroundStyle(palette.gradient.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }

    private var orbitMarks: some ChartContent {
        ForEach(entries) { entry in
            LineMark(
                x: .value("Date", entry.date),
                y: .value("Glucose", entry.value)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2.4, lineCap: .round))
            .foregroundStyle(palette.gradient)

            PointMark(
                x: .value("Date", entry.date),
                y: .value("Glucose", entry.value)
            )
            .symbolSize(70)
            .foregroundStyle(palette.glow)
        }
    }

    private func nearestEntry(to date: Date) -> GlucoseEntry? {
        entries.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
    }
}
