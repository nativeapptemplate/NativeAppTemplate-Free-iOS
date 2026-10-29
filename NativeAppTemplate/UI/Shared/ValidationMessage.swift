//
//  ValidationMessage.swift
//  NativeAppTemplate
//

import SwiftUI

/// A validation message that keeps its space in the layout while it is not shown.
///
/// Hiding it with `.clear` alone leaves an invisible accessibility element, so
/// VoiceOver would read an error that isn't there; it is also hidden from
/// accessibility while not shown.
struct ValidationMessageModifier: ViewModifier {
    let isShown: Bool

    func body(content: Content) -> some View {
        content
            .foregroundStyle(isShown ? Color.validationError : Color.clear)
            .accessibilityHidden(!isShown)
    }
}

/// Keeps a field's error hidden until the field is first edited. A new form opened with
/// "Name is required." in red before anything was typed; the save button stays disabled
/// meanwhile, so nothing is lost by waiting.
struct UntilEditedModifier<Value: Equatable>: ViewModifier {
    let value: Value
    @State private var isEdited = false

    func body(content: Content) -> some View {
        Group {
            if isEdited {
                // Edited, so validationMessage(isShown:) or the caller alone decides; an outer
                // accessibilityHidden(false) here undid its accessibilityHidden(true), and
                // VoiceOver read a message for an edited field that had none
                content
            } else {
                content
                    .hidden()
                    .accessibilityHidden(true)
            }
        }
        .onChange(of: value) {
            isEdited = true
        }
    }
}

extension View {
    /// Shows this text as a validation error when `isShown`; otherwise keeps its
    /// space but hides it, from VoiceOver too.
    func validationMessage(isShown: Bool) -> some View {
        modifier(ValidationMessageModifier(isShown: isShown))
    }

    /// Hides this field error until `value`, the field's text, first changes.
    func untilEdited(_ value: some Equatable) -> some View {
        modifier(UntilEditedModifier(value: value))
    }
}
