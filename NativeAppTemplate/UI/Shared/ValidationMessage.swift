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

extension View {
    /// Shows this text as a validation error when `isShown`; otherwise keeps its
    /// space but hides it, from VoiceOver too.
    func validationMessage(isShown: Bool) -> some View {
        modifier(ValidationMessageModifier(isShown: isShown))
    }
}
