//
//  Constants.swift
//  NativeAppTemplate
//

import typealias Foundation.TimeInterval
import SwiftUI

extension Int {
    static let minimumPasswordLength: Int = 8
    static let invitationCodeLength: Int = 6
}

// MARK: - Design Constants

enum NativeAppTemplateConstants {
    // MARK: - Spacing

    enum Spacing {
        /// 4pt - Micro spacing, tight padding
        static let xxxs: CGFloat = 4

        /// 8pt - Minimal spacing, compact layouts
        static let xxs: CGFloat = 8

        /// 12pt - Small spacing, close elements
        static let xs: CGFloat = 12

        /// 16pt - Base spacing unit, standard padding
        static let sm: CGFloat = 16

        /// 24pt - Medium spacing, section separation
        static let md: CGFloat = 24

        /// 32pt - Large spacing, major sections
        static let lg: CGFloat = 32

        /// 48pt - Extra large spacing, screen margins
        static let xl: CGFloat = 48

        /// 64pt - Very large spacing, major divisions
        static let xxl: CGFloat = 64

        /// 96pt - Dramatic spacing, large separations
        static let xxxl: CGFloat = 96

        /// 128pt - Massive spacing, hero sections
        static let xxxxl: CGFloat = 128
    }

    // MARK: - Animation Durations

    enum Animation {
        /// 0.15s - Fast animations, micro-interactions
        static let fast: Double = 0.15

        /// 0.3s - Standard animations, most UI transitions
        static let standard: Double = 0.3
    }

    // MARK: - Glass

    enum Glass {
        static let borderOpacity: Double = 0.2
        static let shadowOpacity: Double = 0.15
    }

    // MARK: - Layout

    enum Layout {
        static let borderWidth: CGFloat = 1
        static let shadowRadius: CGFloat = 8
    }

    // MARK: - Shop

    static let maximumShopNameLength = 100
    static let maximumShopDescriptionLength = 1_000

    // MARK: - ItemTag

    static let maximumItemTagNameLength = 100
    static let maximumItemTagDescriptionLength = 1_000

    // MARK: - Corner Radius

    enum CornerRadius {
        /// 4pt - Minimal rounding
        static let xs: CGFloat = 4

        /// 8pt - Small rounding, buttons
        static let sm: CGFloat = 8

        /// 12pt - Medium rounding, cards (default)
        static let md: CGFloat = 12

        /// 16pt - Large rounding, prominent cards
        static let lg: CGFloat = 16

        /// 24pt - Extra large rounding, hero elements
        static let xl: CGFloat = 24
    }
}

enum Strings {
    #if DEBUG
    private static let env = ProcessInfo.processInfo.environment
    static let scheme: String = env["NATIVEAPPTEMPLATE_API_SCHEME"] ?? "https"
    static let domain: String = env["NATIVEAPPTEMPLATE_API_DOMAIN"] ?? "api.nativeapptemplate.com"
    static let port: String = env["NATIVEAPPTEMPLATE_API_PORT"] ?? ""
    #else
    static let scheme: String = "https"
    static let domain: String = "api.nativeapptemplate.com"
    static let port: String = ""
    #endif

    static let appName: String = "NativeAppTemplate Free"

    /// This is for MyTurnTag Creator. Replace this.
    static let appStoreUrl: String = "https://apps.apple.com/app/myturntag-creator/id1516198303"

    static let placeholderFullName: String = "John Smith"
    static let placeholderEmail: String = "you@example.com"
    static let placeholderPassword: String = "password"

    static let defaultTimeZone: String = "London"

    static let keychainAccountLoggedInShopkeeper =
        "com.nativeapptemplate.NativeAppTemplateFree.LoggedInShopkeeperAccount"
    static let keychainServiceLoggedInShopkeeper =
        "com.nativeapptemplate.NativeAppTemplateFree.LoggedInShopkeeperService"

    static let shops = "Shops"
    static let settings = "Settings"
    static let loading = "Loading..."

    // MARK: Resend Confirmation Instructions View

