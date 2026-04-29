//
//  OnboardingViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class OnboardingViewModel {
    var onboardings: [Onboarding] = []

    private let onboardingRepository: OnboardingRepositoryProtocol

    init(onboardingRepository: OnboardingRepositoryProtocol) {
        self.onboardingRepository = onboardingRepository
    }

    func reload() {
        onboardingRepository.reload()
        onboardings = onboardingRepository.onboardings
    }

    func onboardingDescription(index: Int) -> String {
        switch index {
        case 1:
            Strings.onboardingDescription1
        case 2:
            Strings.onboardingDescription2
        case 3:
            Strings.onboardingDescription3
        case 4:
            Strings.onboardingDescription4
        default:
            Strings.onboardingDescription1
        }
    }
}
