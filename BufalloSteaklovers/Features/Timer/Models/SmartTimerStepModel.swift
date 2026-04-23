//
//  SmartTimerStepModel.swift
//  BufalloSteaklovers
//

import Foundation

struct SmartTimerStepModel: Identifiable, Equatable {
    let id: UUID
    let title: String
    let durationSeconds: Int

    init(id: UUID = UUID(), title: String, durationSeconds: Int) {
        self.id = id
        self.title = title
        self.durationSeconds = durationSeconds
    }
}
