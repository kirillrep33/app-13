//
//  SteakUIKitFormTextField.swift
//  BufalloSteaklovers
//

import SwiftUI
import UIKit

/// Single-line field with a UIKit **Done** accessory (avoids SwiftUI keyboard `ToolbarItem` layout bugs).
struct SteakUIKitFormTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType
    var returnKeyType: UIReturnKeyType
    var showsDoneAccessory: Bool
    /// Already layout-scaled point size (e.g. `fpScale(13, scale)`).
    var fontSize: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.delegate = context.coordinator
        tf.keyboardType = keyboardType
        tf.returnKeyType = returnKeyType
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.textColor = .white
        tf.backgroundColor = .clear
        tf.tintColor = .white

        let fs = Self.safeFont(fontSize)
        tf.font = .systemFont(ofSize: fs, weight: .regular)
        tf.attributedPlaceholder = Self.placeholderAttr(placeholder, fontSize: fs)

        tf.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged)
        tf.text = text
        if showsDoneAccessory {
            tf.inputAccessoryView = SteakKeyboard.makeDoneInputAccessory(
                target: context.coordinator,
                action: #selector(Coordinator.doneTapped)
            )
        } else {
            tf.inputAccessoryView = nil
        }
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.parent = self
        let fs = Self.safeFont(fontSize)
        uiView.font = .systemFont(ofSize: fs, weight: .regular)
        uiView.keyboardType = keyboardType
        uiView.returnKeyType = returnKeyType
        uiView.attributedPlaceholder = Self.placeholderAttr(placeholder, fontSize: fs)
        uiView.inputAccessoryView = showsDoneAccessory
            ? SteakKeyboard.makeDoneInputAccessory(target: context.coordinator, action: #selector(Coordinator.doneTapped))
            : nil
        if uiView.text != text, !uiView.isFirstResponder {
            uiView.text = text
        }
    }

    private static func safeFont(_ s: CGFloat) -> CGFloat {
        guard s.isFinite, !s.isNaN, s > 0 else { return 13 }
        return min(max(s, 10), 34)
    }

    private static func placeholderAttr(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        NSAttributedString(
            string: string,
            attributes: [
                .foregroundColor: UIColor(red: 161 / 255, green: 136 / 255, blue: 127 / 255, alpha: 1),
                .font: UIFont.systemFont(ofSize: fontSize, weight: .regular)
            ]
        )
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SteakUIKitFormTextField

        init(_ parent: SteakUIKitFormTextField) {
            self.parent = parent
        }

        @objc func doneTapped() {
            SteakKeyboard.dismiss()
        }

        @objc func editingChanged(_ tf: UITextField) {
            parent.text = tf.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            SteakKeyboard.dismiss()
            return true
        }
    }
}
