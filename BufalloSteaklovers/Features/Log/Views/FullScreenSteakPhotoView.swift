//
//  FullScreenSteakPhotoView.swift
//  BufalloSteaklovers
//

import SwiftUI
import UIKit

/// Full-screen flow: camera or library, then optional preview before confirming.
struct FullScreenSteakPhotoView: View {
    @Environment(\.layoutScale) private var scale
    @Environment(\.dismiss) private var dismiss

    @Binding var imageData: Data?

    @State private var stagingImage: UIImage?
    @State private var activePickerSource: UIImagePickerController.SourceType?
    @State private var pickerImage: UIImage?

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color(steakHex: "2D1B11")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("Close")
                                .font(.system(size: fpScale(16, scale), weight: .semibold))
                                .foregroundStyle(Color(steakHex: "FF5722"))
                        }
                        .buttonStyle(SteakSoundPlainButtonStyle())
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, fpScale(24, scale))
                    .padding(.top, fpScale(8, scale) + geo.safeAreaInsets.top)
                    .padding(.bottom, fpScale(8, scale))

                    Group {
                        if let ui = stagingImage ?? (imageData.flatMap { UIImage(data: $0) }) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.horizontal, fpScale(12, scale))
                        } else {
                            VStack(spacing: fpScale(12, scale)) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: fpScale(48, scale), weight: .medium))
                                    .foregroundStyle(Color(steakHex: "A1887F"))
                                Text("Take a photo or choose from library")
                                    .font(.system(size: fpScale(15, scale), weight: .medium))
                                    .foregroundStyle(Color(steakHex: "D7CCC8"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, fpScale(32, scale))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack(spacing: fpScale(12, scale)) {
                        if stagingImage != nil {
                            Button {
                                if let ui = stagingImage, let d = ui.jpegData(compressionQuality: 0.88) {
                                    imageData = d
                                }
                                dismiss()
                            } label: {
                                Text("Use Photo")
                                    .font(.system(size: fpScale(16, scale), weight: .semibold))
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: fpScale(48, scale))
                                    .background(Color(steakHex: "FF5722"))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(SteakSoundPlainButtonStyle())
                        }

                        HStack(spacing: fpScale(12, scale)) {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                pickButton(title: "Camera", systemImage: "camera.fill") {
                                    activePickerSource = .camera
                                }
                            }
                            pickButton(title: "Library", systemImage: "photo.on.rectangle") {
                                activePickerSource = .photoLibrary
                            }
                        }
                    }
                    .padding(.horizontal, fpScale(24, scale))
                    .padding(.bottom, fpScale(24, scale) + geo.safeAreaInsets.bottom)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            }
        }
        .ignoresSafeArea()
        .fullScreenCover(item: $activePickerSource) { source in
            SteakUIImagePicker(image: $pickerImage, sourceType: source)
        }
        .onChange(of: pickerImage) { ui in
            guard let ui else { return }
            stagingImage = ui
            pickerImage = nil
            activePickerSource = nil
        }
    }

    private func pickButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: fpScale(8, scale)) {
                Image(systemName: systemImage)
                    .font(.system(size: fpScale(16, scale), weight: .semibold))
                Text(title)
                    .font(.system(size: fpScale(15, scale), weight: .semibold))
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: fpScale(48, scale))
            .background(Color(steakHex: "3E2723"))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(0.5, fpScale(0.5, scale)))
            )
        }
        .buttonStyle(SteakSoundPlainButtonStyle())
    }
}

