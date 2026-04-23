//
//  StatsTabView.swift
//  BufalloSteaklovers
//

import SwiftUI

// MARK: - Segmented control

private struct StatsPeriodSegmentedControl: View {
    @Environment(\.layoutScale) private var scale
    @Binding var selection: Int

    private let labels = ["Week", "Month", "Year"]

    var body: some View {
        let trackH = fpScale(32, scale)
        let innerH = fpScale(28, scale)
        let pad = fpScale(2, scale)
        let cornerTrack = fpScale(8, scale)
        let cornerSeg = fpScale(7, scale)

        HStack(spacing: 0) {
            ForEach(labels.indices, id: \.self) { i in
                Button {
                    selection = i
                } label: {
                    Text(labels[i])
                        .font(.system(size: fpScale(10, scale), weight: .semibold))
                        .tracking(-0.08)
                        .foregroundStyle(selection == i ? Color.white : Color(steakHex: "A1887F"))
                        .frame(maxWidth: .infinity)
                        .frame(height: innerH)
                        .background(
                            RoundedRectangle(cornerRadius: cornerSeg, style: .continuous)
                                .fill(selection == i ? Color(steakHex: "FF5722") : Color.clear)
                                .shadow(
                                    color: selection == i ? Color.black.opacity(0.12) : .clear,
                                    radius: fpScale(4, scale),
                                    x: 0,
                                    y: fpScale(3, scale)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerSeg, style: .continuous)
                                .strokeBorder(Color.black.opacity(0.04), lineWidth: selection == i ? max(0.5, fpScale(0.5, scale)) : 0)
                        )
                }
                .buttonStyle(SteakSoundPlainButtonStyle())
            }
        }
        .padding(pad)
        .frame(height: trackH)
        .frame(maxWidth: fpScale(342, scale))
        .background(
            RoundedRectangle(cornerRadius: cornerTrack, style: .continuous)
                .fill(Color(steakHex: "3E2723"))
        )
    }
}

// MARK: - Empty state

private struct StatisticsEmptyStateBlock: View {
    @Environment(\.layoutScale) private var scale

    var body: some View {
        let bull = fpScale(258, scale)
        VStack(spacing: fpScale(15, scale)) {
            Image("Layer_x0020_1")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: bull, height: bull)
                .accessibilityLabel("Buffalo")

            VStack(spacing: fpScale(4, scale)) {
                Text("NO DATA YET")
                    .font(.system(size: fpScale(20, scale), weight: .semibold))
                    .foregroundStyle(Color(steakHex: "FF5722"))
                    .multilineTextAlignment(.center)

                Text("Start cooking and logging steaks!")
                    .font(.system(size: fpScale(16, scale), weight: .medium))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: fpScale(296, scale))
        }
        .frame(maxWidth: fpScale(296, scale))
    }
}

// MARK: - Metric mini cards

private struct StatsMetricMiniCard: View {
    @Environment(\.layoutScale) private var scale
    let systemImage: String
    let label: String
    let value: String
    var valueColor: Color = .white

    private var cardW: CGFloat { fpScale(163, scale) }
    private var cardH: CGFloat { fpScale(85, scale) }
    private var corner: CGFloat { fpScale(12, scale) }

