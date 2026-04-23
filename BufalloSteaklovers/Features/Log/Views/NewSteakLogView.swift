//
//  NewSteakLogView.swift
//  BufalloSteaklovers
//

import SwiftUI
import UIKit

struct NewSteakLogView: View {
    @Environment(\.layoutScale) private var scale
    @EnvironmentObject private var repository: SteakDataRepository
    @ObservedObject var viewModel: NewSteakLogViewModel

    var onSubmit: (SteakLogSubmission) -> Void

    @State private var activePhotoPickerSource: UIImagePickerController.SourceType?
    @State private var pickedUIImage: UIImage?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text("New Steak Log")
                    .font(.system(size: fpScale(20, scale), weight: .semibold))
                    .foregroundStyle(Color(steakHex: "FFC107"))
                    .padding(.top, fpScale(20, scale))
                    .padding(.bottom, fpScale(24, scale))

                meatCutSection

                sliderBlock(
                    title: "Thickness (cm)",
                    valueText: String(format: "%.1f cm", viewModel.thicknessCM),
                    scale: scale
                ) {
                    SteakFormSlider(value: $viewModel.thicknessCM, range: viewModel.thicknessRange, scale: scale)
                }
                .padding(.top, fpScale(20, scale))

                fieldBlock(title: "Weight (g)") {
                    SteakFieldChrome(scale: scale) {
                        SteakUIKitFormTextField(
                            text: $viewModel.weightText,
                            placeholder: "Enter weight",
                            keyboardType: .numberPad,
                            returnKeyType: .default,
                            showsDoneAccessory: true,
                            fontSize: fpScale(13, scale)
                        )
                    }
                }
                .padding(.top, fpScale(20, scale))

                sliderBlock(
                    title: "Final Temperature (°C)",
                    valueText: "\(Int(viewModel.finalTempC))°C",
                    scale: scale
                ) {
                    SteakFormSlider(value: $viewModel.finalTempC, range: viewModel.tempRange, scale: scale)
                }
                .padding(.top, fpScale(20, scale))

                logDonenessSummaryCard
                    .padding(.top, fpScale(16, scale))

