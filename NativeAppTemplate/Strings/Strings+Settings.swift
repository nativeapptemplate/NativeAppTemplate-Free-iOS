//
//  Strings+Settings.swift
//  NativeAppTemplate
//

import Foundation

extension Strings {
    // MARK: Settings View

    static let supportMail: String = "support@nativeapptemplate.com"
    static let supportWebsiteUrl: String = "https://nativeapptemplate.com"
    static let faqsUrl: String = "https://nativeapptemplate.com/faqs"
    static let privacyPolicyUrl: String = "https://nativeapptemplate.com/privacy"
    static let termsOfUseUrl: String = "https://nativeapptemplate.com/terms"

    static let myAccount = String(localized: "My Account")
    static let profile = String(localized: "Profile")
    static let supportWebsite = String(localized: "Support Website")
    static let faqs = String(localized: "FAQs")
    static let rateApp = String(localized: "Rate or Review the App")
    static let contact = String(localized: "Contact")
    static let privacyPolicy = String(localized: "Privacy Policy")
    static let termsOfUse = String(localized: "Terms of Use")
    static let editProfile = String(localized: "Edit Profile")
    static let deleteMyAccount = String(localized: "Delete My Account")
    /// The API deletes the shopkeeper's organization, with its shops, with the account
    static let deleteMyAccountDescription = String(
        localized: "Your shops and item tags are deleted with your account. This cannot be undone."
    )
    static let updatePassword = String(localized: "Update Password")
    static let currentPassword = String(localized: "Current Password")
    static let newPassword = String(localized: "New Password")
    static let confirmNewPassword = String(localized: "Confirm New Password")
    static let currentPasswordIsRequired = String(localized: "Current password is required.")
    static let newPasswordIsRequired = String(localized: "New password is required.")
    static let confirmNewPasswordIsRequired = String(localized: "Confirm new password is required.")
    static let passwordsDoNotMatch = String(localized: "Passwords do not match.")
    static let weNeedYourCurrentPassword = String(localized: "We need your current password to confirm your changes.")
    static let reconfirmDescription = String(
        localized: """
        A message with a confirmation link has been sent to your new email address. \
        Please follow the link to update to your new email address. \
        Your email address will not be updated until confirming.
        """
    )
}
