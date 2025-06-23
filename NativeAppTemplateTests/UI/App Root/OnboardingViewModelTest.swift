//
//  OnboardingViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/21.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct OnboardingViewModelTest {
  let onboardingRepository = TestOnboardingRepository()

  func mockOnboarding(
    id: Int = 1,
    isPortraitImage: Bool = true
  ) -> Onboarding {
    Onboarding(
      id: id,
      isPortraitImage: isPortraitImage
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
      mockOnboarding(id: 1, isPortraitImage: true),
      mockOnboarding(id: 2, isPortraitImage: false),
      mockOnboarding(id: 3, isPortraitImage: true)
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
    #expect(viewModel.onboardingDescription(index: 1) == String.onboardingDescription1)
    #expect(viewModel.onboardingDescription(index: 2) == String.onboardingDescription2)
    #expect(viewModel.onboardingDescription(index: 3) == String.onboardingDescription3)
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
    #expect(result == String.onboardingDescription1)
    let result2 = viewModel.onboardingDescription(index: 99)
    #expect(result2 == String.onboardingDescription1)
  }

  @Test
  func onboardingDescriptionAllSteps() {
    let onboardings = (1...13).map { mockOnboarding(id: $0) }
    onboardingRepository.setOnboardings(onboardings: onboardings)

    let viewModel = OnboardingViewModel(
      onboardingRepository: onboardingRepository
    )

    viewModel.reload()

    // Test all 13 onboarding steps (1-based indexing)
    let expectedDescriptions = [
      String.onboardingDescription1, String.onboardingDescription2, String.onboardingDescription3,
      String.onboardingDescription4, String.onboardingDescription5, String.onboardingDescription6,
      String.onboardingDescription7, String.onboardingDescription8, String.onboardingDescription9,
      String.onboardingDescription10, String.onboardingDescription11, String.onboardingDescription12,
      String.onboardingDescription13
    ]

    for index in 1...13 {
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
      mockOnboarding(id: 1, isPortraitImage: true),
      mockOnboarding(id: 2, isPortraitImage: false),
      mockOnboarding(id: 3, isPortraitImage: true),
      mockOnboarding(id: 4, isPortraitImage: false)
    ]

    onboardingRepository.setOnboardings(onboardings: onboardings)

    let viewModel = OnboardingViewModel(
      onboardingRepository: onboardingRepository
    )

    viewModel.reload()

    #expect(viewModel.onboardings.count == 4)
    #expect(viewModel.onboardings[0].isPortraitImage == true)
    #expect(viewModel.onboardings[1].isPortraitImage == false)
    #expect(viewModel.onboardings[2].isPortraitImage == true)
    #expect(viewModel.onboardings[3].isPortraitImage == false)
  }
}
