//
//  SteakNotesDoneField.swift
//  BufalloSteaklovers
//

import SwiftUI
import UIKit

/// Multiline notes where **Return** dismisses the keyboard (no new line).
struct SteakNotesDoneField: UIViewRepresentable {
    @Binding var text: String
    /// Already scaled point size (e.g. `fpScale(13, scale)`).
    var fontSize: CGFloat
    var placeholder: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private var safeFontSize: CGFloat {
        let s = fontSize
        guard s.isFinite, !s.isNaN, s > 0 else { return 13 }
        return min(max(s, 10), 34)
    }

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        tv.backgroundColor = .clear
        tv.returnKeyType = .done
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        tv.textContainer.lineFragmentPadding = 4
        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        tv.font = UIFont.systemFont(ofSize: safeFontSize, weight: .regular)
        if text.isEmpty {
            context.coordinator.applyPlaceholder(tv)
        } else {
            tv.text = text
            tv.textColor = .white
        }
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.parent = self
        uiView.font = UIFont.systemFont(ofSize: safeFontSize, weight: .regular)
        if uiView.isFirstResponder { return }
        let display = text.isEmpty ? placeholder : text
        if uiView.text != display, (text.isEmpty || uiView.text != text) {
            if text.isEmpty {
                context.coordinator.applyPlaceholder(uiView)
            } else {
                uiView.text = text
                uiView.textColor = .white
            }
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: SteakNotesDoneField

        init(_ parent: SteakNotesDoneField) {
            self.parent = parent
        }

        func applyPlaceholder(_ tv: UITextView) {
            if parent.text.isEmpty {
                tv.text = parent.placeholder
                tv.textColor = UIColor(red: 161 / 255, green: 136 / 255, blue: 127 / 255, alpha: 1)
            } else if tv.textColor != UIColor.white {
                tv.textColor = UIColor.white
            }
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder, textView.textColor != UIColor.white {
                textView.text = ""
                textView.textColor = UIColor.white
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            let raw = textView.text ?? ""
            if raw == parent.placeholder || raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                parent.text = ""
                applyPlaceholder(textView)
            } else {
                parent.text = raw
            }
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool {
            if string == "\n" {
                textView.resignFirstResponder()
                return false
            }
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            if textView.textColor == UIColor.white {
                parent.text = textView.text ?? ""
            }
        }
    }
}
