//
//  TestOnboardingRepository.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Foundation
import OrderedCollections
@testable import NativeAppTemplate

@MainActor
final class TestOnboardingRepository: OnboardingRepositoryProtocol {
  var onboardings: [Onboarding] = []
  var onboardingsDictionary: OrderedDictionary<Int, Bool> {
    var dict = OrderedDictionary<Int, Bool>()
    for onboarding in onboardings {
      dict[onboarding.id] = onboarding.isPortraitImage
    }
    return dict
  }

  // A test-only
  var reloadCalled = false

  func reload() {
    reloadCalled = true
  }

  // A test-only
  func setOnboardings(onboardings: [Onboarding]) {
    self.onboardings = onboardings
  }
}
