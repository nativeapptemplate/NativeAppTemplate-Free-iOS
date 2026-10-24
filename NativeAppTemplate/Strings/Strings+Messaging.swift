//
//  Strings+Messaging.swift
//  NativeAppTemplate
//

import Foundation

extension Strings {
    // MARK: Messaging

    static let shopCreated = String(localized: "Shop created successfully.")
    static let basicSettingsUpdated = String(localized: "Basic settings updated successfully.")
    static let shopDeleted = String(localized: "Shop deleted successfully.")
    static let shopDeletedError = String(localized: "There was a problem deleting shop.")

    static let itemTagCreated = String(localized: "Item tag created successfully.")
    static let itemTagUpdated = String(localized: "Item tag updated successfully.")
    static let itemTagDeleted = String(localized: "Item tag deleted successfully.")
    static let itemTagDeletedError = String(localized: "There was a problem deleting item tag.")
    static let itemTagCompletedError = String(localized: "There was a problem completing item tag.")
    static let itemTagIdledError = String(localized: "There was a problem idling item tag.")

    static let shopkeeperCreatedError = String(localized: "There was a problem creating the account.")
    static let signedUpButUnconfirmed = String(
        localized: """
        A message with a confirmation link has been sent to your email address. \
        Please follow the link to activate your account.
        """
    )

    static let shopkeeperUpdated = String(localized: "Account updated successfully.")
    static let shopkeeperDeleted = String(localized: "Account deleted successfully.")
    static let shopkeeperDeletedError = String(localized: "There was a problem deleting the account.")

    static let confirmedPrivacyVersionUpdated = String(localized: "Privacy policy accepted successfully.")
    static let confirmedPrivacyVersionUpdatedError = String(
        localized: "There was a problem accepting the privacy policy."
    )

    static let confirmedTermsVersionUpdated = String(localized: "Terms of use accepted successfully.")
    static let confirmedTermsVersionUpdatedError = String(localized: "There was a problem accepting the terms of use.")

    static let signedOut = String(localized: "Signed out successfully.")
    static let signedOutError = String(localized: "There was a problem signing out.")

    static let passwordUpdated = String(localized: "Password updated successfully.")

    static let sentResetPasswordInstruction = String(
        localized: """
        If your email address exists in our database, you will receive a password recovery link \
        at your email address in a few minutes.
        """
    )
    static let sentResetPasswordInstructionError = String(localized: "Unable to find user with the email.")

    static let sentConfirmationInstruction = String(
        localized: "An email with instructions for confirming your email address has been sent."
    )
    static let sentConfirmationInstructionError = String(localized: "Unable to find user with the email.")

    static let updateApp = String(localized: "Update App")
    static let installNewVersionApp = String(localized: "Please install new version app.")
}
