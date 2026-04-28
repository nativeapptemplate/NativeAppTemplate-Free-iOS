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
            String.onboardingDescription1
        case 2:
            String.onboardingDescription2
        case 3:
            String.onboardingDescription3
        case 4:
            String.onboardingDescription4
        case 5:
            String.onboardingDescription5
        case 6:
            String.onboardingDescription6
        case 7:
            String.onboardingDescription7
        case 8:
            String.onboardingDescription8
        default:
            String.onboardingDescription1
        }
    }
}
