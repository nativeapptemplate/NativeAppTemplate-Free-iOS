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
    func reload() {
        let onboardings = [
            mockOnboarding(id: 1, imageOrientation: .portrait),
            mockOnboarding(id: 2, imageOrientation: .landscape),
            mockOnboarding(id: 3, imageOrientation: .portrait)
        ]

        onboardingRepository.setOnboardings(onboardings: onboardings)

        let viewModel = OnboardingViewModel(
            onboardingRepository: onboardingRepository
        )

        viewModel.reload()

        #expect(onboardingRepository.reloadCalled == true)
        #expect(viewModel.onboardings.count == 3)
    }

    @Test
    func onboardingDescription() {
        let onboardings = [
            mockOnboarding(id: 1),
            mockOnboarding(id: 2),
            mockOnboarding(id: 3)
        ]

        onboardingRepository.setOnboardings(onboardings: onboardings)

        let viewModel = OnboardingViewModel(
            onboardingRepository: onboardingRepository
        )

        viewModel.reload()

        // Test valid indices (1-based indexing in the switch case)
        #expect(viewModel.onboardingDescription(index: 1) == Strings.onboardingDescription1)
        #expect(viewModel.onboardingDescription(index: 2) == Strings.onboardingDescription2)
        #expect(viewModel.onboardingDescription(index: 3) == Strings.onboardingDescription3)
    }

    @Test
    func onboardingDescriptionInvalidIndex() {
        let onboardings = [
            mockOnboarding(id: 1)
        ]

        onboardingRepository.setOnboardings(onboardings: onboardings)

        let viewModel = OnboardingViewModel(
            onboardingRepository: onboardingRepository
        )

        viewModel.reload()

        // Test invalid indices - should return default (onboardingDescription1)
        let result = viewModel.onboardingDescription(index: 0)
        #expect(result == Strings.onboardingDescription1)
        let result2 = viewModel.onboardingDescription(index: 99)
        #expect(result2 == Strings.onboardingDescription1)
    }

    @Test
    func onboardingDescriptionAllSteps() {
        let onboardings = (1...4).map { mockOnboarding(id: $0) }
        onboardingRepository.setOnboardings(onboardings: onboardings)

        let viewModel = OnboardingViewModel(
            onboardingRepository: onboardingRepository
        )

        viewModel.reload()

        let expectedDescriptions = [
            Strings.onboardingDescription1,
            Strings.onboardingDescription2,
            Strings.onboardingDescription3,
            Strings.onboardingDescription4
        ]

        for index in 1...4 {
            #expect(viewModel.onboardingDescription(index: index) == expectedDescriptions[index - 1])
        }
    }

    @Test
    func emptyOnboardings() {
        onboardingRepository.setOnboardings(onboardings: [])

        let viewModel = OnboardingViewModel(
            onboardingRepository: onboardingRepository
        )

        viewModel.reload()

        #expect(viewModel.onboardings.isEmpty)
        #expect(onboardingRepository.reloadCalled == true)
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

        viewModel.reload()

        #expect(viewModel.onboardings.count == 4)
        #expect(viewModel.onboardings[0].imageOrientation == .portrait)
        #expect(viewModel.onboardings[1].imageOrientation == .landscape)
        #expect(viewModel.onboardings[2].imageOrientation == .portrait)
        #expect(viewModel.onboardings[3].imageOrientation == .landscape)
    }
}
