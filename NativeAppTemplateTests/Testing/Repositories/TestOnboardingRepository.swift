//
//  TestOnboardingRepository.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate

@MainActor
final class TestOnboardingRepository: OnboardingRepositoryProtocol {
    var onboardings: [Onboarding] = []

    /// A test-only
    var reloadCalled = false

    func reload() {
        reloadCalled = true
    }

    /// A test-only
    func setOnboardings(onboardings: [Onboarding]) {
        self.onboardings = onboardings
    }
}
