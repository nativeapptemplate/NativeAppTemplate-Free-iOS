//
//  OnboardingRepositoryProtocol.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import Foundation
import OrderedCollections

@MainActor protocol OnboardingRepositoryProtocol: AnyObject, Observable, Sendable {
  var onboardings: [Onboarding] { get set }
  var onboardingsDictionary: OrderedDictionary<Int, Bool> { get }
  
  func reload()
}
