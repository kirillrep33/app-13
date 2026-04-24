import SwiftUI
import Combine
import UIKit

private struct CookingMethod: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let usesAssetIcon: Bool
}

struct TimerScreen: View {
    @EnvironmentObject private var store: AppDataStore
    let scale: CGFloat
    let onBack: () -> Void

    @State private var selectedMethod = "Pan Sear"
    @State private var selectedProduct = "Product"
    @State private var isProductExpanded = false
    @State private var thickness: Double = 3.5
    @State private var tasteRating: Double = 3.5
    @State private var selectedTarget = "180°C"
    @State private var isTimerRunning = false
    @State private var hasTimerStarted = false
    @State private var remainingSeconds = 0
    @State private var statusMessage = "Ready to start"
    @State private var didFireHalfway = false
    @State private var accumulatedActiveSeconds: TimeInterval = 0
    @State private var currentRunStartedAt: Date?

    private let methods: [CookingMethod] = [
        .init(title: "Pan Sear", icon: "hugeicons_pan-03", usesAssetIcon: true),
        .init(title: "Bake", icon: "hugeicons_pan-03-2", usesAssetIcon: true),
        .init(title: "Steam", icon: "hugeicons_pan-03-3", usesAssetIcon: true),
        .init(title: "Grill", icon: "hugeicons_pan-03-4", usesAssetIcon: true),
        .init(title: "Boil", icon: "hugeicons_pan-03-5", usesAssetIcon: true),
        .init(title: "Deep Fry", icon: "hugeicons_pan-03-6", usesAssetIcon: true),
        .init(title: "Braise", icon: "hugeicons_pan-03-7", usesAssetIcon: true)
    ]

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24 * scale) {
                    topFormCard
                    tasteCard
                    timerCard
                }
                .padding(.top, 24 * scale)
                .padding(.horizontal, 16 * scale)
                .padding(.bottom, 12 * scale)
            }
        }
        .onAppear {
            resetTimerState()
        }
        .onChange(of: selectedMethod) { _ in resetTimerState() }
        .onChange(of: thickness) { _ in resetTimerState() }
        .onReceive(timer) { _ in tick() }
    }

    private var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }

    private var timerPlan: TimerComputation {
        TimerEngine.compute(thickness: thickness, method: selectedMethod, productName: selectedProduct)
    }

    private var productList: [String] {
        store.seafoodCatalog.map(\.name)
    }

    private var navBar: some View {
        HStack {
            Button(action: onBack) {
                Circle()
                    .fill(Color(red: 0.169, green: 0.098, blue: 0.706))
                    .frame(width: 42 * scale, height: 42 * scale)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15 * scale, weight: .semibold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(SoundPlainButtonStyle())

            Spacer()

            Text("Cooking Timer")
                .font(.system(size: 26 * scale, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer()

            Color.clear.frame(width: 42 * scale, height: 42 * scale)
        }
        .padding(.horizontal, 16 * scale)
        .frame(height: 42 * scale)
        .padding(.top, 16 * scale)
    }

    private var topFormCard: some View {
        VStack(alignment: .leading, spacing: 24 * scale) {
            productDropdownBlock

            if !isProductExpanded {
                VStack(alignment: .leading, spacing: 12 * scale) {
                    Text("Method of Preparation")
                        .font(.system(size: 17 * scale, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12 * scale), count: 3), spacing: 12 * scale) {
                        ForEach(methods) { method in
                            methodButton(method)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 16 * scale) {
                Text("Thickness")
                    .font(.system(size: 17 * scale, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                thicknessSlider
            }

            VStack(alignment: .leading, spacing: 12 * scale) {
                Text("Intensity")
                    .font(.system(size: 17 * scale, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("iteral target heat")
                    .font(.system(size: 17 * scale, weight: .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                VStack(spacing: 12 * scale) {
                    targetButton("180°C")
                    targetButton("200°C")
                    targetButton("220°C")
                }
            }
        }
        .padding(.vertical, 20 * scale)
        .padding(.horizontal, 16 * scale)
        .background(Color(red: 0.965, green: 0.98, blue: 0.996))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
    }

    private var productDropdownBlock: some View {
        VStack(alignment: .leading, spacing: 12 * scale) {
            Text("Choose Product")
                .font(.system(size: 17 * scale, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isProductExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(selectedProduct)
                        .foregroundStyle(selectedProduct == "Product" ? .black.opacity(0.6) : .black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Spacer()
                    Image(systemName: isProductExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.black.opacity(0.6))
                }
                .font(.system(size: 17 * scale, weight: .regular))
                .padding(16 * scale)
                .frame(height: 52 * scale)
                .background(Color(red: 0.91, green: 0.91, blue: 0.965))
                .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
            }
            .buttonStyle(SoundPlainButtonStyle())

            if isProductExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(productList.enumerated()), id: \.offset) { index, item in
                        Button {
                            selectedProduct = item
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isProductExpanded = false
                            }
                        } label: {
                            HStack {
                                Text(item)
                                    .font(.system(size: 17 * scale, weight: .regular))
                                    .foregroundStyle(.black)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                Spacer()
                            }
                            .padding(.horizontal, 16 * scale)
                            .frame(height: 52 * scale)
                        }
                        .buttonStyle(SoundPlainButtonStyle())

                        if index != productList.count - 1 {
                            Divider()
                                .overlay(Color.black.opacity(0.1))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.937, green: 0.937, blue: 0.945))
                .clipShape(
                    RoundedRectangle(cornerRadius: 24 * scale, style: .continuous)
                )
                .shadow(color: .black.opacity(0.08), radius: 4 * scale, y: 2 * scale)
                .padding(.top, -4 * scale)
            }
        }
    }

    private var tasteCard: some View {
        VStack(alignment: .leading, spacing: 24 * scale) {
            Text("Taste rating")
                .font(.system(size: 24 * scale, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            HStack {
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18 * scale, height: 18 * scale)
                    .foregroundStyle(Color(red: 1.0, green: 0.5, blue: 0.0))
                Spacer()
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18 * scale, height: 18 * scale)
                    .foregroundStyle(Color(red: 1.0, green: 0.5, blue: 0.0))
            }
            .frame(height: 18 * scale)

            tasteSlider
        }
        .padding(.vertical, 20 * scale)
        .padding(.horizontal, 16 * scale)
        .frame(maxWidth: .infinity, minHeight: 151 * scale)
        .background(Color(red: 0.965, green: 0.98, blue: 0.996))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
    }

    private var tasteSlider: some View {
        GeometryReader { geo in
            let rawWidth = geo.size.width
            let width = rawWidth.isFinite ? max(rawWidth, 0) : 0
            let safeWidth = max(width, 1)
            let progress = max(0, min(1, tasteRating / 5))
            let fillWidth = width * progress
            let knobX = fillWidth
            let stepValue = Int((tasteRating * 2).rounded())

            Group {
                if width > 1 {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 100 * scale, style: .continuous)
                            .fill(Color(red: 0.169, green: 0.098, blue: 0.706).opacity(0.2))
                            .frame(width: width, height: 4 * scale)
                            .offset(y: 5 * scale)

                        RoundedRectangle(cornerRadius: 100 * scale, style: .continuous)
                            .fill(Color(red: 0.169, green: 0.098, blue: 0.706))
                            .frame(width: fillWidth, height: 4 * scale)
                            .offset(y: 5 * scale)

                        ZStack {
                            Image("Tooltip")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 39 * scale, height: 24 * scale)
                                .offset(y: -10 * scale)
                            Text("\(stepValue)")
                                .font(.system(size: 12 * scale, weight: .regular))
                                .foregroundStyle(.white)
                                .frame(width: 35 * scale, height: 15 * scale)
                                .offset(y: -10 * scale)
                        }
                        .offset(x: knobX - 19.5 * scale, y: -15 * scale)

                        Circle()
                            .fill(.white)
                            .overlay(
                                Circle().stroke(Color.black.opacity(0.1), lineWidth: 1 * scale)
                            )
                            .frame(width: 12 * scale, height: 12 * scale)
                            .shadow(color: .black.opacity(0.1), radius: 2 * scale, y: 2 * scale)
                            .offset(x: knobX - 6 * scale, y: 1 * scale)

                        HStack(spacing: 0) {
                            ForEach(0...10, id: \.self) { tick in
                                VStack(spacing: 2 * scale) {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.2))
                                        .frame(width: 1 * scale, height: 4 * scale)
                                    Text([0, 2, 4, 6, 8, 10].contains(tick) ? "\(tick)" : "")
                                        .font(.system(size: 8 * scale, weight: .regular))
                                        .foregroundStyle(Color.black.opacity(0.45))
                                        .frame(height: 10 * scale)
                                }
                                if tick != 10 {
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                        .frame(width: width, height: 14 * scale, alignment: .top)
                        .offset(y: 15 * scale)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x.isFinite ? value.location.x : 0
                                let clampedX = min(max(0, x), safeWidth)
                                let rawValue = (clampedX / safeWidth) * 5
                                tasteRating = (rawValue * 10).rounded() / 10
                            }
                    )
                } else {
                    Color.clear
                }
            }
        }
        .frame(height: 33 * scale)
    }

    private var timerCard: some View {
        let progress = max(0, min(1, Double(remainingSeconds) / Double(max(timerPlan.totalSeconds, 1))))
        return ZStack(alignment: .topLeading) {
            VStack(alignment: .center, spacing: 24 * scale) {
                Text("Timer")
                    .font(.system(size: 24 * scale, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                ZStack {
                    Circle()
                        .stroke(Color(red: 0.91, green: 0.91, blue: 0.965), lineWidth: 16 * scale)
                        .frame(width: 238 * scale, height: 238 * scale)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color(red: 0.169, green: 0.098, blue: 0.706),
                            style: StrokeStyle(lineWidth: 16 * scale, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 238 * scale, height: 238 * scale)

                    VStack(spacing: 24 * scale) {
                        Text("TIME REMAINING")
                            .font(.system(size: 14 * scale, weight: .semibold))
                            .frame(width: 139 * scale, height: 20 * scale, alignment: .center)
                            .multilineTextAlignment(.center)
                            .textCase(.uppercase)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        Text(formattedTime(remainingSeconds))
                            .font(.system(size: 52 * scale, weight: .bold))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.55)
                            .frame(maxWidth: 170 * scale, minHeight: 44 * scale, alignment: .center)
                            .multilineTextAlignment(.center)
                        Text("minutes")
                            .font(.system(size: 14 * scale, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.5))
                            .frame(width: 139 * scale, height: 20 * scale, alignment: .center)
                            .multilineTextAlignment(.center)
                            .textCase(.lowercase)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                }
                .frame(width: 238 * scale, height: 238 * scale)

                Text(statusMessage)
                    .font(.system(size: 14 * scale, weight: .semibold))
                    .foregroundStyle(Color(red: 0.169, green: 0.098, blue: 0.706))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if hasTimerStarted {
                    HStack(spacing: 16 * scale) {
                        Button(action: toggleTimer) {
                            HStack(spacing: 4 * scale) {
                                Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                    .font(.system(size: 20 * scale, weight: .medium))
                                Text(isTimerRunning ? "Pause" : "Start")
                                    .font(.system(size: 17 * scale, weight: .medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, minHeight: 52 * scale)
                            .background(Color(red: 0.737, green: 0.737, blue: 0.929))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16 * scale, style: .continuous)
                                    .stroke(Color(red: 0.169, green: 0.098, blue: 0.706), lineWidth: 2 * scale)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
                        }
                        .buttonStyle(SoundPlainButtonStyle())

                        Button(action: resetTimerFromControls) {
                            HStack(spacing: 4 * scale) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 20 * scale, weight: .medium))
                                Text("Reset")
                                    .font(.system(size: 17 * scale, weight: .medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, minHeight: 52 * scale)
                            .background(Color(red: 0.91, green: 0.91, blue: 0.965))
                            .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
                        }
                        .buttonStyle(SoundPlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    Button(action: startTimerFromIdle) {
                        Text("Start timer")
                            .font(.system(size: 20 * scale, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .frame(maxWidth: .infinity, minHeight: 56 * scale)
                            .background(Color(red: 0.169, green: 0.098, blue: 0.706))
                            .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
                    }
                    .buttonStyle(SoundPlainButtonStyle())
                }
            }
            .frame(maxWidth: .infinity)

            Image("1")
                .resizable()
                .scaledToFit()
                .frame(width: 95 * scale, height: 95 * scale)
                .offset(x: 234 * scale, y: 0 * scale)

            Image("1")
                .resizable()
                .scaledToFit()
                .scaleEffect(x: -1, y: 1)
                .frame(width: 60 * scale, height: 60 * scale)
                .offset(x: 0 * scale, y: 246 * scale)
        }
        .padding(.vertical, 20 * scale)
        .padding(.horizontal, 16 * scale)
        .frame(maxWidth: .infinity, minHeight: 406 * scale)
        .background(Color(red: 0.965, green: 0.98, blue: 0.996))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
    }

    private var thicknessSlider: some View {
        GeometryReader { geo in
            let rawWidth = geo.size.width
            let width = rawWidth.isFinite ? max(rawWidth, 0) : 0
            let safeWidth = max(width, 1)
            let progress = max(0, min(1, thickness / 5))
            let knobX = width * progress

            Group {
                if width > 1 {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 100 * scale, style: .continuous)
                            .fill(Color(red: 0.169, green: 0.098, blue: 0.706).opacity(0.2))
                            .frame(width: width, height: 4 * scale)
                            .offset(y: 8 * scale)

                        RoundedRectangle(cornerRadius: 100 * scale, style: .continuous)
                            .fill(Color(red: 0.169, green: 0.098, blue: 0.706))
                            .frame(width: knobX, height: 4 * scale)
                            .offset(y: -5 * scale)

                        ZStack {
                            Image("Tooltip")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 39 * scale, height: 24 * scale)
                                .offset(y: -15 * scale)
                            Text(String(format: "%.1fcm", thickness))
                                .font(.system(size: 12 * scale, weight: .regular))
                                .foregroundStyle(.white)
                                .frame(width: 35 * scale, height: 15 * scale)
                                .offset(y: -15 * scale)
                        }
                        .offset(x: knobX - 19.5 * scale, y: 0)

                        Circle()
                            .fill(.white)
                            .overlay(
                                Circle().stroke(Color.black.opacity(0.1), lineWidth: 1 * scale)
                            )
                            .frame(width: 12 * scale, height: 12 * scale)
                            .shadow(color: .black.opacity(0.1), radius: 2 * scale, y: 2 * scale)
                            .offset(x: knobX - 6 * scale, y: 28 * scale)

                        HStack(spacing: 0) {
                            ForEach(0...10, id: \.self) { tick in
                                VStack(spacing: 2 * scale) {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.2))
                                        .frame(width: 1 * scale, height: 4 * scale)
                                    Text([0, 2, 4, 6, 8, 10].contains(tick) ? "\(tick)" : "")
                                        .font(.system(size: 8 * scale, weight: .regular))
                                        .foregroundStyle(Color.black.opacity(0.45))
                                        .frame(height: 10 * scale)
                                }
                                if tick != 10 {
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                        .frame(width: width, height: 18 * scale, alignment: .top)
                        .offset(y: 34 * scale)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x.isFinite ? value.location.x : 0
                                let clampedX = min(max(0, x), safeWidth)
                                let rawValue = (clampedX / safeWidth) * 5
                                thickness = (rawValue * 10).rounded() / 10
                            }
                    )
                } else {
                    Color.clear
                }
            }
        }
        .frame(height: 51 * scale)
    }

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

    private func targetButton(_ title: String) -> some View {
        let selected = selectedTarget == title
        return Button {
            selectedTarget = title
        } label: {
            Text(title)
                .font(.system(size: 18 * scale, weight: .semibold))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 40 * scale)
                .background(selected ? Color(red: 0.737, green: 0.737, blue: 0.929) : Color(red: 0.91, green: 0.91, blue: 0.965))
                .overlay(
                    RoundedRectangle(cornerRadius: 8 * scale, style: .continuous)
                        .stroke(selected ? Color(red: 0.169, green: 0.098, blue: 0.706) : .clear, lineWidth: 1 * scale)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8 * scale, style: .continuous))
        }
        .buttonStyle(SoundPlainButtonStyle())
    }

    private func methodButton(_ method: CookingMethod) -> some View {
        let selected = selectedMethod == method.title
        return Button {
            selectedMethod = method.title
        } label: {
            VStack(spacing: 8 * scale) {
                if method.usesAssetIcon {
                    Image(method.icon)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 24 * scale, height: 24 * scale)
                } else {
                    Image(systemName: method.icon)
                        .font(.system(size: 20 * scale))
                }
                Text(method.title)
                    .font(.system(size: 17 * scale, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, minHeight: 84 * scale)
            .background(selected ? Color(red: 0.737, green: 0.737, blue: 0.929) : Color(red: 0.91, green: 0.91, blue: 0.965))
            .overlay(
                RoundedRectangle(cornerRadius: 16 * scale, style: .continuous)
                    .stroke(selected ? Color(red: 0.169, green: 0.098, blue: 0.706) : .clear, lineWidth: 1 * scale)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
        }
        .buttonStyle(SoundPlainButtonStyle())
    }

    private func toggleTimer() {
        if remainingSeconds == 0 {
            resetTimerState()
        }
        hasTimerStarted = true
        if isTimerRunning {
            pauseTimer()
        } else {
            resumeTimer()
        }
    }

    private func tick() {
        guard isTimerRunning, remainingSeconds > 0 else { return }
        remainingSeconds -= 1

        if !didFireHalfway, remainingSeconds == timerPlan.flipAtSeconds {
            didFireHalfway = true
            statusMessage = "Flip now!"
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }

        if remainingSeconds == 0 {
            isTimerRunning = false
            hasTimerStarted = false
            statusMessage = "Done! Rest 2 min"
            let actualCookSeconds = completeCurrentRunAndMeasure()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            store.addCookingRecord(
                productName: selectedProduct == "Product" ? "Unknown fish" : selectedProduct,
                method: selectedMethod,
                thickness: thickness,
                targetTemperature: Int(selectedTarget.replacingOccurrences(of: "°C", with: "")) ?? 180,
                totalSeconds: timerPlan.totalSeconds,
                flipAtSeconds: timerPlan.flipAtSeconds,
                actualTotalSeconds: actualCookSeconds,
                tasteRating: tasteRating
            )
        }
    }

    private func resetTimerState() {
        isTimerRunning = false
        remainingSeconds = timerPlan.totalSeconds
        didFireHalfway = false
        accumulatedActiveSeconds = 0
        currentRunStartedAt = nil
        let flipMinute = max(1, timerPlan.flipAtSeconds / 60)
        statusMessage = "Flip at \(flipMinute) min"
    }

    private func startTimerFromIdle() {
        if remainingSeconds == 0 {
            resetTimerState()
        }
        hasTimerStarted = true
        resumeTimer()
    }

    private func resetTimerFromControls() {
        resetTimerState()
        hasTimerStarted = false
    }

    private func resumeTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        currentRunStartedAt = Date()
    }

    private func pauseTimer() {
        guard isTimerRunning else { return }
        isTimerRunning = false
        if let runStart = currentRunStartedAt {
            accumulatedActiveSeconds += Date().timeIntervalSince(runStart)
        }
        currentRunStartedAt = nil
    }

    private func completeCurrentRunAndMeasure() -> Int {
        if let runStart = currentRunStartedAt {
            accumulatedActiveSeconds += Date().timeIntervalSince(runStart)
        }
        currentRunStartedAt = nil
        let seconds = max(0, Int(accumulatedActiveSeconds.rounded()))
        accumulatedActiveSeconds = 0
        return seconds
    }

    private func formattedTime(_ totalSeconds: Int) -> String {
        let minutes = max(0, totalSeconds) / 60
        let seconds = max(0, totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

