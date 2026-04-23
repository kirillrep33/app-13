//
//  SteakPersistenceModels.swift
//  BufalloSteaklovers
//

import Foundation

/// Single persisted cook log (success or analyzed failure).
struct PersistedSteakSession: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var cut: String
    var weightG: Int
    var thicknessCM: Double
    var finalTempC: Double
    var donenessLabel: String
    /// 0 = poor, 1 = OK, 2 = great
    var rating: Int
    var notes: String
    /// Filename in app Documents `SteakPhotos/` (not full path).
    var photoFilename: String?
    var restMinutes: Double?

    var failureRecap: String?
    var failurePrimaryReason: String?
    var failureLesson: String?
    var failureResolved: Bool?

    var isSuccess: Bool { rating >= 1 }
    var isAnalyzedFailure: Bool { rating == 0 && failureRecap != nil }
}

/// Passed from log tab into analyze-failure flow.
struct PendingSteakLogDraft: Equatable {
    var cut: String
    var weightG: Int
    var thicknessCM: Double
    var finalTempC: Double
    var donenessLabel: String
    var notes: String
    var photoFilename: String?
}
