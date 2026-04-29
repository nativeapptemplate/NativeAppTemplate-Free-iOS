//
//  OnboardingRepository.swift
//  NativeAppTemplate
//

import Foundation

@MainActor @Observable class OnboardingRepository: OnboardingRepositoryProtocol {
    var onboardings: [Onboarding] = [
        Onboarding(id: 1, imageOrientation: .landscape),
        Onboarding(id: 2, imageOrientation: .landscape),
        Onboarding(id: 3, imageOrientation: .portrait),
        Onboarding(id: 4, imageOrientation: .portrait)
    ]
}
