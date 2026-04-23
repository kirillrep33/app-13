//
//  StatisticsViewModel.swift
//  BufalloSteaklovers
//

import Foundation
import SwiftUI

struct StatisticsSnapshot {
    var hasAnyLogs: Bool
    var totalSteaks: Int
    var successRatePercent: Int
    var avgTempC: Int
    var favoriteCut: String
    var avgRestMinutes: String
    /// Normalized 0...1 for line chart (x = temp, y = taste tier).
    var tempTasteLinePoints: [(CGFloat, CGFloat)]
    /// All catalog doneness levels (six slices).
    var donenessSlices: [(title: String, percent: Double, hex: String)]

    static let empty = StatisticsSnapshot(
        hasAnyLogs: false,
        totalSteaks: 0,
        successRatePercent: 0,
        avgTempC: 0,
        favoriteCut: "—",
        avgRestMinutes: "—",
        tempTasteLinePoints: [],
        donenessSlices: StatisticsBuilder.equalSixDonenessSlices()
    )
}

enum StatisticsBuilder {
    private static let calendar = Calendar.current

    static func filterSessions(_ sessions: [PersistedSteakSession], periodIndex: Int) -> [PersistedSteakSession] {
        let now = Date()
        let from: Date?
        switch periodIndex {
        case 0: from = calendar.date(byAdding: .day, value: -7, to: now)
        case 1: from = calendar.date(byAdding: .month, value: -1, to: now)
        case 2: from = calendar.date(byAdding: .year, value: -1, to: now)
        default: from = nil
        }
        guard let f = from else { return sessions }
        return sessions.filter { $0.date >= f }
    }

    static func equalSixDonenessSlices() -> [(title: String, percent: Double, hex: String)] {
        SteakCatalog.donenessChoices.map {
            ($0, 1.0 / 6.0, DonenessThermometer.swatchHex(forLabel: $0))
        }
    }

    static func normalizedDonenessLabel(_ raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if SteakCatalog.donenessChoices.contains(t) { return t }
        let lower = t.lowercased()
        if let match = SteakCatalog.donenessChoices.first(where: { $0.lowercased() == lower }) {
            return match
        }
        return DonenessThermometer.label(forTempC: 54)
    }

    static func build(sessions: [PersistedSteakSession], periodIndex: Int) -> StatisticsSnapshot {
        let s = filterSessions(sessions, periodIndex: periodIndex)
        guard !s.isEmpty else {
            return .empty
        }

        let successes = s.filter(\.isSuccess)
        let failures = s.filter(\.isAnalyzedFailure)
        let total = s.count
        let denom = successes.count + failures.count
        let rate = denom > 0 ? Int(round(Double(successes.count) / Double(denom) * 100)) : 0

        let avgTemp: Int
        if successes.isEmpty {
            avgTemp = Int(s.map(\.finalTempC).reduce(0, +) / Double(max(s.count, 1)).rounded())
        } else {
            let sum = successes.map(\.finalTempC).reduce(0, +)
            avgTemp = Int((sum / Double(successes.count)).rounded())
        }

        let favorite: String
        if successes.isEmpty {
            favorite = "—"
        } else {
            var counts: [String: Int] = [:]
            for x in successes {
                counts[x.cut, default: 0] += 1
            }
            favorite = counts.max(by: { $0.value < $1.value })?.key ?? "—"
        }

        let rests = successes.compactMap(\.restMinutes)
        let avgRest: String
        if rests.isEmpty {
            avgRest = "—"
        } else {
            let m = rests.reduce(0, +) / Double(rests.count)
            avgRest = String(format: "%.0f min", m)
        }

        let linePoints: [(CGFloat, CGFloat)] = successes.map { log in
            let span = 75.0 - 40.0
            let xNorm: CGFloat
            if span > 0 {
                xNorm = CGFloat((log.finalTempC - 40) / span).steakClamped(to: 0...1)
            } else {
                xNorm = 0.5
            }
            let yNorm: CGFloat = log.rating >= 2 ? 0.05 : (log.rating >= 1 ? 0.5 : 0.95)
            return (xNorm, yNorm)
        }.sorted { $0.0 < $1.0 }

        let donenessSlices: [(title: String, percent: Double, hex: String)]
        if successes.isEmpty {
            donenessSlices = equalSixDonenessSlices()
        } else {
            var counts: [String: Int] = Dictionary(uniqueKeysWithValues: SteakCatalog.donenessChoices.map { ($0, 0) })
            for log in successes {
                let key = normalizedDonenessLabel(log.donenessLabel)
                counts[key, default: 0] += 1
            }
            let total = Double(successes.count)
            donenessSlices = SteakCatalog.donenessChoices.map { title in
                let c = counts[title] ?? 0
                return (title, Double(c) / total, DonenessThermometer.swatchHex(forLabel: title))
            }
        }

        return StatisticsSnapshot(
            hasAnyLogs: true,
            totalSteaks: total,
            successRatePercent: rate,
            avgTempC: avgTemp,
            favoriteCut: favorite,
            avgRestMinutes: avgRest,
            tempTasteLinePoints: linePoints,
            donenessSlices: donenessSlices
        )
    }
}

private extension CGFloat {
    func steakClamped(to r: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, r.lowerBound), r.upperBound)
    }
}

final class StatisticsViewModel: ObservableObject {
    @Published var periodIndex: Int = 0
    @Published private(set) var snapshot: StatisticsSnapshot = .empty

    func recompute(using repository: SteakDataRepository) {
        snapshot = StatisticsBuilder.build(sessions: repository.sessions, periodIndex: periodIndex)
    }
}