    static let buttonSendMeConfirmationInstructions = "Resend confirmation instructions"
    static let didntReceiveConfirmationInstructions = "Didn't receive confirmation instructions?"

    // MARK: Forgot Password View

    static let buttonSendMeResetPasswordInstructions = "Send me reset password instructions"
    static let forgotYourPassword = "Forgot your password?"

    // MARK: Shop View

    static let shopName = "Shop Name"
    static let createShop = "Create Shop"
    static let editShop = "Edit Shop"
    static let addShop = "Add Shop"
    static let addShopDescription = "Add a new shop."
    static let deleteShop = "Delete Shop"
    static let shopNameIsRequired = "Shop name is required."
    static let shopNameIsInvalid = "Shop name is invalid."
    static let shopDescriptionIsInvalid = "Shop description is too long."

    static func shopNameHelp(maximumLength: Int) -> String {
        "Name must be 1–\(maximumLength) characters."
    }

    static func shopDescriptionHelp(maximumLength: Int) -> String {
        "Description can be up to \(maximumLength) characters."
    }

    static let timeZone = "Time Zone"
    static let createShopsLabel = "Create shops"
    static let tapShopBelow = "Tap a shop below."
    static let haveFun = "Have fun!"
    static let shopDetailInstruction = "Swipe an item tag to change its status."

    // MARK: Shop Settings View

    static let shopSettingsLabel = "Shop Settings"
    static let shopSettingsBasicSettingsLabel = "Basic Settings"
    static let shopSettingsManageItemTagsLabel = "Manage Item Tags"

    // MARK: Item Tag View

    static let nameLabel = "Name"
    static let descriptionLabel = "Description"
    static let itemTagNamePlaceholder = "Name"
    static let editItemTag = "Edit Item Tag"
    static let addItemTag = "Add Item Tag"
    static let addItemTagDescription = "Add a new item tag and start changing the item tag status."
    static let deleteItemTag = "Delete item tag"
    static let buttonDeleteItemTag = "Delete Item Tag"
    static let itemTagNameIsInvalid = "Item tag name is invalid."
    static let itemTagDescriptionIsInvalid = "Item tag description is too long."
    static let completedAtLabel = "Completed at"
    static let markAsCompleted = "Mark as completed"
    static let markAsIdled = "Mark as idled"

    static func itemTagNameHelp(maximumLength: Int) -> String {
        "Name must be 1–\(maximumLength) characters."
    }

    static func itemTagDescriptionHelp(maximumLength: Int) -> String {
        "Description can be up to \(maximumLength) characters."
    }

    // MARK: Settings View

    static let supportMail: String = "support@nativeapptemplate.com"
    static let supportWebsiteUrl: String = "https://nativeapptemplate.com"
    static let faqsUrl: String = "https://nativeapptemplate.com/faqs"
    static let privacyPolicyUrl: String = "https://nativeapptemplate.com/privacy"
    static let termsOfUseUrl: String = "https://nativeapptemplate.com/terms"

    static let myAccount = "My Account"
    static let profile = "Profile"
    static let supportWebsite = "Support Website"
    static let howToUse = "How To Use"
    static let faqs = "FAQs"
    static let rateApp = "Rate or Review the App"
    static let contact = "Contact"
    static let privacyPolicy = "Privacy Policy"
    static let termsOfUse = "Terms of Use"
    static let editProfile = "Edit Profile"
    static let deleteMyAccount = "Delete My Account"
    static let updatePassword = "Update Password"
    static let currentPassword = "Current Password"
    static let newPassword = "New Password"
    static let confirmNewPassword = "Confirm New Password"
    static let currentPasswordIsRequired = "Current password is required."
    static let newPasswordIsRequired = "New password is required."
    static let confirmNewPasswordIsRequired = "Confirm new password is required."
    static let weNeedYourCurrentPassword = "We need your current password to confirm your changes."
    // swiftlint:disable:next line_length
    static let reconfirmDescription = "A message with a confirmation link has been sent to your new email address. Please follow the link to update to your new email address. Your email address will not be updated until confirming."

