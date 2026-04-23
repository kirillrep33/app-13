//
//  ArchiveTabView.swift
//  BufalloSteaklovers
//

import SwiftUI
import UIKit

enum ArchiveListSegment: Int, CaseIterable {
    case failures
    case successes

    var title: String {
        switch self {
        case .failures: return "Failures"
        case .successes: return "Successes"
        }
    }
}

struct ArchiveFailureEntry: Identifiable {
    let id: UUID
    let cutLabel: String
    let dateDisplay: String
    let recap: String
    let primaryReason: String
    let lesson: String
    let showsHeroImage: Bool
    /// Tapping Fixed keeps the card in the archive and shows a green checkmark.
    var isResolved: Bool

    init(
        id: UUID = UUID(),
        cutLabel: String,
        dateDisplay: String,
        recap: String,
        primaryReason: String,
        lesson: String,
        showsHeroImage: Bool,
        isResolved: Bool = false
    ) {
        self.id = id
        self.cutLabel = cutLabel
        self.dateDisplay = dateDisplay
        self.recap = recap
        self.primaryReason = primaryReason
        self.lesson = lesson
        self.showsHeroImage = showsHeroImage
        self.isResolved = isResolved
    }
}

struct ArchiveSuccessEntry: Identifiable {
    let id: UUID
    let cutName: String
    let dateDisplay: String
    let weightThicknessLine: String
    let tempText: String
    let donenessLabel: String
    /// Flame accent: e.g. `FF5252` (medium rare) or `D32F2F` (rare) per design.
    let donenessFlameHex: String
    let note: String
    let showsHeroImage: Bool
    let photoFilename: String?

    init(
        id: UUID = UUID(),
        cutName: String,
        dateDisplay: String,
        weightThicknessLine: String,
        tempText: String,
        donenessLabel: String,
        donenessFlameHex: String,
        note: String,
        showsHeroImage: Bool,
        photoFilename: String? = nil
    ) {
        self.id = id
        self.cutName = cutName
        self.dateDisplay = dateDisplay
        self.weightThicknessLine = weightThicknessLine
        self.tempText = tempText
        self.donenessLabel = donenessLabel
        self.donenessFlameHex = donenessFlameHex
        self.note = note
        self.showsHeroImage = showsHeroImage
        self.photoFilename = photoFilename
    }
}

private struct ArchiveSegmentedPicker: View {
    @Binding var selection: ArchiveListSegment
    @Environment(\.layoutScale) private var scale

    private func pillFill(for segment: ArchiveListSegment) -> Color {
        switch segment {
        case .failures: return Color(steakHex: "D32F2F")
        case .successes: return Color(steakHex: "4CAF50")
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ArchiveListSegment.allCases, id: \.rawValue) { segment in
                let selected = selection == segment
                Button {
                    selection = segment
                } label: {
                    Text(segment.title)
                        .font(.system(size: fpScale(10, scale), weight: .semibold))
                        .tracking(-0.08)
                        .foregroundStyle(Color.white)
                        .opacity(selected ? 1 : 0.92)
                        .frame(maxWidth: .infinity)
                        .frame(height: fpScale(28, scale))
                        .background(
                            Group {
                                if selected {
                                    RoundedRectangle(cornerRadius: fpScale(7, scale), style: .continuous)
                                        .fill(pillFill(for: segment))
                                        .shadow(
                                            color: Color.black.opacity(0.12),
                                            radius: fpScale(4, scale),
                                            x: 0,
                                            y: fpScale(3, scale)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: fpScale(7, scale), style: .continuous)
                                                .strokeBorder(Color.black.opacity(0.04), lineWidth: 0.5)
                                        )
                                }
                            }
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(SteakSoundPlainButtonStyle())
            }
        }
        .padding(fpScale(2, scale))
        .frame(height: fpScale(32, scale))
        .background(
            RoundedRectangle(cornerRadius: fpScale(8, scale), style: .continuous)
                .fill(Color(steakHex: "3E2723"))
        )
    }
}

