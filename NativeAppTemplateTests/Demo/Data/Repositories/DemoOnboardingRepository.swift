//
//  DemoOnboardingRepository.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate

@MainActor
final class DemoOnboardingRepository: OnboardingRepositoryProtocol {
    var onboardings: [Onboarding] = []

    init() {
        setupMockOnboardings()
    }

    func reload() {
        setupMockOnboardings()
    }

    // MARK: - Test Helpers

    func resetState() {
        setupMockOnboardings()
    }

    func addOnboarding(_ onboarding: Onboarding) {
        onboardings.append(onboarding)
    }

    func clearOnboardings() {
        onboardings.removeAll()
    }

    private func setupMockOnboardings() {
        onboardings = [
            Onboarding(id: 1, imageOrientation: .portrait),
            Onboarding(id: 2, imageOrientation: .landscape),
            Onboarding(id: 3, imageOrientation: .portrait),
            Onboarding(id: 4, imageOrientation: .landscape),
            Onboarding(id: 5, imageOrientation: .portrait)
        ]
    }
}