    // MARK: Messaging

    static let shopCreated = "Shop created successfully."
    static let basicSettingsUpdated = "Basic settings updated successfully."
    static let shopDeleted = "Shop deleted successfully."
    static let shopDeletedError = "There was a problem deleting the shop."

    static let itemTagCreated = "Item tag created successfully."
    static let itemTagUpdated = "Item tag updated successfully."
    static let itemTagDeleted = "Item tag deleted successfully."
    static let itemTagDeletedError = "There was a problem deleting the item tag."
    static let itemTagCompletedError = "There was a problem completing the item tag."
    static let itemTagIdledError = "There was a problem idling the item tag."

    static let shopkeeperCreated = "Account created successfully."
    static let shopkeeperCreatedError = "There was a problem creating the account."
    // swiftlint:disable:next line_length
    static let signedUpButUnconfirmed = "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."

    static let shopkeeperUpdated = "Account updated successfully."
    static let shopkeeperDeleted = "Account deleted successfully."
    static let shopkeeperDeletedError = "There was a problem deleting the account."

    static let confirmedPrivacyVersionUpdated = "Privacy policy accepted successfully."
    static let confirmedPrivacyVersionUpdatedError = "There was a problem accepting the privacy policy."

    static let confirmedTermsVersionUpdated = "Terms of use accepted successfully."
    static let confirmedTermsVersionUpdatedError = "There was a problem accepting the terms of use."

    static let signedOut = "Signed out successfully."
    static let signedOutError = "There was a problem signing out."

    static let passwordUpdated = "Password updated successfully."
    static let passwordUpdatedError = "There was a problem updating the password."

    static let sentResetPasswordInstruction =
        "If your email address exists in our database, you will receive a password recovery link " +
        "at your email address in a few minutes."
    static let sentResetPasswordInstructionError = "Unable to find user with the email."

    static let sentConfirmationInstruction =
        "An email has been sent the email containing instructions for confirming your email address."
    static let sentConfirmationInstructionError = "Unable to find user with the email."

    static let pleaseSignIn = "Please sign in."
    static let updateApp = "Update App"
    static let installNewVersionApp = "Please install new version app."

    // MARK: Onboarding

    static let signIn = "Sign In"
    static let signUp = "Sign Up"
    static let signUpForAnAccount = "Sign Up for an Account"
    static let signInToYourAccount = "Sign In to Your Account"
    static let email = "Email"
    static let password = "Password"

    static var welcomeToApp: String {
        "Welcome to \(appName)"
    }

    // MARK: Other

    static let yes = "Yes"
    static let ok = "OK"
    static let no = "No"
    static let cancel = "Cancel"
    static let close = "Close"
    static let save = "Save"
    static let edit = "Edit"
    static let delete = "Delete"
    static let areYouSure = "Are you sure?"
    static let name = "Name"
    static let accept = "Accept"
    static let decline = "Decline"
    static let descriptionString = "Description"
    static let nameIsRequired = "Name is required."
    static let emailIsRequired = "Email is required."
    static let emailIsInvalid = "Email is invalid."
    static let passwordIsRequired = "Password is required."
    static let passwordIsInvalid = "Password is invalid."
    static let role = "Role"
    static let complete = "Complete"
    static let open = "Open"
    static let instructions = "Instructions"
    static let forceSignOut = "Force Sign Out?"
    static let signOut = "Sign Out"
    static let noConnection = "No Connection"
    static let checkInternetConnection = "Please check internet connection and try again."
    static let privacyPolicyUpdated = "Privacy Policy Updated"
    static let termsOfUseUpdated = "Terms of Use Updated"
    static let backToStartScreen = "Back to Start Screen"
    static let fullName = "Full Name"
    static let fullNameIsRequired = "Full name is required."
    static let idle = "Idle"
}

extension TimeInterval {
    // MARK: Message Banner

    static let autoDismissTime: Self = 3
}