private struct FailureCardHeroImage: View {
    let scale: CGFloat

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(steakHex: "5D4037"),
                    Color(steakHex: "3E2723")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "flame.fill")
                .font(.system(size: fpScale(40, scale)))
                .foregroundStyle(Color(steakHex: "FF5722").opacity(0.35))
        }
        .frame(height: fpScale(128, scale))
        .frame(maxWidth: .infinity)
        .clipped()
    }
}

private struct ArchiveFailureCardView: View {
    let entry: ArchiveFailureEntry
    let scale: CGFloat
    var onMarkFixed: () -> Void

    private let cardCorner = CGFloat(12)
    private let contentInset: CGFloat = 12

    var body: some View {
        let c = fpScale(cardCorner, scale)
        let inset = fpScale(contentInset, scale)

        VStack(alignment: .leading, spacing: 0) {
            if entry.showsHeroImage {
                FailureCardHeroImage(scale: scale)
            }

            VStack(alignment: .leading, spacing: fpScale(12, scale)) {
                HStack(alignment: .center, spacing: fpScale(8, scale)) {
                    Text(entry.cutLabel)
                        .font(.system(size: fpScale(16, scale), weight: .semibold))
                        .foregroundStyle(Color(steakHex: "FFC107"))
                    Spacer(minLength: fpScale(8, scale))
                    Text(entry.dateDisplay)
                        .font(.system(size: fpScale(11, scale), weight: .regular))
                        .foregroundStyle(Color(steakHex: "A1887F"))
                    if entry.isResolved {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: fpScale(22, scale), weight: .medium))
                            .foregroundStyle(Color(steakHex: "4CAF50"))
                            .accessibilityLabel("Marked fixed")
                    }
                }

                VStack(alignment: .leading, spacing: fpScale(4, scale)) {
                    Text("Error")
                        .font(.system(size: fpScale(12, scale), weight: .semibold))
                        .foregroundStyle(Color(steakHex: "D32F2F"))
                    Text("\"\(entry.recap)\"")
                        .font(.system(size: fpScale(14, scale), weight: .regular))
                        .foregroundStyle(Color.white)
                        .lineSpacing(fpScale(3, scale))
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: fpScale(4, scale)) {
                    Text("Reason")
                        .font(.system(size: fpScale(12, scale), weight: .semibold))
                        .foregroundStyle(Color(steakHex: "A1887F"))
                    HStack(alignment: .center, spacing: fpScale(6, scale)) {
                        Image(systemName: "list.bullet.circle.fill")
                            .font(.system(size: fpScale(14, scale), weight: .semibold))
                            .foregroundStyle(Color(steakHex: "D32F2F"))
                        Text(entry.primaryReason)
                            .font(.system(size: fpScale(13, scale), weight: .medium))
                            .foregroundStyle(Color(steakHex: "D32F2F"))
                    }
                }

                VStack(alignment: .leading, spacing: fpScale(6, scale)) {
                    Text("Lesson")
                        .font(.system(size: fpScale(14, scale), weight: .semibold))
                        .foregroundStyle(Color(steakHex: "FFC107"))
                    Text(entry.lesson)
                        .font(.system(size: fpScale(12, scale), weight: .regular))
                        .italic()
                        .foregroundStyle(Color.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, fpScale(12, scale))
                .padding(.vertical, fpScale(10, scale))
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(steakHex: "2D1B11"))
                .clipShape(RoundedRectangle(cornerRadius: fpScale(12, scale), style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: fpScale(12, scale), style: .continuous)
                        .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(0.3, fpScale(0.3, scale)))
                )

