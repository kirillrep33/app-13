//
//  NewSteakLogViewModel.swift
//  BufalloSteaklovers
//

import Foundation
import SwiftUI

final class NewSteakLogViewModel: ObservableObject {
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
    @Published var finalTempC: Double = 54 {
        didSet {
            guard finalTempC.isFinite, !finalTempC.isNaN else {
                finalTempC = 54
                return
            }
            let c = min(max(finalTempC, tempRange.lowerBound), tempRange.upperBound)
            if c != finalTempC { finalTempC = c }
        }
    }
    @Published var ratingIndex: Int = 1
    @Published var notesText: String = ""
    @Published var photoJPEGData: Data?
    /// Set after first write to disk (poor flow or success submit).
    @Published private(set) var cachedPhotoFilename: String?

    let thicknessRange: ClosedRange<Double> = 0.5...8
    let tempRange: ClosedRange<Double> = 45...75

    let ratingOptions: [(emoji: String, title: String)] = [
        ("😕", "Poor"),
        ("😐", "OK"),
        ("😍", "Great")
    ]

    var donenessLabel: String {
        DonenessThermometer.label(forTempC: finalTempC)
    }

    var isLogFormComplete: Bool {
        guard selectedCut != nil else { return false }
        let w = weightText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !w.isEmpty, Double(w) != nil else { return false }
        return true
    }

    /// Writes image to disk if needed; returns filename for draft / persistence.
    func ensurePhotoOnDisk() throws -> String? {
        guard let d = photoJPEGData else { return nil }
        if let c = cachedPhotoFilename { return c }
        let n = try PhotoFileStore.saveImageData(d)
        cachedPhotoFilename = n
        return n
    }

    func resetAfterSubmit() {
        selectedCut = nil
        meatCutExpanded = false
        thicknessCM = 4.5
        weightText = ""
        finalTempC = 54
        ratingIndex = 1
        notesText = ""
        photoJPEGData = nil
        cachedPhotoFilename = nil
    }

    func buildDraftForFailure() throws -> PendingSteakLogDraft {
        let w = Int(weightText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let photo = try ensurePhotoOnDisk()
        return PendingSteakLogDraft(
            cut: selectedCut ?? "",
            weightG: w,
            thicknessCM: thicknessCM,
            finalTempC: finalTempC,
            donenessLabel: donenessLabel,
            notes: notesText.trimmingCharacters(in: .whitespacesAndNewlines),
            photoFilename: photo
        )
    }

    func saveSuccessSession(repository: SteakDataRepository) throws {
        let w = Int(weightText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let photo = try ensurePhotoOnDisk()
        let session = PersistedSteakSession(
            id: UUID(),
            date: Date(),
            cut: selectedCut ?? "",
            weightG: w,
            thicknessCM: thicknessCM,
            finalTempC: finalTempC,
            donenessLabel: donenessLabel,
            rating: ratingIndex,
            notes: notesText.trimmingCharacters(in: .whitespacesAndNewlines),
            photoFilename: photo,
            restMinutes: nil,
            failureRecap: nil,
            failurePrimaryReason: nil,
            failureLesson: nil,
            failureResolved: nil
        )
        repository.add(session)
    }
}
