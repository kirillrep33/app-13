//
//  DesignScale.swift
//  BufalloSteaklovers
//

import CoreGraphics

enum DesignScale {
    static func from(containerWidth: CGFloat, designWidth: CGFloat) -> CGFloat {
        guard containerWidth.isFinite, containerWidth > 0,
              designWidth.isFinite, designWidth > 0 else { return 1 }
        return max(containerWidth / designWidth, 0.01)
    }
}
