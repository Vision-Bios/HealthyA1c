import SwiftUI
import Charts

struct FastingGraphView: View {
    let entries: [FastingEntry]
    let theme: FastingGraphTheme
    let palette: FastingPalette
    @State private var selectedEntry: FastingEntry?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if entries.isEmpty {
                Text("No data")
                    .foregroundStyle(palette.textColor.opacity(0.75))
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .background(palette.cardBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else {
                Chart {
                    switch theme {
                    case .pulse:
                        pulseMarks
                    case .layers:
                        layersMarks
                    case .prism:
                        prismMarks
                    case .arc:
                        arcMarks
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
                .chartXScale(domain: xDomain)
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
                                Text(formatDuration(selectedEntry.hours))
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

    private var xDomain: ClosedRange<Date> {
        let dates = entries.map { $0.date }
        guard let minDate = dates.min(), let maxDate = dates.max() else {
            return Date()...Date().addingTimeInterval(3600)
        }
        let padding: TimeInterval = max(6 * 3600, maxDate.timeIntervalSince(minDate) * 0.2)
        return minDate.addingTimeInterval(-padding)...maxDate.addingTimeInterval(padding)
    }

    private var yDomain: ClosedRange<Double> {
        let values = entries.map { $0.hours }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 24
        let padding = max(1, (maxValue - minValue) * 0.1)
        return (minValue - padding)...(maxValue + padding)
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
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .foregroundStyle(palette.gradient)
            .shadow(color: palette.glow.opacity(0.35), radius: 8, x: 0, y: 6)

            PointMark(
                x: .value("Date", entry.date),
                y: .value("Hours", entry.hours)
            )
            .symbolSize(50)
            .foregroundStyle(palette.glow)
        }
    }

    private var layersMarks: some ChartContent {
        ForEach(entries) { entry in
            BarMark(
                x: .value("Date", entry.date),
                yStart: .value("Floor", yDomain.lowerBound),
                yEnd: .value("Hours", entry.hours)
            )
            .foregroundStyle(palette.gradient.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }

    private var prismMarks: some ChartContent {
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

    private var arcMarks: some ChartContent {
        ForEach(entries) { entry in
            LineMark(
                x: .value("Date", entry.date),
                y: .value("Hours", entry.hours)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2.4, lineCap: .round))
            .foregroundStyle(palette.gradient)

            AreaMark(
                x: .value("Date", entry.date),
                yStart: .value("Floor", yDomain.lowerBound),
                yEnd: .value("Hours", entry.hours)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(palette.gradient.opacity(0.25))

            PointMark(
                x: .value("Date", entry.date),
                y: .value("Hours", entry.hours)
            )
            .symbolSize(50)
            .foregroundStyle(palette.glow)
        }
    }

    private func nearestEntry(to date: Date) -> FastingEntry? {
        entries.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
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
}
