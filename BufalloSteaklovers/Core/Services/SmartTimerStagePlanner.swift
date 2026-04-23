//
//  SmartTimerStagePlanner.swift
//  BufalloSteaklovers
//
//  TZ: dry (short room-temp window); sear side = thickness(cm)×0.6 min; ends 30 s; butter/herbs 30 s;
//  rest = 2×(sear1+sear2); weight >500 g → +20% sear time; cold-from-fridge inferred from weight/thickness.
//

import Foundation

struct SmartTimerPlanResult: Equatable {
    let steps: [SmartTimerStepModel]
    let targetCenterTempC: Int
}

enum SmartTimerStagePlanner {
    /// Heavier / thicker steaks get +1 min per sear side (straight-from-fridge style margin).
    static func inferColdFromFridge(weightG: Int, thicknessCM: Double) -> Bool {
        weightG >= 500 || thicknessCM >= 4.5
    }

    static func plan(
        weightG: Int,
        thicknessCM: Double,
        doneness: String
    ) -> SmartTimerPlanResult {
        let coldFromFridge = inferColdFromFridge(weightG: weightG, thicknessCM: thicknessCM)
        let dry = 10 * 60

        var sideSec = Int((thicknessCM * 0.6 * 60).rounded())
        sideSec = max(30, sideSec)

        let dKey = doneness.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let donenessMul: Double = {
            switch dKey {
            case "well done": return 1.14
            case "medium well": return 1.08
            case "medium": return 1.0
            case "medium rare": return 0.96
            case "rare": return 0.92
            case "blue rare": return 0.88
            default: return 1.0
            }
        }()
        sideSec = max(30, Int((Double(sideSec) * donenessMul).rounded()))

        if weightG > 500 {
            sideSec = Int((Double(sideSec) * 1.2).rounded())
        }
        if coldFromFridge {
            sideSec += 60
        }

        let endsSec = 30
        let butterSec = 30

        let searTotal = sideSec + sideSec
        let restSec = max(60, 2 * searTotal)

        let target = DonenessThermometer.targetTempCInt(forDoneness: doneness)

        let steps: [SmartTimerStepModel] = [
            .init(title: "Room temp dry", durationSeconds: dry),
            .init(title: "Sear side 1", durationSeconds: sideSec),
            .init(title: "Sear side 2", durationSeconds: sideSec),
            .init(title: "Sear edges", durationSeconds: endsSec),
            .init(title: "Butter & herbs", durationSeconds: butterSec),
            .init(title: "Rest", durationSeconds: restSec)
        ]

        return SmartTimerPlanResult(steps: steps, targetCenterTempC: target)
    }

    static func restMinutes(from plan: SmartTimerPlanResult) -> Int {
        guard let rest = plan.steps.last(where: { $0.title == "Rest" }) else { return 0 }
        return max(1, (rest.durationSeconds + 30) / 60)
    }
}
