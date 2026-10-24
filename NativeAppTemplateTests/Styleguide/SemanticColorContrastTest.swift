//
//  SemanticColorContrastTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import SwiftUI
import Testing
import UIKit

/// Every pair of a color and what it is drawn on, in the light and the dark appearance.
/// Mapping a color to a new value by its name alone once left a paid edition's close button at
/// 1.10:1; the pair, not the name, is what has to be readable. Text needs WCAG's 4.5:1, icons and
/// a control's outline 3:1.
struct SemanticColorContrastTest {
    struct Pair: CustomTestStringConvertible, Sendable {
        let name: String
        let foreground: @Sendable () -> Color
        let background: @Sendable () -> Color
        let minimum: Double

        var testDescription: String {
            name
        }
    }

    private static let text = 4.5
    private static let icon = 3.0

    static let pairs: [Pair] = [
        // Text on the screen and on cards
        Pair(name: "title on the screen", foreground: { .titleText }, background: { .backgroundColor }, minimum: text),
        Pair(name: "title on a card", foreground: { .titleText }, background: { .cardBackground }, minimum: text),
        Pair(name: "content on the screen", foreground: { .contentText }, background: { .backgroundColor }, minimum: text),
        Pair(name: "content on a card", foreground: { .contentText }, background: { .cardBackground }, minimum: text),
        Pair(name: "secondary on the screen", foreground: { .secondaryText }, background: { .backgroundColor }, minimum: text),
        Pair(name: "secondary on a card", foreground: { .secondaryText }, background: { .cardBackground }, minimum: text),
        Pair(name: "snack text on the screen", foreground: { .snackText }, background: { .backgroundColor }, minimum: text),
        Pair(name: "accent on the screen", foreground: { .accent }, background: { .backgroundColor }, minimum: text),
        Pair(name: "accent on a card", foreground: { .accent }, background: { .cardBackground }, minimum: text),
        Pair(name: "validation error on the screen", foreground: { .validationError }, background: { .backgroundColor }, minimum: text),
        Pair(name: "validation error on a card", foreground: { .validationError }, background: { .cardBackground }, minimum: text),
        // Buttons: primary is white on its fill, the others are text and outline on the screen.
        // The primary fill on the dark screen is 2.50:1, but its white text identifies the button
        // (WCAG 1.4.11 asks nothing of the fill then), and a lighter fill would take the text under 4.5:1
        Pair(name: "primary button", foreground: { .primaryButtonForeground }, background: { .primaryButtonBackground }, minimum: text),
        Pair(name: "secondary button", foreground: { .secondaryButtonForeground }, background: { .backgroundColor }, minimum: text),
        Pair(name: "destructive button", foreground: { .destructiveButtonForeground }, background: { .backgroundColor }, minimum: text),
        // Tags
        Pair(name: "idled tag", foreground: { .idledTagForeground }, background: { .idledTagBackground }, minimum: text),
        Pair(name: "completed tag", foreground: { .completedTagForeground }, background: { .completedTagBackground }, minimum: text),
        // The tip's icon and close button
        Pair(name: "alarm on the screen", foreground: { .alarm }, background: { .backgroundColor }, minimum: icon)
    ]

    @Test(arguments: pairs, [UIUserInterfaceStyle.light, .dark])
    func pairIsReadable(pair: Pair, style: UIUserInterfaceStyle) {
        let ratio = Contrast.ratio(pair.foreground(), pair.background(), style: style)
        #expect(ratio >= pair.minimum, "\(pair.name): \(ratio)")
    }

    /// The colors really change with the appearance: the light screen is light and the dark one dark
    @Test
    func screenFollowsTheAppearance() {
        #expect(Contrast.luminance(.backgroundColor, style: .light) > 0.8)
        #expect(Contrast.luminance(.backgroundColor, style: .dark) < 0.05)
    }
}
