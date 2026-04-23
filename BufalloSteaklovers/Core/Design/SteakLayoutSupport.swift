//
//  SteakLayoutSupport.swift
//  BufalloSteaklovers
//

import SwiftUI
import UIKit

/// `GeometryReader.safeAreaInsets.bottom` grows with the software keyboard; the key window’s inset does not.
/// Use this for a fixed bottom tab bar and stable `tabReserve` while the keyboard is open.
struct SteakKeyWindowBottomSafeInsetReader: UIViewRepresentable {
    @Binding var bottomInset: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(bottomInset: $bottomInset)
    }

    func makeUIView(context: Context) -> ReaderView {
        let v = ReaderView()
        v.coordinator = context.coordinator
        return v
    }

    func updateUIView(_ uiView: ReaderView, context: Context) {
        uiView.coordinator = context.coordinator
    }

    final class Coordinator {
        var bottomInset: Binding<CGFloat>

        init(bottomInset: Binding<CGFloat>) {
            self.bottomInset = bottomInset
        }

        func publishWindowBottom(from window: UIWindow) {
            let value = window.safeAreaInsets.bottom
            DispatchQueue.main.async { [bottomInset] in
                if bottomInset.wrappedValue != value {
                    bottomInset.wrappedValue = value
                }
            }
        }
    }

    final class ReaderView: UIView {
        weak var coordinator: Coordinator?

        override func layoutSubviews() {
            super.layoutSubviews()
            if let w = window {
                coordinator?.publishWindowBottom(from: w)
            }
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            if let w = window {
                coordinator?.publishWindowBottom(from: w)
            }
        }

        override func safeAreaInsetsDidChange() {
            super.safeAreaInsetsDidChange()
            if let w = window {
                coordinator?.publishWindowBottom(from: w)
            }
        }
    }
}

enum SteakDesign {
    static let width: CGFloat = 390
}

private enum LayoutScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1
}

extension EnvironmentValues {
    var layoutScale: CGFloat {
        get { self[LayoutScaleKey.self] }
        set { self[LayoutScaleKey.self] = newValue }
    }
}

@inline(__always)
func fpScale(_ v: CGFloat, _ scale: CGFloat) -> CGFloat { v * scale }

/// Shared top bar for tabs (matches Log header height and bull size).
struct SteakTabScreenHeader: View {
    var title: String
    var subtitle: String?
    @Environment(\.layoutScale) private var scale

    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(alignment: .center, spacing: fpScale(12, scale)) {
            VStack(alignment: .leading, spacing: fpScale(2, scale)) {
                Text(title)
                    .font(.system(size: fpScale(24, scale), weight: .semibold))
                    .foregroundStyle(Color(steakHex: "FF5722"))
                    .minimumScaleFactor(0.65)
                    .lineLimit(1)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: fpScale(11, scale), weight: .medium))
                        .foregroundStyle(Color(steakHex: "A1887F"))
                }
            }
            Spacer(minLength: 0)
            Image("Frame")
                .resizable()
                .scaledToFit()
                .frame(width: fpScale(44, scale), height: fpScale(44, scale))
                .accessibilityLabel("Buffalo")
        }
        .padding(.horizontal, fpScale(24, scale))
        .padding(.top, fpScale(8, scale))
        .padding(.bottom, fpScale(16, scale))
        .frame(maxWidth: .infinity)
        .background(Color(steakHex: "3E2723"))
    }
}

/// Vertical space to reserve above the keyboard so scroll content isn’t hidden under the floating tab bar.
func steakTabBarReserveHeight(scale: CGFloat, bottomSafeInset: CGFloat, isPhoneSEClass: Bool) -> CGFloat {
    let outerPadTop = fpScale(20, scale)
    let barH = fpScale(54, scale)
    let bottomExtra = isPhoneSEClass ? fpScale(22, scale) : max(fpScale(2, scale), 2)
    return outerPadTop + barH + bottomExtra + bottomSafeInset
}

extension Color {
    init(steakHex hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}
