//
//  SteakButtonSoundStyle.swift
//  BufalloSteaklovers
//

import SwiftUI
import UIKit
import AudioToolbox
import ObjectiveC.runtime

enum SteakButtonSound {
    static func play() {
        // iOS system "tap" feedback.
        AudioServicesPlaySystemSound(1104)
    }
}

struct SteakSoundPlainButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .onTapGesture {
                SteakButtonSound.play()
                configuration.trigger()
            }
    }
}

enum SteakGlobalButtonSound {
    static func installOnce() {
        _ = swizzleSendAction
    }

    private static let swizzleSendAction: Void = {
        let original = #selector(UIControl.sendAction(_:to:for:))
        let replacement = #selector(UIControl.steak_sendAction(_:to:for:))
        guard
            let originalMethod = class_getInstanceMethod(UIControl.self, original),
            let replacementMethod = class_getInstanceMethod(UIControl.self, replacement)
        else { return }
        method_exchangeImplementations(originalMethod, replacementMethod)
    }()
}

private extension UIControl {
    @objc func steak_sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        let cls = String(describing: type(of: self))
        if self is UIButton || cls.contains("Button") {
            SteakButtonSound.play()
        }
        steak_sendAction(action, to: target, for: event)
    }
}
