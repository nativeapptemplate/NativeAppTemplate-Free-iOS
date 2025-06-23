//
//  OnboardingViewModel.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/16.
//

import SwiftUI
import Observation

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
    case 9:
      String.onboardingDescription9
    case 10:
      String.onboardingDescription10
    case 11:
      String.onboardingDescription11
    case 12:
      String.onboardingDescription12
    case 13:
      String.onboardingDescription13
    default:
      String.onboardingDescription1
    }
  }
}
