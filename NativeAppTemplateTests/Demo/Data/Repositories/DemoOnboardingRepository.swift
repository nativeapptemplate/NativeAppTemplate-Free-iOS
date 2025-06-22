//
//  DemoOnboardingRepository.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

@testable import NativeAppTemplate
import Foundation
import OrderedCollections

@MainActor
final class DemoOnboardingRepository: OnboardingRepositoryProtocol {
  var onboardings: [Onboarding] = []
  var onboardingsDictionary: OrderedDictionary<Int, Bool> {
    var dict = OrderedDictionary<Int, Bool>()
    for onboarding in onboardings {
      dict[onboarding.id] = onboarding.isPortraitImage
    }
    return dict
  }

  func reload() {
    // Demo data with predefined onboarding items
    let demoOnboardingData: OrderedDictionary = [
      1: false,  // Landscape image
      2: false,  // Landscape image
      3: false,  // Landscape image
      4: true,   // Portrait image
      5: false,  // Landscape image
      6: false,  // Landscape image
      7: true,   // Portrait image
      8: true,   // Portrait image
      9: false,  // Landscape image
      10: false, // Landscape image
      11: true,  // Portrait image
      12: false, // Landscape image
      13: false  // Landscape image
    ]

    onboardings = demoOnboardingData.map { key, value in
      Onboarding(id: key, isPortraitImage: value)
    }
  }
}