                if entry.isResolved {
                    HStack(spacing: fpScale(4, scale)) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: fpScale(18, scale), weight: .medium))
                        Text("Fixed & Learned")
                            .font(.system(size: fpScale(16, scale), weight: .semibold))
                            .tracking(-0.08)
                    }
                    .foregroundStyle(Color(steakHex: "4CAF50"))
                    .frame(maxWidth: .infinity)
                    .frame(height: fpScale(44, scale))
                    .background(Color(red: 76 / 255, green: 175 / 255, blue: 80 / 255).opacity(0.22))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Color(steakHex: "4CAF50").opacity(0.65), lineWidth: 0.5)
                    )
                    .allowsHitTesting(false)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Fixed and learned")
                } else {
                    Button(action: onMarkFixed) {
                        HStack(spacing: fpScale(4, scale)) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: fpScale(18, scale), weight: .medium))
                            Text("Mark as Fixed")
                                .font(.system(size: fpScale(16, scale), weight: .semibold))
                                .tracking(-0.08)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .foregroundStyle(Color(steakHex: "4CAF50"))
                        .frame(maxWidth: .infinity)
                        .frame(height: fpScale(44, scale))
                        .background(Color(red: 76 / 255, green: 175 / 255, blue: 80 / 255).opacity(0.15))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(Color(steakHex: "4CAF50"), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(SteakSoundPlainButtonStyle())
                }
            }
            .padding(inset)
        }
        .background(
            RoundedRectangle(cornerRadius: c, style: .continuous)
                .fill(Color(steakHex: "3E2723"))
        )
        .clipShape(RoundedRectangle(cornerRadius: c, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: c, style: .continuous)
                .strokeBorder(Color(steakHex: "D32F2F"), lineWidth: max(0.3, fpScale(0.3, scale)))
        )
    }
}

/// Swipe left: compact 40×40 delete (#D32F2F, radius 8), not full-height `swipeActions`.
/// Single `offset` + anchor at gesture lock — predictable, no GestureState / double offset.
private struct ArchiveFailureSwipeRow: View {
    let entry: ArchiveFailureEntry
    let scale: CGFloat
    var onMarkFixed: () -> Void
    var onDelete: () -> Void

    @State private var offset: CGFloat = 0
    /// Snapshot of `offset` when the horizontal drag is recognized; `translation` is from drag start.
    @State private var dragAnchor: CGFloat?

    private var deleteSide: CGFloat { fpScale(40, scale) }
    /// Space between card edge and delete control when row is open.
    private var cardDeleteGap: CGFloat { fpScale(6, scale) }
    private var maxReveal: CGFloat { deleteSide + cardDeleteGap }

    private func clampOffset(_ x: CGFloat) -> CGFloat {
        min(0, max(-maxReveal, x))
    }

    /// Quantize to 0.5 pt steps to reduce subpixel shimmer.
    private func quantize(_ x: CGFloat) -> CGFloat {
        (x * 2).rounded() / 2
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 36, coordinateSpace: .local)
            .onChanged { g in
                let w = g.translation.width
                let h = g.translation.height

                if dragAnchor == nil {
                    guard max(abs(w), abs(h)) > 10 else { return }

                    if offset <= -0.5 {
                        // Row open: ignore vertical scroll unless clearly horizontal (swipe right to close).
                        guard abs(w) >= abs(h) + 4 || w > 12 else { return }
                    } else {
                        // Row closed: left swipe needs clear horizontal intent or strong left pull.
                        guard abs(w) >= abs(h) + 5 || w <= -14 else { return }
                    }
                    dragAnchor = offset
                }

                guard let anchor = dragAnchor else { return }
                offset = quantize(clampOffset(anchor + w))
            }
            .onEnded { _ in
                let hadLockedAnchor = dragAnchor != nil
                dragAnchor = nil

                guard hadLockedAnchor || abs(offset) > 0.5 else { return }

                let midpoint = -maxReveal * 0.5
                let target: CGFloat = offset < midpoint ? -maxReveal : 0

                withAnimation(.easeOut(duration: 0.22)) {
                    offset = target
                }
            }
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            ArchiveFailureCardView(entry: entry, scale: scale, onMarkFixed: onMarkFixed)
                .offset(x: offset)
                .contentShape(Rectangle())
                .simultaneousGesture(swipeGesture)

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: fpScale(15, scale), weight: .medium))
                    .foregroundStyle(Color.white)
                    .frame(width: fpScale(24, scale), height: fpScale(24, scale))
                    .frame(width: deleteSide, height: deleteSide)
                    .background(Color(steakHex: "D32F2F"))
                    .clipShape(RoundedRectangle(cornerRadius: fpScale(8, scale), style: .continuous))
            }
            .buttonStyle(SteakSoundPlainButtonStyle())
            .accessibilityLabel("Delete")
            .padding(.trailing, 0)
            .offset(x: fpScale(8, scale))
            .opacity(offset < -6 ? 1 : 0)
            .allowsHitTesting(offset < -deleteSide * 0.35)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