    var body: some View {
        VStack(alignment: .leading, spacing: fpScale(12, scale)) {
            HStack(spacing: fpScale(4, scale)) {
                Image(systemName: systemImage)
                    .font(.system(size: fpScale(11, scale), weight: .semibold))
                    .foregroundStyle(Color(steakHex: "A1887F"))
                    .frame(width: fpScale(20, scale), height: fpScale(20, scale))

                Text(label)
                    .font(.system(size: fpScale(12, scale), weight: .bold))
                    .foregroundStyle(Color(steakHex: "D7CCC8"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Text(value)
                .font(.system(size: fpScale(24, scale), weight: .bold))
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, fpScale(12, scale))
        .padding(.vertical, fpScale(12, scale))
        .frame(width: cardW, height: cardH, alignment: .topLeading)
        .background(Color(steakHex: "3E2723"))
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
        )
    }
}

// MARK: - Line chart

private let statsDesignFallbackLinePoints: [(CGFloat, CGFloat)] = [
    (0.035, 0.327), (0.436, 0.327), (0.502, 0.0), (0.639, 0.0),
    (0.709, 0.660), (0.846, 0.346), (0.973, 0.346)
]

private struct StatsTemperatureTasteChartCard: View {
    @Environment(\.layoutScale) private var scale
    let linePoints: [(CGFloat, CGFloat)]

    private var cardCorner: CGFloat { fpScale(12, scale) }
    private var plotH: CGFloat { fpScale(150, scale) }
    private var axisLabelFont: CGFloat { fpScale(8, scale) }

    private let xTicks: [Int] = [40, 45, 50, 55, 60, 65, 70, 75]
    private let yLabels: [(String, String)] = [
        ("☹️", "Bad"),
        ("😐", "Average"),
        ("🤩", "Excellent")
    ]

    private var resolvedPoints: [(CGFloat, CGFloat)] {
        let p = linePoints
        if p.count >= 2 { return p }
        if p.count == 1 { return [p[0], p[0]] }
        return statsDesignFallbackLinePoints
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Temperature vs Taste")
                .font(.system(size: fpScale(15, scale), weight: .bold))
                .foregroundStyle(Color(steakHex: "FFC107"))
                .textCase(.uppercase)
                .padding(.horizontal, fpScale(12, scale))
                .padding(.top, fpScale(16, scale))
                .padding(.bottom, fpScale(10, scale))

            HStack(alignment: .top, spacing: fpScale(6, scale)) {
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(Array(yLabels.enumerated()), id: \.offset) { _, pair in
                        Text("\(pair.0) \(pair.1)")
                            .font(.system(size: axisLabelFont, weight: .regular))
                            .foregroundStyle(Color.white)
                            .frame(height: plotH / 3, alignment: .center)
                    }
                }
                .frame(width: fpScale(51, scale), alignment: .trailing)

                GeometryReader { geo in
                    let w = geo.size.width
                    let h = plotH
                    let gridCount = xTicks.count - 1
                    let ox = fpScale(1, scale)
                    let pts = resolvedPoints
                    ZStack(alignment: .topLeading) {
                        Color.clear.frame(width: w, height: h)

                        ForEach(0..<gridCount, id: \.self) { i in
                            let x = ox + CGFloat(i) / CGFloat(max(gridCount - 1, 1)) * (w - ox * 2)
                            Path { p in
                                p.move(to: CGPoint(x: x, y: 0))
                                p.addLine(to: CGPoint(x: x, y: h))
                            }
                            .stroke(
                                Color(steakHex: "A1887F"),
                                style: StrokeStyle(lineWidth: max(0.5, fpScale(1, scale)), dash: [4, 4])
                            )
                        }

                        Path { p in
                            p.move(to: CGPoint(x: ox, y: 0))
                            p.addLine(to: CGPoint(x: ox, y: h))
                        }
                        .stroke(Color(steakHex: "D9D9D9"), lineWidth: max(1, fpScale(1, scale)))

                        Path { p in
                            p.move(to: CGPoint(x: ox, y: h))
                            p.addLine(to: CGPoint(x: w, y: h))
                        }
                        .stroke(Color(steakHex: "D9D9D9"), lineWidth: max(1, fpScale(1, scale)))

                        let lineW = max(1, fpScale(1.5, scale))
                        let pointR = fpScale(3.5, scale)
                        StatsTempTasteLineShape(points: pts)
                            .stroke(Color(steakHex: "FF5722"), style: StrokeStyle(lineWidth: lineW, lineCap: .round, lineJoin: .round))
                            .frame(width: w - ox, height: h)
                            .offset(x: ox)

                        ForEach(Array(pts.enumerated()), id: \.offset) { _, pt in
                            let cx = ox + pt.0 * (w - ox)
                            let cy = pt.1 * h
                            Circle()
                                .fill(Color(steakHex: "FF5722"))
                                .frame(width: pointR * 2, height: pointR * 2)
                                .position(x: cx, y: cy)
                        }
                    }
                }
                .frame(height: plotH)
            }
            .padding(.horizontal, fpScale(12, scale))

            HStack(spacing: 0) {
                Spacer()
                    .frame(width: fpScale(51 + 6, scale))
                HStack(spacing: 0) {
                    ForEach(xTicks, id: \.self) { t in
                        VStack(spacing: fpScale(2, scale)) {
                            Rectangle()
                                .fill(Color(steakHex: "D9D9D9"))
                                .frame(width: max(1, fpScale(1, scale)), height: fpScale(4, scale))
                            Text("\(t)")
                                .font(.system(size: axisLabelFont, weight: .regular))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, fpScale(12, scale))
            .padding(.top, fpScale(4, scale))
            .padding(.bottom, fpScale(12, scale))
        }
        .frame(maxWidth: .infinity)
        .background(Color(steakHex: "3E2723"))
        .clipShape(RoundedRectangle(cornerRadius: cardCorner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cardCorner, style: .continuous)
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
        )
    }
}

private struct StatsTempTasteLineShape: Shape {
    let points: [(CGFloat, CGFloat)]

    func path(in rect: CGRect) -> Path {
        guard !points.isEmpty, rect.width > 0, rect.height > 0 else { return Path() }
        var p = Path()
        let first = CGPoint(x: points[0].0 * rect.width, y: points[0].1 * rect.height)
        p.move(to: first)
        for i in 1..<points.count {
            p.addLine(to: CGPoint(x: points[i].0 * rect.width, y: points[i].1 * rect.height))
        }
        return p
    }
}

// MARK: - Doneness donut (TZ: Rare / Medium / Well Done)

private struct DonenessSlice: Identifiable {
    var id: String { title }
    let title: String
    let percent: Double
    let hex: String
}

private struct StatsDonenessDistributionCard: View {
    @Environment(\.layoutScale) private var scale
    let slices: [DonenessSlice]

    private var cardCorner: CGFloat { fpScale(12, scale) }

    var body: some View {
        VStack(alignment: .leading, spacing: fpScale(16, scale)) {
            Text("Doneness Distribution")
                .font(.system(size: fpScale(15, scale), weight: .bold))
                .foregroundStyle(Color(steakHex: "FFC107"))
                .textCase(.uppercase)
                .padding(.horizontal, fpScale(12, scale))
                .padding(.top, fpScale(16, scale))

            StatsDonutChart(slices: slices, scale: scale)
                .frame(height: fpScale(200, scale))
                .frame(maxWidth: .infinity)

            VStack(spacing: fpScale(10, scale)) {
                ForEach(slices) { slice in
                    HStack(spacing: fpScale(4, scale)) {
                        Circle()
                            .fill(Color(steakHex: slice.hex))
                            .frame(width: fpScale(12, scale), height: fpScale(12, scale))
                        Text(slice.title)
                            .font(.system(size: fpScale(12, scale), weight: .medium))
                            .foregroundStyle(Color(steakHex: slice.hex))
                        Spacer(minLength: 0)
                        Text("\(Int(slice.percent * 100))%")
                            .font(.system(size: fpScale(12, scale), weight: .semibold))
                            .foregroundStyle(Color.white)
                            .frame(minWidth: fpScale(28, scale), alignment: .trailing)
                    }
                    .padding(.horizontal, fpScale(16, scale))
                }
            }
            .padding(.bottom, fpScale(16, scale))
        }
        .frame(maxWidth: .infinity)
        .background(Color(steakHex: "3E2723"))
        .clipShape(RoundedRectangle(cornerRadius: cardCorner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cardCorner, style: .continuous)
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
        )
    }
}

private struct StatsDonutChart: View {
    let slices: [DonenessSlice]
    var scale: CGFloat

    /// Ring ~160 pt; uniform gaps (card-colored); white 1 pt stroke on colored arcs only.
    private func donutAnnulusPath(
        cx: CGFloat,
        cy: CGFloat,
        rOuter: CGFloat,
        rInner: CGFloat,
        start: Double,
        end: Double
    ) -> Path {
        var p = Path()
        p.addArc(
            center: CGPoint(x: cx, y: cy),
            radius: rOuter,
            startAngle: .radians(start),
            endAngle: .radians(end),
            clockwise: false
        )
        p.addArc(
            center: CGPoint(x: cx, y: cy),
            radius: rInner,
            startAngle: .radians(end),
            endAngle: .radians(start),
            clockwise: true
        )
        p.closeSubpath()
        return p
    }

    var body: some View {
        Canvas { context, size in
            guard size.width.isFinite, size.height.isFinite, size.width > 1, size.height > 1 else { return }

            let cx = size.width / 2
            let cy = size.height / 2
            let outerRaw = min(fpScale(80, scale), min(size.width, size.height) / 2 - fpScale(4, scale))
            let outer = max(2, outerRaw.isFinite ? outerRaw : 2)
            let inner = max(1, outer * 0.55)
            let strokeW = max(1, fpScale(1, scale))

            let n = slices.count
            guard n > 0 else { return }

            // Uniform angular gap between segments; fill matches card — white is stroke only (like CSS border).
            let gapDegrees = 0.2
            let gapRadians = gapDegrees * Double.pi / 180.0
            let totalGaps = gapRadians * Double(n)
            let sweepPool = max(2 * Double.pi - totalGaps, 0.01)
            let gapFill = Color(steakHex: "3E2723")

            let rawSum = slices.map(\.percent).reduce(0, +)
            let sumP = max(rawSum, 0.000_001)
            let useEqualSlices = rawSum < 0.000_001

            var theta = -Double.pi / 2

            for slice in slices {
                let fraction = useEqualSlices ? (1.0 / Double(n)) : (slice.percent / sumP)
                let sweep = fraction * sweepPool

                if sweep > 1e-10 {
                    let end = theta + sweep
                    let seg = donutAnnulusPath(cx: cx, cy: cy, rOuter: outer, rInner: inner, start: theta, end: end)
                    context.fill(seg, with: .color(Color(steakHex: slice.hex)))
                    context.stroke(seg, with: .color(.white), lineWidth: strokeW)
                    theta = end
                }

                let gapEnd = theta + gapRadians
                if gapRadians > 1e-10 {
                    let gapPath = donutAnnulusPath(cx: cx, cy: cy, rOuter: outer, rInner: inner, start: theta, end: gapEnd)
                    context.fill(gapPath, with: .color(gapFill))
                }
                theta = gapEnd
            }
        }
    }
}

// MARK: - Analytics body

private struct StatsAnalyticsContent: View {
    @Environment(\.layoutScale) private var scale
    let snapshot: StatisticsSnapshot

    private var contentW: CGFloat { fpScale(342, scale) }
    private var cellW: CGFloat { fpScale(163, scale) }
    private var colGap: CGFloat { fpScale(16, scale) }
    private var rowGap: CGFloat { fpScale(12, scale) }

    private var metricColumns: [GridItem] {
        [
            GridItem(.fixed(cellW), spacing: colGap, alignment: .top),
            GridItem(.fixed(cellW), spacing: 0, alignment: .top)
        ]
    }

    private var donutSlices: [DonenessSlice] {
        snapshot.donenessSlices.map { DonenessSlice(title: $0.title, percent: $0.percent, hex: $0.hex) }
    }

    var body: some View {
        VStack(spacing: fpScale(24, scale)) {
            LazyVGrid(columns: metricColumns, alignment: .leading, spacing: rowGap) {
                StatsMetricMiniCard(systemImage: "scope", label: "Total Steaks", value: "\(snapshot.totalSteaks)")
                StatsMetricMiniCard(
                    systemImage: "chart.line.uptrend.xyaxis",
                    label: "Success Rate",
                    value: "\(snapshot.successRatePercent)%",
                    valueColor: Color(steakHex: "FF5722")
                )
                StatsMetricMiniCard(systemImage: "thermometer.medium", label: "Avg Temp", value: "\(snapshot.avgTempC)°C")
                StatsMetricMiniCard(systemImage: "rosette", label: "Favorite", value: snapshot.favoriteCut)
                StatsMetricMiniCard(systemImage: "clock", label: "Avg Rest", value: snapshot.avgRestMinutes)
                Color.clear.frame(width: cellW, height: 0)
            }
            .frame(width: contentW, alignment: .leading)

            StatsTemperatureTasteChartCard(linePoints: snapshot.tempTasteLinePoints)
                .frame(width: contentW)

            StatsDonenessDistributionCard(slices: donutSlices)
                .frame(width: contentW)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, fpScale(24, scale))
        .padding(.top, fpScale(24, scale))
        .padding(.bottom, fpScale(24, scale))
    }
}

// MARK: - Tab root

struct StatsTabView: View {
    @Environment(\.layoutScale) private var scale
    @EnvironmentObject private var repository: SteakDataRepository
    @StateObject private var statisticsViewModel = StatisticsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            SteakTabScreenHeader(title: "Statistics")
                .environment(\.layoutScale, scale)

            ZStack {
                Color(steakHex: "2D1B11")
                if statisticsViewModel.snapshot.hasAnyLogs {
                    ScrollView(.vertical, showsIndicators: false) {
                        StatsAnalyticsContent(snapshot: statisticsViewModel.snapshot)
                    }
                } else {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        StatisticsEmptyStateBlock()
                        Spacer(minLength: 0)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            StatsPeriodSegmentedControl(selection: $statisticsViewModel.periodIndex)
                .padding(.horizontal, fpScale(24, scale))
                .padding(.top, fpScale(12, scale))
                .padding(.bottom, fpScale(16, scale))
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(steakHex: "2D1B11"))
        .onAppear {
            statisticsViewModel.recompute(using: repository)
        }
        .onReceive(repository.$sessions) { _ in
            statisticsViewModel.recompute(using: repository)
        }
        .onChange(of: statisticsViewModel.periodIndex) { _ in
            statisticsViewModel.recompute(using: repository)
        }
    }
}

#Preview("Analytics") {
    StatsTabView()
        .environment(\.layoutScale, 1)
        .environmentObject(SteakDataRepository())
}
