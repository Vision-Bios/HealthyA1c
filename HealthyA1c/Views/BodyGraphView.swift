import SwiftUI
import Charts

struct BodyGraphView: View {
    let entries: [BodyMetricsEntry]
    let theme: BodyGraphTheme
    let palette: BodyPalette
    @State private var selectedEntry: BodyMetricsEntry?

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

                    }
                }
            }
        }
    }

    private var yDomain: ClosedRange<Double> {
        let values = entries.map { $0.weight }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 1
        let padding = max(1, (maxValue - minValue) * 0.08)
        return (minValue - padding)...(maxValue + padding)
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

}
