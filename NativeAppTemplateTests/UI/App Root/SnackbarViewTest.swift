//
//  SnackbarViewTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import SwiftUI
import Testing

/// The snackbar's close button, as VoiceOver and UI automation reach it. On the
/// same view in another app, a WebDriverAgent dump of a message listed its text but
/// no close button, and the button was a 16 pt square (the symbol's frame,
/// NativeAppTemplateConstants.Spacing.sm).
@MainActor
struct SnackbarViewTest {
    private let message = "Something went wrong."

    private func closeButton() throws -> AccessibilityElements.Element? {
        try AccessibilityElements.of(
            SnackbarView(state: SnackbarState(status: .warning, message: message), visible: .constant(true))
        ).first { $0.traits.contains(.button) }
    }

    /// A button named "Close" (Strings.close; the tests run in English)
    @Test
    func closeButtonIsALabeledButton() throws {
        let button = try #require(try closeButton())

        #expect(button.label == "Close")
    }

    /// At least NativeAppTemplateConstants.Spacing.lg (32 pt) square to tap, while the
    /// symbol stays 16 pt
    @Test
    func closeButtonIsLargeEnoughToTap() throws {
        let button = try #require(try closeButton())

        #expect(button.frame.width >= NativeAppTemplateConstants.Spacing.lg)
        #expect(button.frame.height >= NativeAppTemplateConstants.Spacing.lg)
    }

    /// The message itself is still read
    @Test
    func messageIsRead() throws {
        let labels = try AccessibilityElements.of(
            SnackbarView(state: SnackbarState(status: .warning, message: message), visible: .constant(true))
        ).map(\.label)

        #expect(labels.contains(message))
    }
}
