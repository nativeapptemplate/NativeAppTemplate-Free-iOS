//
//  Color+Extensions.swift
//  NativeAppTemplate
//

import SwiftUI

// MARK: - Palette 9: Friendly

extension Color {
    // MARK: - Primary Colors (Light Blue Vivid)

    static let lightBlue1 = Color(hex: "#035388") // Darkest
    static let lightBlue2 = Color(hex: "#0B69A3")
    static let lightBlue3 = Color(hex: "#127FBF")
    static let lightBlue4 = Color(hex: "#1992D4")
    static let lightBlue5 = Color(hex: "#2BB0ED")
    static let lightBlue6 = Color(hex: "#40C3F7")
    static let lightBlue7 = Color(hex: "#5ED0FA")
    static let lightBlue8 = Color(hex: "#81DEFD")
    static let lightBlue9 = Color(hex: "#B3ECFF")
    static let lightBlue10 = Color(hex: "#E3F8FF") // Lightest

    // MARK: - Primary Colors (Pink Vivid)

    static let pink1 = Color(hex: "#620042") // Darkest
    static let pink2 = Color(hex: "#870557")
    static let pink3 = Color(hex: "#A30664")
    static let pink4 = Color(hex: "#BC0A6F")
    static let pink5 = Color(hex: "#DA127D")
    static let pink6 = Color(hex: "#E8368F")
    static let pink7 = Color(hex: "#F364A2")
    static let pink8 = Color(hex: "#F899BD")
    static let pink9 = Color(hex: "#FFB8D2")
    static let pink10 = Color(hex: "#FFE3EC") // Lightest

    // MARK: - Neutrals (Cool Grey)

    static let coolGrey1 = Color(hex: "#1F2933") // Darkest
    static let coolGrey2 = Color(hex: "#323F4B")
    static let coolGrey3 = Color(hex: "#3E4C59")
    static let coolGrey4 = Color(hex: "#52606D")
    static let coolGrey5 = Color(hex: "#616E7C")
    static let coolGrey6 = Color(hex: "#7B8794")
    static let coolGrey7 = Color(hex: "#9AA5B1")
    static let coolGrey8 = Color(hex: "#CBD2D9")
    static let coolGrey9 = Color(hex: "#E4E7EB")
    static let coolGrey10 = Color(hex: "#F5F7FA") // Lightest

    // MARK: - Supporting: Red (Vivid)

    static let red1 = Color(hex: "#610316")
    static let red2 = Color(hex: "#8A041A")
    static let red3 = Color(hex: "#AB091E")
    static let red4 = Color(hex: "#CF1124")
    static let red5 = Color(hex: "#E12D39")
    static let red6 = Color(hex: "#EF4E4E")
    static let red7 = Color(hex: "#F86A6A")
    static let red8 = Color(hex: "#FF9B9B")
    static let red9 = Color(hex: "#FFBDBD")
    static let red10 = Color(hex: "#FFE3E3")

    // MARK: - Supporting: Yellow (Vivid)

    static let yellow1 = Color(hex: "#8D2B0B")
    static let yellow2 = Color(hex: "#B44D12")
    static let yellow3 = Color(hex: "#CB6E17")
    static let yellow4 = Color(hex: "#DE911D")
    static let yellow5 = Color(hex: "#F0B429")
    static let yellow6 = Color(hex: "#F7C948")
    static let yellow7 = Color(hex: "#FADB5F")
    static let yellow8 = Color(hex: "#FCE588")
    static let yellow9 = Color(hex: "#FFF3C4")
    static let yellow10 = Color(hex: "#FFFBEA")

    // MARK: - Supporting: Green (Vivid)

    static let green1 = Color(hex: "#014807")
    static let green2 = Color(hex: "#07600E")
    static let green3 = Color(hex: "#0E7817")
    static let green4 = Color(hex: "#0F8613")
    static let green5 = Color(hex: "#18981D")
    static let green6 = Color(hex: "#31B237")
    static let green7 = Color(hex: "#51CA58")
    static let green8 = Color(hex: "#91E697")
    static let green9 = Color(hex: "#C1F2C7")
    static let green10 = Color(hex: "#E3F9E5")
}

// MARK: - Semantic Colors (Dark Mode)

