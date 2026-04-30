//
//  Font+Extensions.swift
//  NativeAppTemplate
//

import SwiftUI

extension Font {
    static var uiLargeTitle: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 36.0)).weight(.bold)
    }

    static var uiTitle1: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 30.0)).weight(.medium)
    }

    static var uiTitle2: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 24.0)).weight(.bold)
    }

    static var uiTitle3: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 20.0)).weight(.bold)
    }

    static var uiTitle4: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 18.0)).weight(.medium)
    }

    static var uiTitle5: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 18.0)).weight(.medium)
    }

    static var uiHeadline: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 18.0)).weight(.semibold)
    }

    static var uiBodyAppleDefault: Font {
        .body
    }

    /// Can't have bold Font's
    static var uiButtonLabelLarge: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 18.0)).bold()
    }

    static var uiButtonLabelMedium: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 16)).weight(.bold)
    }

    static var uiButtonLabelSmall: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 14.0)).weight(.semibold)
    }

    static var uiBodyCustom: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 16.0))
    }

    static var uiLabelBold: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 18.0)).weight(.semibold)
    }

    static var uiLabel: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 18.0))
    }

    static var uiFootnote: Font {
        .footnote
    }

    static var uiCaption: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 14.0))
    }

    static var uiUppercaseTag: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 10.0)).weight(.semibold)
    }
}
