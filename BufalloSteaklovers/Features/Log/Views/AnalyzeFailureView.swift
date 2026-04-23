//
//  AnalyzeFailureView.swift
//  BufalloSteaklovers
//

import SwiftUI

private struct SteakFieldChrome44: View {
    let scale: CGFloat
    let content: () -> AnyView

    init(scale: CGFloat, @ViewBuilder content: @escaping () -> some View) {
        self.scale = scale
        self.content = { AnyView(content()) }
    }

    var body: some View {
        content()
            .padding(.horizontal, fpScale(12, scale))
            .frame(height: fpScale(44, scale))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(steakHex: "3E2723"))
            .clipShape(RoundedRectangle(cornerRadius: fpScale(12, scale), style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: fpScale(12, scale), style: .continuous)
                    .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
            )
    }
}

struct AnalyzeFailureView: View {
    @Environment(\.layoutScale) private var scale
    @EnvironmentObject private var repository: SteakDataRepository

    let draft: PendingSteakLogDraft
    var onBack: () -> Void = {}
    var onSavedToArchive: () -> Void = {}

    @State private var whatWrong = ""
    @State private var primaryExpanded = false
    @State private var selectedPrimary: String?
    @State private var lessonText = ""

    private var isFailureFormComplete: Bool {
        let desc = whatWrong.trimmingCharacters(in: .whitespacesAndNewlines)
        let lesson = lessonText.trimmingCharacters(in: .whitespacesAndNewlines)
        return !desc.isEmpty && selectedPrimary != nil && !lesson.isEmpty
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: fpScale(12, scale)) {
                    Button {
                        onBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: fpScale(16, scale), weight: .semibold))
                            .foregroundStyle(Color(steakHex: "FF5722"))
                    }
                    .buttonStyle(SteakSoundPlainButtonStyle())

                    Text("Analyze Failure")
                        .font(.system(size: fpScale(20, scale), weight: .semibold))
                        .foregroundStyle(Color(steakHex: "D32F2F"))
                }
                .padding(.top, fpScale(20, scale))
                .padding(.bottom, fpScale(24, scale))

                field(title: "What went wrong?") {
                    SteakFieldChrome44(scale: scale) {
                        SteakUIKitFormTextField(
                            text: $whatWrong,
                            placeholder: "e.g. Overcooked ribeye — wanted medium, got well",
                            keyboardType: .default,
                            returnKeyType: .done,
                            showsDoneAccessory: false,
                            fontSize: fpScale(13, scale)
                        )
                    }
                }

                primaryReasonSection
                    .padding(.top, fpScale(20, scale))

                field(title: "Lesson Learned") {
                    SteakNotesDoneField(
                        text: $lessonText,
                        fontSize: fpScale(13, scale),
                        placeholder: "e.g. Thermometer is mandatory for steaks >3 cm"
                    )
                    .frame(maxWidth: .infinity, minHeight: fpScale(76, scale), alignment: .topLeading)
                    .background(Color(steakHex: "3E2723"))
                    .clipShape(RoundedRectangle(cornerRadius: fpScale(12, scale), style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: fpScale(12, scale), style: .continuous)
                            .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
                    )
                }
                .padding(.top, fpScale(20, scale))
                .padding(.bottom, fpScale(20, scale))
            }
            .padding(.horizontal, fpScale(24, scale))
            .padding(.bottom, fpScale(74, scale))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(steakHex: "2D1B11"))
        .overlay(alignment: .bottom) {
            VStack(spacing: 0) {
                SteakPrimarySubmitButton(
                    title: "Save to Archive",
                    isReady: isFailureFormComplete
                ) {
                    guard let reason = selectedPrimary else { return }
                    let session = PersistedSteakSession(
                        id: UUID(),
                        date: Date(),
                        cut: draft.cut,
                        weightG: draft.weightG,
                        thicknessCM: draft.thicknessCM,
                        finalTempC: draft.finalTempC,
                        donenessLabel: draft.donenessLabel,
                        rating: 0,
                        notes: draft.notes,
                        photoFilename: draft.photoFilename,
                        restMinutes: nil,
                        failureRecap: whatWrong.trimmingCharacters(in: .whitespacesAndNewlines),
                        failurePrimaryReason: reason,
                        failureLesson: lessonText.trimmingCharacters(in: .whitespacesAndNewlines),
                        failureResolved: false
                    )
                    repository.add(session)
                    onSavedToArchive()
                    onBack()
                }
                .padding(.horizontal, fpScale(24, scale))
                .padding(.top, fpScale(10, scale))
                .padding(.bottom, fpScale(8, scale))
            }
            .frame(maxWidth: .infinity)
            .background(Color(steakHex: "2D1B11"))
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var primaryReasonSection: some View {
        VStack(alignment: .leading, spacing: fpScale(6, scale)) {
            Text("Primary Reason")
                .font(.system(size: fpScale(16, scale), weight: .semibold))
                .foregroundStyle(Color.white)

            if primaryExpanded {
                expandedPrimaryPanel
            } else {
                collapsedPrimaryTrigger
            }
        }
    }

    private var collapsedPrimaryTrigger: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { primaryExpanded = true }
        } label: {
            SteakFieldChrome44(scale: scale) {
                HStack {
                    Text(selectedPrimary ?? "Choose")
                        .font(.system(size: fpScale(13, scale), weight: .regular))
                        .foregroundStyle(Color(steakHex: "A1887F"))
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.down")
                        .font(.system(size: fpScale(12, scale), weight: .semibold))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .buttonStyle(SteakSoundPlainButtonStyle())
    }

    private var expandedPrimaryPanel: some View {
        let corner = fpScale(12, scale)
        let rowSpacing = fpScale(12, scale)

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text("Choose a reason")
                    .font(.system(size: fpScale(13, scale), weight: .regular))
                    .foregroundStyle(Color(steakHex: "A1887F"))
                Spacer(minLength: 0)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { primaryExpanded = false }
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: fpScale(12, scale), weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                .buttonStyle(SteakSoundPlainButtonStyle())
            }
            .padding(.horizontal, fpScale(12, scale))
            .padding(.top, fpScale(14, scale))
            .padding(.bottom, fpScale(10, scale))

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: rowSpacing) {
                    ForEach(FailureMorgue.primaryReasonChoices, id: \.self) { reason in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPrimary = reason
                                primaryExpanded = false
                            }
                        } label: {
                            Text(reason)
                                .font(.system(size: fpScale(13, scale), weight: .medium))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(SteakSoundPlainButtonStyle())
                    }
                }
                .padding(.horizontal, fpScale(12, scale))
                .padding(.bottom, fpScale(14, scale))
            }
        }
        .frame(height: fpScale(188, scale))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(steakHex: "3E2723"))
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
        )
        .shadow(color: Color.black.opacity(0.25), radius: fpScale(4, scale), x: 0, y: fpScale(4, scale))
    }

    private func field(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: fpScale(6, scale)) {
            Text(title)
                .font(.system(size: fpScale(16, scale), weight: .semibold))
                .foregroundStyle(Color.white)
            content()
        }
    }
}
