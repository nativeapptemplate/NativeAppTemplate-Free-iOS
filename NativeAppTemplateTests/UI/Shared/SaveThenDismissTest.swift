//
//  SaveThenDismissTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

/// `saveThenDismiss` is what the form view models (shop basic settings, item tag edit,
/// password) run when the user taps Save.
@MainActor
struct SaveThenDismissTest {
    let messageBus = MessageBus()

    @Test
    func dismissesAfterASuccessfulSave() async {
        var didSave = false
        var dismissCount = 0

        await saveThenDismiss(
            messageBus: messageBus,
            successMessage: Strings.passwordUpdated,
            dismiss: { dismissCount += 1 },
            save: { didSave = true }
        )

        #expect(didSave)
        #expect(dismissCount == 1)
        #expect(messageBus.currentMessage?.level == .success)
        #expect(messageBus.currentMessage?.message == Strings.passwordUpdated)
    }

    @Test
    func staysOpenAndShowsTheErrorWhenTheSaveFails() async {
        var dismissCount = 0
        let message = "Internal server error."
        let httpResponseCode = 500

        await saveThenDismiss(
            messageBus: messageBus,
            successMessage: Strings.passwordUpdated,
            dismiss: { dismissCount += 1 },
            save: { throw NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message) }
        )

        // A failed save keeps the form open with the user's input
        #expect(dismissCount == 0)
        #expect(messageBus.currentMessage?.level == .error)
        // Message(error:) shows NativeAppTemplateAPIError.requestFailed's codedDescription:
        // "[NATIVEAPPTEMPLATE-2001] <message> [Status: <code>]"
        #expect(messageBus.currentMessage?.message == "[NATIVEAPPTEMPLATE-2001] \(message) [Status: \(httpResponseCode)]")
    }
}