                fieldBlock(title: "Photo") {
                    Button {
                        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                            activePhotoPickerSource = .photoLibrary
                        }
                    } label: {
                        ZStack {
                            if let data = viewModel.photoJPEGData, let ui = UIImage(data: data) {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipped()
                            } else {
                                VStack(spacing: fpScale(8, scale)) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: fpScale(28, scale), weight: .medium))
                                        .foregroundStyle(Color(steakHex: "A1887F"))
                                    Text("Tap to add photo")
                                        .font(.system(size: fpScale(13, scale), weight: .regular))
                                        .foregroundStyle(Color(steakHex: "A1887F"))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .frame(height: fpScale(128, scale))
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .background(Color(steakHex: "3E2723"))
                        .clipShape(RoundedRectangle(cornerRadius: fpScale(12, scale), style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: fpScale(12, scale), style: .continuous)
                                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
                        )
                    }
                    .buttonStyle(SteakSoundPlainButtonStyle())
                }
                .padding(.top, fpScale(20, scale))

                fieldBlock(title: "Notes") {
                    SteakNotesDoneField(
                        text: $viewModel.notesText,
                        fontSize: fpScale(13, scale),
                        placeholder: "E.g., Hickory smoke is perfect..."
                    )
                    .frame(maxWidth: .infinity, minHeight: fpScale(76, scale), alignment: .topLeading)
                    .background(Color(steakHex: "3E2723"))
                    .clipShape(RoundedRectangle(cornerRadius: fpScale(12, scale), style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: fpScale(12, scale), style: .continuous)
                            .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
                    )
                }
                .padding(.top, fpScale(24, scale))

                SteakEmojiTripleSegment(selection: $viewModel.ratingIndex, options: viewModel.ratingOptions)
                    .padding(.top, fpScale(24, scale))
                    .padding(.bottom, fpScale(20, scale))
            }
            .padding(.horizontal, fpScale(24, scale))
            .padding(.bottom, fpScale(74, scale))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(steakHex: "2D1B11"))
        .fullScreenCover(item: $activePhotoPickerSource, onDismiss: {
            activePhotoPickerSource = nil
            pickedUIImage = nil
        }) { source in
            SteakUIImagePicker(image: $pickedUIImage, sourceType: source)
        }
        .onChange(of: pickedUIImage) { newImage in
            guard let newImage else { return }
            if let data = newImage.jpegData(compressionQuality: 0.88) {
                viewModel.photoJPEGData = data
            }
            pickedUIImage = nil
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 0) {
                SteakPrimarySubmitButton(
                    title: "Log Success",
                    isReady: viewModel.isLogFormComplete
                ) {
                    guard viewModel.isLogFormComplete else { return }
                    if viewModel.ratingIndex == 0 {
                        if let draft = try? viewModel.buildDraftForFailure() {
                            onSubmit(.openFailureArchive(draft))
                        }
                    } else {
                        do {
                            try viewModel.saveSuccessSession(repository: repository)
                            viewModel.resetAfterSubmit()
                            onSubmit(.savedToSuccesses)
                        } catch {
                            // Keep form; persistence failed silently for MVP
                        }
                    }
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

    private var meatCutSection: some View {
        VStack(alignment: .leading, spacing: fpScale(12, scale)) {
            Text("Meat Cut")
                .font(.system(size: fpScale(16, scale), weight: .semibold))
                .foregroundStyle(Color.white)

            if viewModel.meatCutExpanded {
                expandedMeatCutPanel
            } else {
                collapsedMeatCutTrigger
            }
        }
    }

    private var collapsedMeatCutTrigger: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { viewModel.meatCutExpanded = true }
        } label: {
            SteakFieldChrome(scale: scale) {
                HStack {
                    Text(viewModel.selectedCut ?? "Meat Cut")
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

    private var logDonenessSummaryCard: some View {
        let innerR = fpScale(12, scale)
        let padH = fpScale(16, scale)
        let padV = fpScale(10, scale)
        let flameHex = DonenessThermometer.swatchHex(forLabel: viewModel.donenessLabel)

        return VStack(spacing: fpScale(5, scale)) {
            Text("DONENESS")
                .font(.system(size: fpScale(10, scale), weight: .semibold))
                .foregroundStyle(Color(steakHex: "A1887F"))
                .textCase(.uppercase)
                .multilineTextAlignment(.center)

            HStack(spacing: fpScale(6, scale)) {
                Image(systemName: "flame")
                    .font(.system(size: fpScale(14, scale), weight: .medium))
                    .foregroundStyle(Color(steakHex: flameHex))
                Text(viewModel.donenessLabel)
                    .font(.system(size: fpScale(15, scale), weight: .bold))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, padH)
        .padding(.vertical, padV)
        .background(Color(steakHex: "3E2723"))
        .clipShape(RoundedRectangle(cornerRadius: innerR, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: innerR, style: .continuous)
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
        )
    }

    private var expandedMeatCutPanel: some View {
        let corner = fpScale(12, scale)
        let rowSpacing = fpScale(12, scale)

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text("Meat Cut")
                    .font(.system(size: fpScale(13, scale), weight: .regular))
                    .foregroundStyle(Color(steakHex: "A1887F"))
                Spacer(minLength: 0)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { viewModel.meatCutExpanded = false }
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
                    ForEach(SteakCatalog.meatCuts, id: \.self) { cut in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedCut = cut
                                viewModel.meatCutExpanded = false
                            }
                        } label: {
                            Text(cut)
                                .font(.system(size: fpScale(13, scale), weight: .medium))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(minHeight: fpScale(16, scale), alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(SteakSoundPlainButtonStyle())
                    }
                }
                .padding(.horizontal, fpScale(12, scale))
                .padding(.bottom, fpScale(14, scale))
            }
        }
        .frame(height: fpScale(328, scale))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Color(steakHex: "3E2723"))
                .shadow(color: Color.black.opacity(0.25), radius: fpScale(4, scale), x: 0, y: fpScale(4, scale))
        )
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
        )
    }

    private func fieldBlock(title: String?, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: fpScale(6, scale)) {
            if let title {
                Text(title)
                    .font(.system(size: fpScale(16, scale), weight: .semibold))
                    .foregroundStyle(Color.white)
            }
            content()
        }
    }

    private func sliderBlock(
        title: String,
        valueText: String,
        scale: CGFloat,
        @ViewBuilder control: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: fpScale(8, scale)) {
            HStack {
                Text(title)
                    .font(.system(size: fpScale(16, scale), weight: .semibold))
                    .foregroundStyle(Color.white)
                Spacer(minLength: 0)
                Text(valueText)
                    .font(.system(size: fpScale(16, scale), weight: .semibold))
                    .foregroundStyle(Color(steakHex: "FF5722"))
            }
            control()
        }
    }
}
