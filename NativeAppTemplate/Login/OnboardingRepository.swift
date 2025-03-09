//
//  OnboardingRepository.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import Foundation
import OrderedCollections

@MainActor @Observable class OnboardingRepository {
  var onboardings: [Onboarding] = []
  let onboardingsDictionary: OrderedDictionary = [
    1: false,
    2: false,
    3: false,
    4: true,
    5: false,
    6: false,
    7: true,
    8: true,
    9: false,
    10: false,
    11: true,
    12: false,
    13: false
  ]
  
  func reload() {
    onboardings = onboardingsDictionary.map { key, value in
      Onboarding(id: key, isPortraitImage: value)
    }
  }
}
