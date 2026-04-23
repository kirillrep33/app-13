//
//  SteakPrimarySubmitButton.swift
//  BufalloSteaklovers
//

import SwiftUI

struct SteakPrimarySubmitButton: View {
    @Environment(\.layoutScale) private var scale

    let title: String
    var isReady: Bool
    var action: () -> Void

    var body: some View {
        Button {
            guard isReady else { return }
            action()
        } label: {
            HStack(spacing: fpScale(8, scale)) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: fpScale(18, scale), weight: .medium))
                    .foregroundStyle(isReady ? Color.white : Color(steakHex: "3E2723"))
                Text(title)
                    .font(.system(size: fpScale(16, scale), weight: .semibold))
                    .foregroundStyle(isReady ? Color.white : Color(steakHex: "3E2723"))
                    .tracking(-0.08)
            }
            .frame(maxWidth: .infinity)
            .frame(height: fpScale(44, scale))
            .background(isReady ? Color(steakHex: "FF5722") : Color(steakHex: "A1887F"))
            .clipShape(Capsule())
        }
        .buttonStyle(SteakSoundPlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isReady)
    }
}