private struct ArchiveSuccessSwipeRow: View {
    let entry: ArchiveSuccessEntry
    let scale: CGFloat
    var onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var dragAnchor: CGFloat?

    private var deleteSide: CGFloat { fpScale(40, scale) }
    private var cardDeleteGap: CGFloat { fpScale(6, scale) }
    private var maxReveal: CGFloat { deleteSide + cardDeleteGap }

    private func clampOffset(_ x: CGFloat) -> CGFloat {
        min(0, max(-maxReveal, x))
    }

    private func quantize(_ x: CGFloat) -> CGFloat {
        (x * 2).rounded() / 2
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 36, coordinateSpace: .local)
            .onChanged { g in
                let w = g.translation.width
                let h = g.translation.height

                if dragAnchor == nil {
                    guard max(abs(w), abs(h)) > 10 else { return }

                    if offset <= -0.5 {
                        guard abs(w) >= abs(h) + 4 || w > 12 else { return }
                    } else {
                        guard abs(w) >= abs(h) + 5 || w <= -14 else { return }
                    }
                    dragAnchor = offset
                }

                guard let anchor = dragAnchor else { return }
                offset = quantize(clampOffset(anchor + w))
            }
            .onEnded { _ in
                let hadLockedAnchor = dragAnchor != nil
                dragAnchor = nil

                guard hadLockedAnchor || abs(offset) > 0.5 else { return }

                let midpoint = -maxReveal * 0.5
                let target: CGFloat = offset < midpoint ? -maxReveal : 0

                withAnimation(.easeOut(duration: 0.22)) {
                    offset = target
                }
            }
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            ArchiveSuccessCardView(entry: entry, scale: scale)
                .offset(x: offset)
                .contentShape(Rectangle())
                .simultaneousGesture(swipeGesture)

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: fpScale(15, scale), weight: .medium))
                    .foregroundStyle(Color.white)
                    .frame(width: fpScale(24, scale), height: fpScale(24, scale))
                    .frame(width: deleteSide, height: deleteSide)
                    .background(Color(steakHex: "D32F2F"))
                    .clipShape(RoundedRectangle(cornerRadius: fpScale(8, scale), style: .continuous))
            }
            .buttonStyle(SteakSoundPlainButtonStyle())
            .accessibilityLabel("Delete")
            .padding(.trailing, 0)
            .offset(x: fpScale(8, scale))
            .opacity(offset < -6 ? 1 : 0)
            .allowsHitTesting(offset < -deleteSide * 0.35)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

private struct ArchiveSuccessCardView: View {
    let entry: ArchiveSuccessEntry
    let scale: CGFloat

    private let cardCorner = CGFloat(12)
    private let contentInset: CGFloat = 12

