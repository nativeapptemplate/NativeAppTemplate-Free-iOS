//
//  ValidationMessageTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import SwiftUI
import Testing

/// A validation message hidden with `.clear` alone was still an accessibility
/// element, so VoiceOver read "Name is required." on a valid form.
/// `validationMessage(isShown:)` must keep it out of the accessibility tree
/// until it is shown.
@MainActor
struct ValidationMessageTest {
    // Both strings are made up for the test; the sibling label proves the walk
    // below reaches SwiftUI's accessibility elements at all.
    private let siblingLabel = "Sibling label"
    private let messageText = "Name is required."

    @Test
    func hiddenMessageIsNotAnAccessibilityElement() throws {
        let labels = try accessibilityLabels(isShown: false)

        #expect(labels.contains(siblingLabel))
        #expect(!labels.contains(messageText))
    }

    @Test
    func shownMessageIsAnAccessibilityElement() throws {
        let labels = try accessibilityLabels(isShown: true)

        #expect(labels.contains(siblingLabel))
        #expect(labels.contains(messageText))
    }

    /// A new form opened with "Name is required." before anything was typed. The message
    /// waits until its field is first edited (`untilEdited`), from VoiceOver too
    @Test
    func messageIsHiddenUntilTheFieldIsEdited() throws {
        let labels = try AccessibilityElements.of(Form(edited: false, siblingLabel: siblingLabel, messageText: messageText))
            .map(\.label)

        #expect(labels.contains(siblingLabel))
        #expect(!labels.contains(messageText))
    }

    @Test
    func messageShowsOnceTheFieldIsEdited() throws {
        let labels = try AccessibilityElements.of(Form(edited: true, siblingLabel: siblingLabel, messageText: messageText))
            .map(\.label)

        #expect(labels.contains(siblingLabel))
        #expect(labels.contains(messageText))
    }

    /// An edited field with valid text has no message, for VoiceOver too. untilEdited's
    /// accessibilityHidden(false) undid validationMessage's accessibilityHidden(true), so
    /// VoiceOver read "Name is required." under a filled-in name. Found on 2026-10-29 on a
    /// device (the free app's sign-up, through WebDriverAgent's accessibility snapshot)
    @Test
    func editedFieldWithoutAnErrorHasNoMessage() throws {
        let labels = try AccessibilityElements.of(
            Form(edited: true, isShown: false, siblingLabel: siblingLabel, messageText: messageText)
        )
        .map(\.label)

        #expect(labels.contains(siblingLabel))
        #expect(!labels.contains(messageText))
    }

    /// A field's text and its required-field message; `edited` types into it on appear
    private struct Form: View {
        let edited: Bool
        var isShown = true
        let siblingLabel: String
        let messageText: String
        @State private var text = ""

        var body: some View {
            VStack {
                Text(siblingLabel)
                Text(messageText)
                    .validationMessage(isShown: isShown)
                    .untilEdited(text)
            }
            .onAppear {
                if edited {
                    text = "Typed"
                }
            }
        }
    }

    // MARK: - Helpers

    /// The labels of every accessibility element next to the message and in it
    private func accessibilityLabels(isShown: Bool) throws -> [String] {
        try AccessibilityElements.of(
            VStack {
                Text(siblingLabel)
                Text(messageText)
                    .validationMessage(isShown: isShown)
            }
        ).map(\.label)
    }
}
