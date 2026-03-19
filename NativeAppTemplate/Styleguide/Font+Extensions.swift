//
//  Font+Extensions.swift
//  NativeAppTemplate
//

import SwiftUI

extension Font {
    static var uiLargeTitle: Font {
        .custom("Inter-Bold", size: 36.0, relativeTo: .largeTitle)
    }

    static var uiTitle1: Font {
        .custom("Inter-Medium", size: 30.0, relativeTo: .title)
    }

    static var uiTitle2: Font {
        .custom("Inter-Bold", size: 24.0, relativeTo: .title2)
    }

    static var uiTitle3: Font {
        .custom("Inter-Bold", size: 20.0, relativeTo: .title3)
    }

    static var uiTitle4: Font {
        .custom("Inter-Medium", size: 18.0, relativeTo: .title3)
    }

    static var uiTitle5: Font {
        .custom("Inter-Medium", size: 18.0, relativeTo: .body)
    }

    static var uiHeadline: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 18.0)).weight(.semibold)
    }

    static var uiNumberBox: Font {
        .custom("Inter-Bold", size: 12.0, relativeTo: .footnote)
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

    static var uiUppercase: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 12.0)).weight(.semibold)
    }

    static var uiUppercaseTag: Font {
        .system(size: UIFontMetrics.default.scaledValue(for: 10.0)).weight(.semibold)
    }
}