    var body: some View {
        let c = fpScale(cardCorner, scale)
        let inset = fpScale(contentInset, scale)
        let innerR = fpScale(12, scale)
        let hairline = max(0.3, fpScale(0.3, scale))

        VStack(alignment: .leading, spacing: 0) {
            if entry.showsHeroImage {
                if let fn = entry.photoFilename,
                   let data = PhotoFileStore.loadImageData(filename: fn),
                   let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(height: fpScale(128, scale))
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    FailureCardHeroImage(scale: scale)
                }
            }

            VStack(alignment: .leading, spacing: fpScale(12, scale)) {
                HStack(alignment: .firstTextBaseline) {
                    Text(entry.cutName)
                        .font(.system(size: fpScale(16, scale), weight: .semibold))
                        .foregroundStyle(Color(steakHex: "FFC107"))
                    Spacer(minLength: fpScale(8, scale))
                    Text(entry.dateDisplay)
                        .font(.system(size: fpScale(11, scale), weight: .regular))
                        .foregroundStyle(Color(steakHex: "A1887F"))
                }

                Text(entry.weightThicknessLine)
                    .font(.system(size: fpScale(12, scale), weight: .regular))
                    .foregroundStyle(Color(steakHex: "A1887F"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(alignment: .top, spacing: fpScale(12, scale)) {
                    VStack(spacing: fpScale(6, scale)) {
                        Spacer(minLength: 0)
                        Text("TEMP")
                            .font(.system(size: fpScale(10, scale), weight: .semibold))
                            .foregroundStyle(Color(steakHex: "A1887F"))
                            .textCase(.uppercase)
                        Text(entry.tempText)
                            .font(.system(size: fpScale(14, scale), weight: .bold))
                            .foregroundStyle(Color(steakHex: "FF5722"))
                        Spacer(minLength: 0)
                    }
                    .frame(width: fpScale(64, scale), height: fpScale(57, scale))
                    .frame(maxWidth: fpScale(64, scale))
                    .multilineTextAlignment(.center)
                    .background(Color(steakHex: "2D1B11"))
                    .clipShape(RoundedRectangle(cornerRadius: innerR, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: innerR, style: .continuous)
                            .strokeBorder(Color(steakHex: "A1887F"), lineWidth: hairline)
                    )

                    VStack(spacing: fpScale(4, scale)) {
                        Text("DONENESS")
                            .font(.system(size: fpScale(10, scale), weight: .semibold))
                            .foregroundStyle(Color(steakHex: "A1887F"))
                            .textCase(.uppercase)
                            .frame(maxWidth: .infinity)
                            .padding(.top, fpScale(10, scale))
                        HStack(spacing: fpScale(4, scale)) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: fpScale(14, scale)))
                                .foregroundStyle(Color(steakHex: entry.donenessFlameHex))
                            Text(entry.donenessLabel)
                                .font(.system(size: fpScale(14, scale), weight: .bold))
                                .foregroundStyle(Color.white)
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: fpScale(57, scale))
                    .padding(.horizontal, fpScale(8, scale))
                    .background(Color(steakHex: "2D1B11"))
                    .clipShape(RoundedRectangle(cornerRadius: innerR, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: innerR, style: .continuous)
                            .strokeBorder(Color(steakHex: "A1887F"), lineWidth: hairline)
                    )
                }

                VStack(alignment: .leading, spacing: fpScale(6, scale)) {
                    Text("Note")
                        .font(.system(size: fpScale(14, scale), weight: .semibold))
                        .foregroundStyle(Color(steakHex: "4CAF50"))
                    Text(entry.note)
                        .font(.system(size: fpScale(12, scale), weight: .regular))
                        .italic()
                        .foregroundStyle(Color.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, fpScale(12, scale))
                .padding(.vertical, fpScale(10, scale))
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(steakHex: "2D1B11"))
                .clipShape(RoundedRectangle(cornerRadius: innerR, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: innerR, style: .continuous)
                        .strokeBorder(Color(steakHex: "A1887F"), lineWidth: hairline)
                )
            }
            .padding(inset)
        }
        .background(
            RoundedRectangle(cornerRadius: c, style: .continuous)
                .fill(Color(steakHex: "3E2723"))
        )
        .clipShape(RoundedRectangle(cornerRadius: c, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: c, style: .continuous)
                .strokeBorder(Color(steakHex: "D32F2F"), lineWidth: hairline)
        )
    }
}

private struct ArchiveEmptyStateView: View {
    @Environment(\.layoutScale) private var scale
    var segment: ArchiveListSegment

    private var subtitle: String {
        switch segment {
        case .failures:
            return "Start cooking and logging steaks!"
        case .successes:
            return "Your best cooks will show up here."
        }
    }

    var body: some View {
        VStack(spacing: fpScale(15, scale)) {
            Image("Layer_x0020_1")
                .resizable()
                .scaledToFit()
                .frame(width: fpScale(258, scale), height: fpScale(258, scale))
                .accessibilityLabel("Empty archive")

            VStack(spacing: fpScale(4, scale)) {
                Text("NO DATA YET")
                    .font(.system(size: fpScale(20, scale), weight: .semibold))
                    .foregroundStyle(Color(steakHex: "FF5722"))
                    .multilineTextAlignment(.center)
                    .textCase(.uppercase)

                Text(subtitle)
                    .font(.system(size: fpScale(16, scale), weight: .regular))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: fpScale(296, scale))
        }
        .padding(.horizontal, fpScale(24, scale))
    }
}

