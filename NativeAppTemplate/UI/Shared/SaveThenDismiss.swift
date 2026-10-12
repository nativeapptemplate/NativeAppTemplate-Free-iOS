//
//  SaveThenDismiss.swift
//  NativeAppTemplate
//

/// Runs a form's save and closes the form only when the save succeeds.
///
/// On success it posts `successMessage` and calls `dismiss`. On failure it posts the error
/// (shown with its `codedDescription`) and leaves the form open, so the user keeps their
/// input and can retry.
@MainActor
func saveThenDismiss(
    messageBus: MessageBus,
    successMessage: String,
    dismiss: () -> Void,
    save: () async throws -> Void
) async {
    do {
        try await save()
        messageBus.post(message: Message(level: .success, message: successMessage))
        dismiss()
    } catch {
        messageBus.post(message: Message(error: error))
    }
}
