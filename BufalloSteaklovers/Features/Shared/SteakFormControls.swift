//
//  SteakFormControls.swift
//  BufalloSteaklovers
//

import SwiftUI

struct SteakFormSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let scale: CGFloat

    private var fraction: CGFloat {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        let t = (value - range.lowerBound) / span
        if t.isNaN || t.isInfinite { return 0 }
        return CGFloat(max(0, min(1, t)))
    }

    var body: some View {
        GeometryReader { geo in
            let wRaw = geo.size.width
            let w = (wRaw.isFinite && wRaw > 0) ? wRaw : 1
            let trackH = max(1, fpScale(8, scale))
            let thumb = max(1, fpScale(16, scale))
            let fillW = max(0, min(w, w * fraction))
            let thumbX = max(0, min(w - thumb, fillW - thumb / 2))
            let safeThumbX = thumbX.isFinite ? thumbX : 0

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(steakHex: "A1887F"))
                    .frame(height: trackH)
                Capsule()
                    .fill(Color(steakHex: "FF5722"))
                    .frame(width: fillW, height: trackH)
                Circle()
                    .strokeBorder(Color.white, lineWidth: max(0.5, fpScale(1, scale)))
                    .background(Circle().fill(Color(steakHex: "FF5722")))
                    .frame(width: thumb, height: thumb)
                    .offset(x: safeThumbX)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        guard w > 0, g.location.x.isFinite else { return }
                        let x = max(0, min(w, g.location.x))
                        let t = Double(x / w)
                        guard t.isFinite, !t.isNaN else { return }
                        let next = range.lowerBound + t * (range.upperBound - range.lowerBound)
                        guard next.isFinite, !next.isNaN else { return }
                        value = next
                    }
            )
        }
        .frame(height: fpScale(16, scale))
    }
}

struct SteakFieldChrome: View {
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
