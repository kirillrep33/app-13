//
//  SmartTimerViewModel.swift
//  BufalloSteaklovers
//

import Combine
import Foundation

final class SmartTimerViewModel: ObservableObject {
    enum Phase: Equatable {
        case setup
        case running
        case completed
    }

    @Published var phase: Phase = .setup
    @Published var sessionSteps: [SmartTimerStepModel] = []
    @Published var sessionStepIndex: Int = 0
    @Published var sessionRemaining: Int = 0
    @Published var sessionPlaying: Bool = false
    @Published var completedRestMinutes: Int = 8

    @Published var selectedCut: String?
    @Published var meatCutExpanded = false
    @Published var thicknessCM: Double = 4.5 {
        didSet {
            guard thicknessCM.isFinite, !thicknessCM.isNaN else {
                thicknessCM = 4.5
                return
            }
            let c = min(max(thicknessCM, thicknessRange.lowerBound), thicknessRange.upperBound)
            if c != thicknessCM { thicknessCM = c }
        }
    }
    @Published var weightText: String = ""
    @Published var selectedDoneness: String?
    @Published var donenessExpanded = false

    @Published var targetCenterTempC: Int?

    private var tickCancellable: AnyCancellable?

    let thicknessRange: ClosedRange<Double> = 0.5...8

    var isFormReady: Bool {
        guard selectedCut != nil else { return false }
        guard selectedDoneness != nil else { return false }
        let w = weightText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !w.isEmpty, Int(w) != nil else { return false }
        return true
    }

    func updateTargetTempHint() {
        guard let d = selectedDoneness else {
            targetCenterTempC = nil
            return
        }
        targetCenterTempC = DonenessThermometer.targetTempCInt(forDoneness: d)
    }

    func beginSession() {
        guard isFormReady else { return }
        let wTrim = weightText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let w = Int(wTrim) else { return }
        let plan = SmartTimerStagePlanner.plan(
            weightG: w,
            thicknessCM: thicknessCM,
            doneness: selectedDoneness ?? ""
        )
        sessionSteps = plan.steps
        completedRestMinutes = SmartTimerStagePlanner.restMinutes(from: plan)
        guard let first = sessionSteps.first else { return }
        sessionStepIndex = 0
        sessionRemaining = first.durationSeconds
        sessionPlaying = false
        phase = .running
        startTicking()
    }

    func cancelRunningSession() {
        sessionPlaying = false
        stopTicking()
        phase = .setup
    }

    func completeSession() {
        sessionPlaying = false
        sessionRemaining = 0
        stopTicking()
        SmartTimerFeedback.playSessionComplete()
        phase = .completed
    }

    func retryFromCompleted() {
        phase = .setup
    }

    func skipSessionStep() {
        sessionPlaying = false
        if sessionStepIndex < sessionSteps.count - 1 {
            SmartTimerFeedback.playStepTransition()
            sessionStepIndex += 1
            sessionRemaining = sessionSteps[sessionStepIndex].durationSeconds
        } else {
            completeSession()
        }
    }

    private func startTicking() {
        stopTicking()
        tickCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.handleSessionTick()
            }
    }

    private func stopTicking() {
        tickCancellable?.cancel()
        tickCancellable = nil
    }

    private func handleSessionTick() {
        guard phase == .running, sessionPlaying else { return }
        guard !sessionSteps.isEmpty else { return }

        if sessionRemaining > 0 {
            sessionRemaining -= 1
        }

        if sessionRemaining == 0 {
            if sessionStepIndex < sessionSteps.count - 1 {
                SmartTimerFeedback.playStepTransition()
                sessionStepIndex += 1
                sessionRemaining = sessionSteps[sessionStepIndex].durationSeconds
            } else {
                completeSession()
            }
        }
    }

}
