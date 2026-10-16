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