struct ArchiveTabView: View {
    @Environment(\.layoutScale) private var scale
    @EnvironmentObject private var repository: SteakDataRepository
    @State private var listSegment: ArchiveListSegment = .failures

    private static let archiveDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f
    }()

    private var failureEntries: [ArchiveFailureEntry] {
        repository.sessions
            .filter(\.isAnalyzedFailure)
            .sorted { $0.date > $1.date }
            .map(mapFailure)
    }

    private var successEntries: [ArchiveSuccessEntry] {
        repository.sessions
            .filter(\.isSuccess)
            .sorted { $0.date > $1.date }
            .map(mapSuccess)
    }

    var body: some View {
        VStack(spacing: 0) {
            SteakTabScreenHeader(
                title: "Archive",
                subtitle: listSegment == .failures ? "Failure Morgue" : nil
            )
            .environment(\.layoutScale, scale)

            ArchiveSegmentedPicker(selection: $listSegment)
                .padding(.horizontal, fpScale(24, scale))
                .padding(.top, fpScale(24, scale))

            Group {
                switch listSegment {
                case .failures:
                    if failureEntries.isEmpty {
                        Spacer(minLength: 0)
                        ArchiveEmptyStateView(segment: .failures)
                        Spacer(minLength: 0)
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: fpScale(16, scale)) {
                                ForEach(failureEntries) { entry in
                                    ArchiveFailureSwipeRow(
                                        entry: entry,
                                        scale: scale,
                                        onMarkFixed: {
                                            withAnimation(.easeInOut(duration: 0.25)) {
                                                repository.updateResolved(failureId: entry.id, resolved: true)
                                            }
                                        },
                                        onDelete: {
                                            withAnimation(.easeInOut(duration: 0.25)) {
                                                repository.remove(id: entry.id)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, fpScale(24, scale))
                            .padding(.top, fpScale(16, scale))
                            .padding(.bottom, fpScale(24, scale))
                        }
                        .scrollContentBackground(.hidden)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                case .successes:
                    if successEntries.isEmpty {
                        Spacer(minLength: 0)
                        ArchiveEmptyStateView(segment: .successes)
                        Spacer(minLength: 0)
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: fpScale(16, scale)) {
                                ForEach(successEntries) { entry in
                                    ArchiveSuccessSwipeRow(entry: entry, scale: scale) {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            repository.remove(id: entry.id)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, fpScale(24, scale))
                            .padding(.top, fpScale(16, scale))
                            .padding(.bottom, fpScale(24, scale))
                        }
                        .scrollContentBackground(.hidden)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(steakHex: "2D1B11"))
    }

    private func mapFailure(_ s: PersistedSteakSession) -> ArchiveFailureEntry {
        ArchiveFailureEntry(
            id: s.id,
            cutLabel: "\(s.cut) • \(s.weightG) g",
            dateDisplay: Self.archiveDateFormatter.string(from: s.date),
            recap: s.failureRecap ?? "",
            primaryReason: s.failurePrimaryReason ?? "",
            lesson: s.failureLesson ?? "",
            showsHeroImage: s.photoFilename != nil,
            isResolved: s.failureResolved ?? false
        )
    }

    private func mapSuccess(_ s: PersistedSteakSession) -> ArchiveSuccessEntry {
        ArchiveSuccessEntry(
            id: s.id,
            cutName: s.cut,
            dateDisplay: Self.archiveDateFormatter.string(from: s.date),
            weightThicknessLine: "\(s.weightG)g • \(String(format: "%.1f", s.thicknessCM))cm",
            tempText: "\(Int(s.finalTempC))°C",
            donenessLabel: s.donenessLabel,
            donenessFlameHex: DonenessThermometer.swatchHex(forLabel: s.donenessLabel),
            note: s.notes,
            showsHeroImage: s.photoFilename != nil,
            photoFilename: s.photoFilename
        )
    }
}

#Preview {
    ArchiveTabView()
        .environment(\.layoutScale, 1)
        .environmentObject(SteakDataRepository())
        .preferredColorScheme(.dark)
}
