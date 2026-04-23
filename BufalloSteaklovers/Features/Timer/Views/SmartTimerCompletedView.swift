//
//  SmartTimerCompletedView.swift
//  BufalloSteaklovers
//

import SwiftUI

struct SmartTimerCompletedView: View {
    @Environment(\.layoutScale) private var scale

    var restMinutes: Int
    var onRetry: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: fpScale(24, scale))

            completionRing

            VStack(spacing: fpScale(4, scale)) {
                Text("THE STEAK IS READY")
                    .font(.system(size: fpScale(24, scale), weight: .semibold))
                    .foregroundStyle(Color(steakHex: "FF5722"))
                    .multilineTextAlignment(.center)

                Text("Rest for \(restMinutes) minutes — don't rush.")
                    .font(.system(size: fpScale(16, scale), weight: .medium))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, fpScale(24, scale))
            .frame(maxWidth: fpScale(296, scale))
            .padding(.top, fpScale(28, scale))

            Spacer(minLength: fpScale(24, scale))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var completionRing: some View {
        let ring = fpScale(220, scale)
        let line = fpScale(4, scale)
        let icon = fpScale(142, scale)

        return ZStack {
            Circle()
                .fill(Color.clear)
                .frame(width: ring, height: ring)
                .overlay(
                    Circle()
                        .strokeBorder(Color(steakHex: "FF5722"), lineWidth: line)
                )

            Image("Capa_1-3")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: icon, height: icon)
                .accessibilityLabel("Completed")
        }
    }
}

#Preview {
    SmartTimerCompletedView(restMinutes: 8, onRetry: {})
        .environment(\.layoutScale, 1)
        .background(Color(steakHex: "2D1B11"))
}
