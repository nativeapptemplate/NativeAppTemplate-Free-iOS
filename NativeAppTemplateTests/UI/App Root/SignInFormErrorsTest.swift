//
//  SignInFormErrorsTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import SwiftUI
import Testing

/// Sign-in, Forgot Password and Resend Confirmation opened with "Email is required." (and
/// "Password is required.") in red before anything was typed, like the forms untilEdited
/// already covered. Found on 2026-10-29 on a device. The errors wait until their field is
/// first edited, from VoiceOver too, so the accessibility tree has none when a screen opens
@MainActor
struct SignInFormErrorsTest {
    private let sessionController = TestSessionController()
    private let messageBus = MessageBus()

    @Test
    func signInOpensWithoutErrors() throws {
        let dataManager = DataManager(sessionController: sessionController)
        let view = SignInEmailAndPasswordView(
            viewModel: SignInEmailAndPasswordViewModel(sessionController: sessionController, messageBus: messageBus)
        )
        .environment(dataManager)
        .environment(messageBus)

        let labels = try AccessibilityElements.of(view, until: { $0.map(\.label).contains(Strings.password) })
            .map(\.label)

        // The headers show the screen was walked
        #expect(labels.contains(Strings.password))
        #expect(!labels.contains(Strings.emailIsRequired))
        #expect(!labels.contains(Strings.passwordIsRequired))
    }

    @Test
    func forgotPasswordOpensWithoutErrors() throws {
        let view = ForgotPasswordView(
            viewModel: ForgotPasswordViewModel(signUpRepository: TestSignUpRepository(), messageBus: messageBus)
        )

        let labels = try AccessibilityElements.of(view, until: { $0.map(\.label).contains(Strings.email) })
            .map(\.label)

        #expect(labels.contains(Strings.email))
        #expect(!labels.contains(Strings.emailIsRequired))
    }

    @Test
    func resendConfirmationOpensWithoutErrors() throws {
        let view = ResendConfirmationInstructionsView(
            viewModel: ResendConfirmationInstructionsViewModel(signUpRepository: TestSignUpRepository(), messageBus: messageBus)
        )

        let labels = try AccessibilityElements.of(view, until: { $0.map(\.label).contains(Strings.email) })
            .map(\.label)

        #expect(labels.contains(Strings.email))
        #expect(!labels.contains(Strings.emailIsRequired))
    }
}
