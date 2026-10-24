//
//  OnboardingViewTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import SwiftUI
import Testing

/// The art on the first screen is decoration: VoiceOver reads the title, not "Sparkle"
@MainActor
struct OnboardingViewTest {
    @Test
    func artIsNotReadAndTitleIs() throws {
        let labels = try AccessibilityElements.of(OnboardingView()).map(\.label)

        #expect(labels.contains(Strings.welcomeToApp))
        #expect(!labels.contains("Sparkle"))
    }
}