extension Color {
    // MARK: Backgrounds

    static let backgroundColor = coolGrey1 // #1F2933 - Page background
    static let cardBackground = coolGrey2 // #323F4B - Card background
    static let coloredPrimaryBackground = lightBlue10 // #E3F8FF
    static let coloredSecondaryBackground = coolGrey10 // #F5F7FA
    static let failureBackground = pink1 // #620042
    static let successBackground = green1 // #014807
    static let weekEndBackground = coolGrey2 // #323F4B

    // MARK: Foregrounds (on colored backgrounds)

    static let coloredPrimaryForeground = lightBlue1 // #035388
    static let coloredSecondaryForeground = coolGrey1 // #1F2933
    static let successSecondaryForeground = green9 // #C1F2C7

    // MARK: Text

    static let titleText = coolGrey10 // #F5F7FA
    static let contentText = coolGrey7 // #9AA5B1
    static let secondaryText = coolGrey6 // #7B8794
    static let snackText = coolGrey10 // #F5F7FA
    static let coloredPrimaryFootnoteText = lightBlue1 // #035388
    static let coloredSecondaryFootnoteText = coolGrey1 // #1F2933
    static let textButtonText = coolGrey10 // #F5F7FA

    // MARK: Buttons

    static let primaryButtonForeground = coolGrey10 // #F5F7FA
    static let secondaryButtonForeground = coolGrey10 // #F5F7FA
    static let coloredPrimaryButtonForeground = lightBlue9 // #B3ECFF
    static let coloredSecondaryButtonForeground = coolGrey9 // #E4E7EB
    static let destructiveButtonForeground = coolGrey10 // #F5F7FA
    static let failureSecondaryForeground = pink9 // #FFB8D2

    // MARK: Borders

    static let secondaryBorderColor = coolGrey3 // #3E4C59

    // MARK: Snackbar

    static let snackError = coolGrey1 // #1F2933
    static let snackWarning = coolGrey1 // #1F2933
    static let snackSuccess = coolGrey1 // #1F2933

    // MARK: Tags - Idling

    static let idlingTagBackground = coolGrey8 // #CBD2D9
    static let idlingTagBorder = coolGrey10 // #F5F7FA
    static let idlingTagForeground = coolGrey2 // #323F4B

    // MARK: Tags - Completed

    static let completedTagBackground = green9 // #C1F2C7
    static let completedTagBorder = coolGrey10 // #F5F7FA
    static let completedTagForeground = green1 // #014807

    // MARK: Tags - Personal

    static let personalTagBackground = lightBlue9 // #B3ECFF
    static let personalTagBorder = coolGrey10 // #F5F7FA
    static let personalTagForeground = lightBlue1 // #035388

    // MARK: Tags - Current Account

    static let currentAccountTagBackground = pink9 // #FFB8D2
    static let currentAccountTagBorder = coolGrey10 // #F5F7FA
    static let currentAccountTagForeground = pink1 // #620042

    // MARK: Write to Tag

    static let customerBackground = lightBlue10 // #E3F8FF
    static let customerForeground = lightBlue6 // #40C3F7
    static let lockBackground = yellow10 // #FFFBEA
    static let lockForeground = yellow6 // #F7C948
    static let serverBackground = lightBlue7 // #5ED0FA
    static let serverForeground = red6 // #EF4E4E

    // MARK: Validation

    static let validationError = red5 // #E12D39

    // MARK: Glass

    static let glassBorder = coolGrey10 // #F5F7FA
    static let glassShadow = coolGrey1 // #1F2933
    static let glassForeground = coolGrey10 // #F5F7FA

    // MARK: Button Arrow

    static let arrowBackground = coolGrey10 // #F5F7FA

    // MARK: Accent

    static let accent = lightBlue7 // #5ED0FA
    static let lightestAccent = lightBlue10 // #E3F8FF
    static let alarm = red7 // #F86A6A
}

// MARK: - ShapeStyle Conformance

extension ShapeStyle where Self == Color {
    /// Backgrounds
    static var backgroundColor: Color {
        Color.backgroundColor
    }

    static var cardBackground: Color {
        Color.cardBackground
    }

    static var coloredPrimaryBackground: Color {
        Color.coloredPrimaryBackground
    }

