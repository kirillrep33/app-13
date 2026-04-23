//
//  SteakEmojiTripleSegment.swift
//  BufalloSteaklovers
//

import SwiftUI

struct SteakEmojiTripleSegment: View {
    @Environment(\.layoutScale) private var scale
    @Binding var selection: Int
    let options: [(emoji: String, title: String)]

    var body: some View {
        let pad = fpScale(2, scale)
        let outerR = fpScale(8, scale)
        let innerR = fpScale(7, scale)

        HStack(spacing: pad) {
            ForEach(options.indices, id: \.self) { i in
                let on = selection == i
                let opt = options[i]
                Button {
                    selection = i
                } label: {
                    Text("\(opt.emoji) \(opt.title)")
                        .font(.system(size: fpScale(10, scale), weight: .semibold))
                        .tracking(-0.08)
                        .foregroundStyle(on ? Color.white : Color(steakHex: "A1887F"))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.65)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity)
                        .frame(height: fpScale(28, scale))
                        .background(
                            Group {
                                if on {
                                    RoundedRectangle(cornerRadius: innerR, style: .continuous)
                                        .fill(Color(steakHex: "FF5722"))
                                        .shadow(color: .black.opacity(0.12), radius: fpScale(4, scale), x: 0, y: fpScale(2, scale))
                                }
                            }
                        )
                }
                .buttonStyle(SteakSoundPlainButtonStyle())
            }
        }
        .padding(pad)
        .frame(height: fpScale(32, scale))
        .background(Color(steakHex: "3E2723"))
        .clipShape(RoundedRectangle(cornerRadius: outerR, style: .continuous))
    }
}
