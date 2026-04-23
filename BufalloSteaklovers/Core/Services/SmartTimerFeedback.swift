//
//  SmartTimerFeedback.swift
//  BufalloSteaklovers
//

import AudioToolbox

enum SmartTimerFeedback {
    static func playStepTransition() {
        AudioServicesPlaySystemSound(1104)
    }

    static func playSessionComplete() {
        AudioServicesPlaySystemSound(1025)
    }
}