    static var coloredSecondaryBackground: Color {
        Color.coloredSecondaryBackground
    }

    static var failureBackground: Color {
        Color.failureBackground
    }

    static var successBackground: Color {
        Color.successBackground
    }

    static var weekEndBackground: Color {
        Color.weekEndBackground
    }

    /// Foregrounds
    static var coloredPrimaryForeground: Color {
        Color.coloredPrimaryForeground
    }

    static var coloredSecondaryForeground: Color {
        Color.coloredSecondaryForeground
    }

    static var successSecondaryForeground: Color {
        Color.successSecondaryForeground
    }

    /// Text
    static var titleText: Color {
        Color.titleText
    }

    static var contentText: Color {
        Color.contentText
    }

    static var secondaryText: Color {
        Color.secondaryText
    }

    static var snackText: Color {
        Color.snackText
    }

    static var coloredPrimaryFootnoteText: Color {
        Color.coloredPrimaryFootnoteText
    }

    static var coloredSecondaryFootnoteText: Color {
        Color.coloredSecondaryFootnoteText
    }

    static var textButtonText: Color {
        Color.textButtonText
    }

    /// Buttons
    static var primaryButtonForeground: Color {
        Color.primaryButtonForeground
    }

    static var secondaryButtonForeground: Color {
        Color.secondaryButtonForeground
    }

    static var coloredPrimaryButtonForeground: Color {
        Color.coloredPrimaryButtonForeground
    }

    static var coloredSecondaryButtonForeground: Color {
        Color.coloredSecondaryButtonForeground
    }

    static var destructiveButtonForeground: Color {
        Color.destructiveButtonForeground
    }

    static var failureSecondaryForeground: Color {
        Color.failureSecondaryForeground
    }

    /// Borders
    static var secondaryBorderColor: Color {
        Color.secondaryBorderColor
    }

    /// Snackbar
    static var snackError: Color {
        Color.snackError
    }

    static var snackWarning: Color {
        Color.snackWarning
    }

    static var snackSuccess: Color {
        Color.snackSuccess
    }

    /// Tags
    static var idlingTagBackground: Color {
        Color.idlingTagBackground
    }

    static var idlingTagBorder: Color {
        Color.idlingTagBorder
    }

    static var idlingTagForeground: Color {
        Color.idlingTagForeground
    }

    static var completedTagBackground: Color {
        Color.completedTagBackground
    }

    static var completedTagBorder: Color {
        Color.completedTagBorder
    }

    static var completedTagForeground: Color {
        Color.completedTagForeground
    }

    static var personalTagBackground: Color {
        Color.personalTagBackground
    }

    static var personalTagBorder: Color {
        Color.personalTagBorder
    }

    static var personalTagForeground: Color {
        Color.personalTagForeground
    }

    static var currentAccountTagBackground: Color {
        Color.currentAccountTagBackground
    }

    static var currentAccountTagBorder: Color {
        Color.currentAccountTagBorder
    }

    static var currentAccountTagForeground: Color {
        Color.currentAccountTagForeground
    }

    /// Write to Tag
    static var customerBackground: Color {
        Color.customerBackground
    }

    static var customerForeground: Color {
        Color.customerForeground
    }

    static var lockBackground: Color {
        Color.lockBackground
    }

    static var lockForeground: Color {
        Color.lockForeground
    }

    static var serverBackground: Color {
        Color.serverBackground
    }

    static var serverForeground: Color {
        Color.serverForeground
    }

    /// Validation
    static var validationError: Color {
        Color.validationError
    }

    /// Glass
    static var glassBorder: Color {
        Color.glassBorder
    }

    static var glassShadow: Color {
        Color.glassShadow
    }

    static var glassForeground: Color {
        Color.glassForeground
    }

    /// Button Arrow
    static var arrowBackground: Color {
        Color.arrowBackground
    }

    /// Accent
    static var accent: Color {
        Color.accent
    }

    static var lightestAccent: Color {
        Color.lightestAccent
    }

    static var alarm: Color {
        Color.alarm
    }
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xf) * 17, (int & 0xf) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xff, int & 0xff)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xff, int >> 8 & 0xff, int & 0xff)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
