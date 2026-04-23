//
//  SmartTimerRunningView.swift
//  BufalloSteaklovers
//

import SwiftUI

struct SmartTimerRunningView: View {
    @Environment(\.layoutScale) private var scale

    let steps: [SmartTimerStepModel]
    @Binding var currentStepIndex: Int
    @Binding var remainingSeconds: Int
    @Binding var isPlaying: Bool

    var onCancel: () -> Void
    var onSkipStep: () -> Void

    private var currentStep: SmartTimerStepModel? {
        guard steps.indices.contains(currentStepIndex) else { return nil }
        return steps[currentStepIndex]
    }

    private var timeString: String {
        Self.formatCountdown(remainingSeconds)
    }

    static func formatCountdown(_ t: Int) -> String {
        if t >= 3600 {
            let h = t / 3600
            let m = (t % 3600) / 60
            let s = t % 60
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        let m = t / 60
        let s = t % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        VStack(spacing: 0) {
            sessionToolbar
                .padding(.horizontal, fpScale(24, scale))
                .padding(.top, fpScale(24, scale))

            Spacer(minLength: fpScale(12, scale))

            timerRingBlock

            Spacer(minLength: fpScale(16, scale))

            transportControls
                .padding(.bottom, fpScale(20, scale))

            stepCardsRow
                .padding(.bottom, fpScale(16, scale))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sessionToolbar: some View {
        HStack(alignment: .center) {
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(size: fpScale(13, scale), weight: .medium))
                    .foregroundStyle(Color(steakHex: "A1887F"))
                    .padding(.horizontal, fpScale(12, scale))
                    .padding(.vertical, fpScale(6, scale))
                    .background(Color(steakHex: "3E2723"))
                    .clipShape(Capsule())
            }
            .buttonStyle(SteakSoundPlainButtonStyle())

            Spacer(minLength: 0)

            Text("Step \(currentStepIndex + 1) of \(max(steps.count, 1))")
                .font(.system(size: fpScale(16, scale), weight: .semibold))
                .foregroundStyle(Color(steakHex: "FF5722"))
        }
    }

    private var timerRingBlock: some View {
        let ring = fpScale(220, scale)
        let border = fpScale(4, scale)

        return ZStack {
            Circle()
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: border)
                .frame(width: ring, height: ring)

            VStack(spacing: fpScale(6, scale)) {
                Image("Icon-7")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: fpScale(24, scale), height: fpScale(24, scale))
                    .accessibilityHidden(true)

                Text(timeString)
                    .font(.system(size: fpScale(40, scale), weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.white)
                    .monospacedDigit()

                Text(currentStep?.title ?? "—")
                    .font(.system(size: fpScale(20, scale), weight: .regular))
                    .foregroundStyle(Color(steakHex: "FF5722"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: fpScale(180, scale))
            }
        }
    }

    private var transportControls: some View {
        let d = fpScale(76, scale)
        return HStack(spacing: fpScale(12, scale)) {
            Button {
                isPlaying.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(steakHex: "FF5722"))
                        .frame(width: d, height: d)
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: fpScale(28, scale), weight: .bold))
                        .foregroundStyle(Color.white)
                        .offset(x: isPlaying ? 0 : fpScale(2, scale))
                }
            }
            .buttonStyle(SteakSoundPlainButtonStyle())
            .accessibilityLabel(isPlaying ? "Pause" : "Play")

            Button(action: onSkipStep) {
                ZStack {
                    Circle()
                        .fill(Color(steakHex: "3E2723"))
                        .frame(width: d, height: d)
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: fpScale(26, scale), weight: .medium))
                        .foregroundStyle(Color(steakHex: "A1887F"))
                }
            }
            .buttonStyle(SteakSoundPlainButtonStyle())
            .accessibilityLabel("Skip step")
        }
    }

    private var stepCardsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: fpScale(16, scale)) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    stepCard(step: step, index: index, isActive: index == currentStepIndex)
                }
            }
            .padding(.horizontal, fpScale(24, scale))
        }
    }

    private func stepCard(step: SmartTimerStepModel, index: Int, isActive: Bool) -> some View {
        let w = fpScale(140, scale)
        let h = fpScale(56, scale)
        let r = fpScale(16, scale)
        let timeForStep = Self.formatCountdown(step.durationSeconds)

        return Button {
            currentStepIndex = index
            remainingSeconds = step.durationSeconds
            isPlaying = false
        } label: {
            VStack(alignment: .leading, spacing: fpScale(10, scale)) {
                Text(step.title)
                    .font(.system(size: fpScale(13, scale), weight: .medium))
                    .foregroundStyle(isActive ? Color.white : Color(steakHex: "A1887F"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.leading)
                Text(timeForStep)
                    .font(.system(size: fpScale(15, scale), weight: .bold))
                    .foregroundStyle(Color.white)
                    .monospacedDigit()
            }
            .padding(.horizontal, fpScale(12, scale))
            .padding(.vertical, fpScale(6, scale))
            .frame(width: w, height: h, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .fill(isActive ? Color(steakHex: "FF5722") : Color(steakHex: "3E2723"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
            )
        }
        .buttonStyle(SteakSoundPlainButtonStyle())
    }
}
