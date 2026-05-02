//
//  OnboardingViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class OnboardingViewModel {
    private let onboardingRepository: OnboardingRepositoryProtocol

    var onboardings: [Onboarding] {
        onboardingRepository.onboardings
    }

    init(onboardingRepository: OnboardingRepositoryProtocol) {
        self.onboardingRepository = onboardingRepository
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
