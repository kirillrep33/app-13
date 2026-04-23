//
//  SteakKeyboardSupport.swift
//  BufalloSteaklovers
//

import UIKit

enum SteakKeyboard {
    static func dismiss() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    /// Full width for `inputAccessoryView` (keyboard bar must not start at 0 pt — avoids `_UIToolbarContentView.width == 0` conflicts).
    static func inputAccessoryContainerWidth() -> CGFloat {
        for scene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            if let w = scene.windows.first(where: \.isKeyWindow)?.bounds.width, w.isFinite, w > 1 {
                return w
            }
            let sw = scene.screen.bounds.width
            if sw.isFinite, sw > 1 { return sw }
        }
        let fb = UIScreen.main.bounds.width
        return (fb.isFinite && fb > 1) ? fb : 390
    }

    /// Plain `UIView` bar with **Done** — no `UIToolbar` (its internal `_UIToolbarContentView` often hits width‑0 constraint warnings).
    static func makeDoneInputAccessory(target: Any?, action: Selector) -> UIView {
        let w = inputAccessoryContainerWidth()
        let h: CGFloat = 44
        let bar = UIView(frame: CGRect(x: 0, y: 0, width: w, height: h))
        bar.backgroundColor = UIColor(red: 40 / 255, green: 40 / 255, blue: 42 / 255, alpha: 1)

        let btn = UIButton(type: .system)
        btn.setTitle("Done", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        let btnWidth: CGFloat = 72
        btn.frame = CGRect(x: w - 16 - btnWidth, y: 0, width: btnWidth, height: h)
        btn.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
        btn.addTarget(target, action: action, for: .touchUpInside)
        bar.addSubview(btn)

        return bar
    }
}

