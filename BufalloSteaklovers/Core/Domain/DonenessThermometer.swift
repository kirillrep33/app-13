//
//  DonenessThermometer.swift
//  BufalloSteaklovers
//

import Foundation
import SwiftUI

/// TZ temperature bands (°C) for labels and picker sync.
enum DonenessThermometer {
    static func label(forTempC temp: Double) -> String {
        switch temp {
        case ..<49.5: return "Blue Rare"
        case ..<52.5: return "Rare"
        case ..<55.5: return "Medium Rare"
        case ..<60.5: return "Medium"
        case ..<65.5: return "Medium Well"
        default: return "Well Done"
        }
    }

    /// Midpoint target for timer / hints.
    static func midpointTempC(forDoneness title: String) -> Double {
        switch title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "blue rare": return 47.5
        case "rare": return 51
        case "medium rare": return 54
        case "medium": return 58
        case "medium well": return 63
        case "well done": return 68
        default: return 54
        }
    }

    static func targetTempCInt(forDoneness title: String) -> Int {
        Int(midpointTempC(forDoneness: title).rounded())
    }

    static func swatchHex(forLabel label: String) -> String {
        switch label {
        case "Blue Rare": return "6A1B9A"
        case "Rare": return "D32F2F"
        case "Medium Rare": return "FF5252"
        case "Medium": return "FF8A80"
        case "Medium Well": return "8D6E63"
        case "Well Done": return "F95F00"
        default: return "A1887F"
        }
    }

    static func dotColor(forLabel label: String) -> Color {
        Color(steakHex: swatchHex(forLabel: label))
    }
}
