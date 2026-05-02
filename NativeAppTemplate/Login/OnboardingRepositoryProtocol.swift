//
//  OnboardingRepositoryProtocol.swift
//  NativeAppTemplate
//

import Foundation

@MainActor
protocol OnboardingRepositoryProtocol: AnyObject, Observable, Sendable {
    var onboardings: [Onboarding] { get set }
}
