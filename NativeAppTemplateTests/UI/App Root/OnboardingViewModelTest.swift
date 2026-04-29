//
//  OnboardingViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
@Suite
struct OnboardingViewModelTest {
    let onboardingRepository = TestOnboardingRepository()

    func mockOnboarding(
        id: Int = 1,
        imageOrientation: ImageOrientation = .portrait
    ) -> Onboarding {
        Onboarding(
            id: id,
            imageOrientation: imageOrientation
        )
    }

    @Test
    func initialState() {
        let viewModel = OnboardingViewModel(
            onboardingRepository: onboardingRepository
        )

        #expect(viewModel.onboardings.isEmpty)
    }

    @Test
    func exposesRepositoryOnboardings() {
        let onboardings = [
            mockOnboarding(id: 1, imageOrientation: .portrait),
            mockOnboarding(id: 2, imageOrientation: .landscape),
            mockOnboarding(id: 3, imageOrientation: .portrait)
        ]

        onboardingRepository.setOnboardings(onboardings: onboardings)

        let viewModel = OnboardingViewModel(
            onboardingRepository: onboardingRepository
        )

        #expect(viewModel.onboardings.count == 3)
    }

    @Test
    func onboardingDescription() {
        let viewModel = OnboardingViewModel(
            onboardingRepository: onboardingRepository
        )

        #expect(viewModel.onboardingDescription(index: 1) == Strings.onboardingDescription1)
        #expect(viewModel.onboardingDescription(index: 2) == Strings.onboardingDescription2)
        #expect(viewModel.onboardingDescription(index: 3) == Strings.onboardingDescription3)
        #expect(viewModel.onboardingDescription(index: 4) == Strings.onboardingDescription4)
    }

    @Test
    func onboardingDescriptionInvalidIndex() {
        let viewModel = OnboardingViewModel(
            onboardingRepository: onboardingRepository
        )

        #expect(viewModel.onboardingDescription(index: 0) == Strings.onboardingDescription1)
        #expect(viewModel.onboardingDescription(index: 99) == Strings.onboardingDescription1)
    }

    @Test
    func onboardingWithMixedImageTypes() {
        let onboardings = [
            mockOnboarding(id: 1, imageOrientation: .portrait),
            mockOnboarding(id: 2, imageOrientation: .landscape),
            mockOnboarding(id: 3, imageOrientation: .portrait),
            mockOnboarding(id: 4, imageOrientation: .landscape)
        ]

        onboardingRepository.setOnboardings(onboardings: onboardings)

        let viewModel = OnboardingViewModel(
            onboardingRepository: onboardingRepository
        )

        #expect(viewModel.onboardings.count == 4)
        #expect(viewModel.onboardings[0].imageOrientation == .portrait)
        #expect(viewModel.onboardings[1].imageOrientation == .landscape)
        #expect(viewModel.onboardings[2].imageOrientation == .portrait)
        #expect(viewModel.onboardings[3].imageOrientation == .landscape)
    }
}
