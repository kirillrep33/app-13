//
//  SmartTimerView.swift
//  BufalloSteaklovers
//

import SwiftUI

struct SmartTimerView: View {
    @Environment(\.layoutScale) private var scale
    @StateObject private var vm = SmartTimerViewModel()

    var body: some View {
        VStack(spacing: 0) {
            SteakTabScreenHeader(title: "Smart Timer")
                .environment(\.layoutScale, scale)

            if vm.phase == .setup {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        meatCutSection
                            .padding(.top, fpScale(24, scale))

                        sliderBlock(
                            title: "Thickness (cm)",
                            valueText: String(format: "%.1f cm", vm.thicknessCM)
                        ) {
                            SteakFormSlider(value: $vm.thicknessCM, range: vm.thicknessRange, scale: scale)
                        }
                        .padding(.top, fpScale(20, scale))

                        fieldBlock(title: "Weight (g)") {
                            SteakFieldChrome(scale: scale) {
                                SteakUIKitFormTextField(
                                    text: $vm.weightText,
                                    placeholder: "Enter weight",
                                    keyboardType: .numberPad,
                                    returnKeyType: .default,
                                    showsDoneAccessory: true,
                                    fontSize: fpScale(13, scale)
                                )
                            }
                        }
                        .padding(.top, fpScale(20, scale))

                        donenessSection
                            .padding(.top, fpScale(20, scale))

                        if let t = vm.targetCenterTempC {
                            Text("Target center: \(t)°C")
                                .font(.system(size: fpScale(13, scale), weight: .medium))
                                .foregroundStyle(Color(steakHex: "FFC107"))
                                .padding(.top, fpScale(12, scale))
                        }

                        Color.clear.frame(height: fpScale(24, scale))
                    }
                    .padding(.horizontal, fpScale(24, scale))
                    .padding(.bottom, fpScale(74, scale))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: vm.selectedDoneness) { _ in
                    vm.updateTargetTempHint()
                }
                .onAppear {
                    vm.updateTargetTempHint()
                }
            } else if vm.phase == .running {
                SmartTimerRunningView(
                    steps: vm.sessionSteps,
                    currentStepIndex: $vm.sessionStepIndex,
                    remainingSeconds: $vm.sessionRemaining,
                    isPlaying: $vm.sessionPlaying,
                    onCancel: { vm.cancelRunningSession() },
                    onSkipStep: { vm.skipSessionStep() }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                SmartTimerCompletedView(restMinutes: vm.completedRestMinutes, onRetry: { vm.retryFromCompleted() })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(steakHex: "2D1B11"))
        .overlay(alignment: .bottom) {
            VStack(spacing: fpScale(12, scale)) {
                if vm.phase == .setup {
                    generateTimerButton
                } else if vm.phase == .completed {
                    retryTimerButton
                }
            }
            .padding(.horizontal, fpScale(24, scale))
            .padding(.top, fpScale(10, scale))
            .padding(.bottom, fpScale(8, scale))
            .frame(maxWidth: .infinity)
            .background(Color(steakHex: "2D1B11"))
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var generateTimerButton: some View {
        Button {
            guard vm.isFormReady else { return }
            vm.beginSession()
        } label: {
            HStack(spacing: fpScale(4, scale)) {
                Image(systemName: "clock")
                    .font(.system(size: fpScale(16, scale), weight: .medium))
                Text("Generate Timer")
                    .font(.system(size: fpScale(16, scale), weight: .semibold))
                    .tracking(-0.08)
            }
            .foregroundStyle(vm.isFormReady ? Color.white : Color(steakHex: "3E2723"))
            .frame(maxWidth: .infinity)
            .frame(height: fpScale(44, scale))
            .background(vm.isFormReady ? Color(steakHex: "FFC107") : Color(steakHex: "A1887F"))
            .clipShape(Capsule())
        }
        .buttonStyle(SteakSoundPlainButtonStyle())
        .allowsHitTesting(vm.isFormReady)
    }

    private var retryTimerButton: some View {
        Button(action: { vm.retryFromCompleted() }) {
            Text("Retry")
                .font(.system(size: fpScale(16, scale), weight: .semibold))
                .tracking(-0.08)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: fpScale(44, scale))
                .background(Color(steakHex: "FF5722"))
                .clipShape(Capsule())
        }
        .buttonStyle(SteakSoundPlainButtonStyle())
    }

    private var meatCutSection: some View {
        VStack(alignment: .leading, spacing: fpScale(12, scale)) {
            Text("Meat Cut")
                .font(.system(size: fpScale(16, scale), weight: .semibold))
                .foregroundStyle(Color.white)

            if vm.meatCutExpanded {
                expandedMeatCutPanel
            } else {
                collapsedMeatCutTrigger
            }
        }
    }

    private var collapsedMeatCutTrigger: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { vm.meatCutExpanded = true }
        } label: {
            SteakFieldChrome(scale: scale) {
                HStack {
                    Text(vm.selectedCut ?? "Meat Cut")
                        .font(.system(size: fpScale(13, scale), weight: vm.selectedCut == nil ? .regular : .medium))
                        .foregroundStyle(vm.selectedCut == nil ? Color(steakHex: "A1887F") : Color.white)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.down")
                        .font(.system(size: fpScale(12, scale), weight: .semibold))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .buttonStyle(SteakSoundPlainButtonStyle())
    }

    private var expandedMeatCutPanel: some View {
        let corner = fpScale(12, scale)
        let rowSpacing = fpScale(12, scale)

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text("Meat Cut")
                    .font(.system(size: fpScale(13, scale), weight: .regular))
                    .foregroundStyle(Color(steakHex: "A1887F"))
                Spacer(minLength: 0)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { vm.meatCutExpanded = false }
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: fpScale(12, scale), weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                .buttonStyle(SteakSoundPlainButtonStyle())
            }
            .padding(.horizontal, fpScale(12, scale))
            .padding(.top, fpScale(14, scale))
            .padding(.bottom, fpScale(10, scale))

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: rowSpacing) {
                    ForEach(SteakCatalog.meatCuts, id: \.self) { cut in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                vm.selectedCut = cut
                                vm.meatCutExpanded = false
                            }
                        } label: {
                            Text(cut)
                                .font(.system(size: fpScale(13, scale), weight: .medium))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(minHeight: fpScale(16, scale), alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(SteakSoundPlainButtonStyle())
                    }
                }
                .padding(.horizontal, fpScale(12, scale))
                .padding(.bottom, fpScale(14, scale))
            }
        }
        .frame(height: fpScale(328, scale))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Color(steakHex: "3E2723"))
                .shadow(color: Color.black.opacity(0.25), radius: fpScale(4, scale), x: 0, y: fpScale(4, scale))
        )
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
        )
    }

    private var donenessSection: some View {
        VStack(alignment: .leading, spacing: fpScale(12, scale)) {
            Text("Desired Doneness")
                .font(.system(size: fpScale(16, scale), weight: .semibold))
                .foregroundStyle(Color.white)

            if vm.donenessExpanded {
                expandedDonenessPanel
            } else {
                collapsedDonenessTrigger
            }
        }
    }

    private var collapsedDonenessTrigger: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { vm.donenessExpanded = true }
        } label: {
            SteakFieldChrome(scale: scale) {
                HStack {
                    Text(vm.selectedDoneness ?? "Desired Doneness")
                        .font(.system(size: fpScale(13, scale), weight: vm.selectedDoneness == nil ? .regular : .medium))
                        .foregroundStyle(vm.selectedDoneness == nil ? Color(steakHex: "A1887F") : Color.white)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.down")
                        .font(.system(size: fpScale(12, scale), weight: .semibold))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .buttonStyle(SteakSoundPlainButtonStyle())
    }

    private var expandedDonenessPanel: some View {
        let corner = fpScale(12, scale)
        let rowSpacing = fpScale(12, scale)

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text("Desired Doneness")
                    .font(.system(size: fpScale(13, scale), weight: .regular))
                    .foregroundStyle(Color(steakHex: "A1887F"))
                Spacer(minLength: 0)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { vm.donenessExpanded = false }
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: fpScale(12, scale), weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                .buttonStyle(SteakSoundPlainButtonStyle())
            }
            .padding(.horizontal, fpScale(12, scale))
            .padding(.top, fpScale(14, scale))
            .padding(.bottom, fpScale(10, scale))

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: rowSpacing) {
                    ForEach(SteakCatalog.donenessChoices, id: \.self) { d in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                vm.selectedDoneness = d
                                vm.donenessExpanded = false
                            }
                        } label: {
                            Text(d)
                                .font(.system(size: fpScale(13, scale), weight: .medium))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(minHeight: fpScale(16, scale), alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(SteakSoundPlainButtonStyle())
                    }
                }
                .padding(.horizontal, fpScale(12, scale))
                .padding(.bottom, fpScale(14, scale))
            }
        }
        .frame(height: fpScale(216, scale))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Color(steakHex: "3E2723"))
                .shadow(color: Color.black.opacity(0.25), radius: fpScale(4, scale), x: 0, y: fpScale(4, scale))
        )
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
        )
    }

    private func fieldBlock(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: fpScale(6, scale)) {
            Text(title)
                .font(.system(size: fpScale(16, scale), weight: .semibold))
                .foregroundStyle(Color.white)
            content()
        }
    }

    private func sliderBlock(
        title: String,
        valueText: String,
        @ViewBuilder control: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: fpScale(8, scale)) {
            HStack {
                Text(title)
                    .font(.system(size: fpScale(16, scale), weight: .semibold))
                    .foregroundStyle(Color.white)
                Spacer(minLength: 0)
                Text(valueText)
                    .font(.system(size: fpScale(16, scale), weight: .semibold))
                    .foregroundStyle(Color(steakHex: "FF5722"))
            }
            control()
        }
    }
}

#Preview {
    SmartTimerView()
        .environment(\.layoutScale, 1)
}
