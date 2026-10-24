//
//  Strings+Onboarding.swift
//  NativeAppTemplate
//

import Foundation

extension Strings {
    // MARK: Onboarding

    static let signIn = String(localized: "Sign In")
    static let signUp = String(localized: "Sign Up")
    static let signUpForAnAccount = String(localized: "Sign Up for an Account")
    static let signInToYourAccount = String(localized: "Sign In to Your Account")
    static let email = String(localized: "Email")
    static let password = String(localized: "Password")
    static let sessionExpired = String(localized: "Session Expired")
    static let sessionExpiredDescription = String(localized: "Your session has expired. Please sign in again.")

    static var welcomeToApp: String {
        String(localized: "Welcome to \(appName)")
    }
}
