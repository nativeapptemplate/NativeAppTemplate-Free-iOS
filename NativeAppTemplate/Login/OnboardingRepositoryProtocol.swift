//
//  OnboardingRepositoryProtocol.swift
//  NativeAppTemplate
//

import Foundation
import OrderedCollections

@MainActor protocol OnboardingRepositoryProtocol: AnyObject, Observable, Sendable {
    var onboardings: [Onboarding] { get set }
    var onboardingsDictionary: OrderedDictionary<Int, Bool> { get }

    func reload()
}
