import SwiftUI
import Charts

struct GraphView: View {
    let entries: [HbA1cEntry]
    let theme: GraphTheme
    let palette: GraphPalette
    private let thresholdValue = 6.5
    @State private var selectedEntry: HbA1cEntry?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if entries.isEmpty {
                Text("No data")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else {
                Chart {
                    thresholdLineMark

                    switch theme {
                    case .journey:
                        journeyMarks
                    case .ladder:
                        ladderMarks
                    case .river:
                        riverMarks
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
                                    .onEnded { _ in
                                        // Keep selection visible.
                                    }
                            )

                        if let yOffset = proxy.position(forY: thresholdValue),
                           let plotFrameAnchor = proxy.plotFrame {
                            let plotFrame = geo[plotFrameAnchor]
                            let yPosition = plotFrame.minY + yOffset

                            Text("6.5%")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(palette.textColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(palette.cardBackground, in: Capsule())
                                .position(x: plotFrame.maxX - 60, y: yPosition - 12)
                        }

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
                                Text(String(format: "%.1f", selectedEntry.value))
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
        let values = entries.map { $0.value }
        let minValue = (values.min() ?? thresholdValue) - 0.6
        let maxValue = (values.max() ?? thresholdValue) + 0.6
        let lower = min(minValue, thresholdValue - 0.2)
        let upper = max(maxValue, thresholdValue + 0.4)
        return lower...upper
    }

    private var thresholdLineMark: some ChartContent {
        RuleMark(y: .value("Threshold", thresholdValue))
            .lineStyle(StrokeStyle(lineWidth: 1.2, dash: [6, 4]))
            .foregroundStyle(palette.glow.opacity(0.8))
    }

    private var journeyMarks: some ChartContent {
        ForEach(entries) { entry in
            AreaMark(
                x: .value("Date", entry.date),
                yStart: .value("Floor", yDomain.lowerBound),
                yEnd: .value("A1c", entry.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(palette.gradient.opacity(0.4))

            LineMark(
                x: .value("Date", entry.date),
                y: .value("A1c", entry.value)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .foregroundStyle(palette.gradient)
            .shadow(color: palette.glow.opacity(0.25), radius: 8, x: 0, y: 6)
        }
    }

    private var ladderMarks: some ChartContent {
        ForEach(entries) { entry in
            LineMark(
                x: .value("Date", entry.date),
                y: .value("A1c", entry.value)
            )
            .interpolationMethod(.stepStart)
            .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
            .foregroundStyle(palette.gradient)

            PointMark(
                x: .value("Date", entry.date),
                y: .value("A1c", entry.value)
            )
            .symbolSize(60)
            .foregroundStyle(palette.glow)
        }
    }

    private var riverMarks: some ChartContent {
        ForEach(entries) { entry in
            AreaMark(
                x: .value("Date", entry.date),
                yStart: .value("Floor", yDomain.lowerBound),
                yEnd: .value("A1c", entry.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(palette.gradient.opacity(0.55))

            LineMark(
                x: .value("Date", entry.date),
                y: .value("A1c", entry.value)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
            .foregroundStyle(palette.gradient)
        }
    }

    private func nearestEntry(to date: Date) -> HbA1cEntry? {
        entries.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
    }
}
