import SwiftUI
import Charts

struct BodyGraphView: View {
    let entries: [BodyMetricsEntry]
    let theme: BodyGraphTheme
    let palette: BodyPalette
    let healthyWeightRange: ClosedRange<Double>?
    @State private var selectedEntry: BodyMetricsEntry?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if entries.isEmpty {
                Text("No data")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .background(palette.cardBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else {
                Chart {
                    if showHealthyRange, let range = healthyWeightRange {
                        healthyRangeMarks(range)
                    }
                    switch theme {
                    case .pulse:
                        pulseMarks
                    case .tide:
                        tideMarks
                    case .orbits:
                        orbitMarks
                    case .strata:
                        strataMarks
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
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
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
                           let yPos = proxy.position(forY: selectedEntry.weight) {
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
                                Text(String(format: "%.1f lb", selectedEntry.weight))
                                    .font(.caption)
                                    .foregroundStyle(palette.glow)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(palette.cardBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .position(x: min(point.x + 80, plotFrame.maxX - 70),
                                      y: max(point.y - 44, plotFrame.minY + 24))
                        }

                        if let range = healthyWeightRange,
                           let plotFrameAnchor = proxy.plotFrame,
                           let upperY = proxy.position(forY: range.upperBound),
                           let lowerY = proxy.position(forY: range.lowerBound) {
                            let plotFrame = geo[plotFrameAnchor]
                            let xPos = plotFrame.maxX - 10
                            let upperPoint = CGPoint(x: xPos, y: plotFrame.minY + upperY)
                            let lowerPoint = CGPoint(x: xPos, y: plotFrame.minY + lowerY)

                            bmiLabel(text: "BMI 24.9")
                                .position(x: upperPoint.x, y: max(plotFrame.minY + 14, upperPoint.y))

                            bmiLabel(text: "BMI 18.5")
                                .position(x: lowerPoint.x, y: min(plotFrame.maxY - 14, lowerPoint.y))
                        }
                    }
                }
            }
        }
    }

    private var showHealthyRange: Bool {
        true
    }

    private var yDomain: ClosedRange<Double> {
        let values = entries.map { $0.weight }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 1
        var lower = minValue
        var upper = maxValue
        if showHealthyRange, let range = healthyWeightRange {
            lower = min(lower, range.lowerBound)
            upper = max(upper, range.upperBound)
        }
        let padding = max(1, (upper - lower) * 0.08)
        return (lower - padding)...(upper + padding)
    }

    @ChartContentBuilder
    private func healthyRangeMarks(_ range: ClosedRange<Double>) -> some ChartContent {
        RuleMark(y: .value("BMI Min", range.lowerBound))
            .lineStyle(StrokeStyle(lineWidth: 1.2, dash: [6, 4]))
            .foregroundStyle(palette.glow.opacity(0.8))

        RuleMark(y: .value("BMI Max", range.upperBound))
            .lineStyle(StrokeStyle(lineWidth: 1.2, dash: [6, 4]))
            .foregroundStyle(palette.glow.opacity(0.8))
    }

    private var pulseMarks: some ChartContent {
        ForEach(entries) { entry in
            AreaMark(
                x: .value("Date", entry.date),
                yStart: .value("Floor", yDomain.lowerBound),
                yEnd: .value("Weight", entry.weight)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(palette.gradient.opacity(0.45))

            LineMark(
                x: .value("Date", entry.date),
                y: .value("Weight", entry.weight)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .foregroundStyle(palette.gradient)
            .shadow(color: palette.glow.opacity(0.35), radius: 8, x: 0, y: 6)
        }
    }

    private var tideMarks: some ChartContent {
        ForEach(entries) { entry in
            AreaMark(
                x: .value("Date", entry.date),
                yStart: .value("Floor", yDomain.lowerBound),
                yEnd: .value("Weight", entry.weight)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(palette.gradient.opacity(0.35))

            LineMark(
                x: .value("Date", entry.date),
                y: .value("Weight", entry.weight)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
            .foregroundStyle(palette.gradient)
        }
    }

    private var orbitMarks: some ChartContent {
        ForEach(entries) { entry in
            LineMark(
                x: .value("Date", entry.date),
                y: .value("Weight", entry.weight)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2.8, lineCap: .round))
            .foregroundStyle(palette.gradient)

            PointMark(
                x: .value("Date", entry.date),
                y: .value("Weight", entry.weight)
            )
            .symbolSize(70)
            .foregroundStyle(palette.glow)
        }
    }

    private var strataMarks: some ChartContent {
        ForEach(entries) { entry in
            BarMark(
                x: .value("Date", entry.date),
                yStart: .value("Floor", yDomain.lowerBound),
                yEnd: .value("Weight", entry.weight)
            )
            .foregroundStyle(palette.gradient.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }

    private func nearestEntry(to date: Date) -> BodyMetricsEntry? {
        entries.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
    }

    private func bmiLabel(text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(palette.textColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(palette.cardBackground, in: Capsule())
    }
}
