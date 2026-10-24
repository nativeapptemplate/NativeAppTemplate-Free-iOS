//
//  Contrast.swift
//  NativeAppTemplate
//

import SwiftUI
import UIKit

/// WCAG 2.x contrast of two colors as they resolve in one appearance
enum Contrast {
    static func ratio(_ first: Color, _ second: Color, style: UIUserInterfaceStyle) -> Double {
        let lighter = max(luminance(first, style: style), luminance(second, style: style))
        let darker = min(luminance(first, style: style), luminance(second, style: style))
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// WCAG 2.x relative luminance.
    static func luminance(_ color: Color, style: UIUserInterfaceStyle) -> Double {
        let resolved = UIColor(color).resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        func linear(_ channel: CGFloat) -> Double {
            let value = Double(channel)
            return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
    }
}
