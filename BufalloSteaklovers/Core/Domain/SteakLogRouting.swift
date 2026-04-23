//
//  SteakLogRouting.swift
//  BufalloSteaklovers
//

import Foundation

enum SteakLogSubmission {
    case savedToSuccesses
    case openFailureArchive(PendingSteakLogDraft)
}

enum LogTabRoute: Equatable {
    case newSteak
    case analyzeFailure(PendingSteakLogDraft)
}
