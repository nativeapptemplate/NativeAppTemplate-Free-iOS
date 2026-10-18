//
//  Constants.swift
//  NativeAppTemplate
//

import typealias Foundation.TimeInterval
import SwiftUI

extension Int {
    static let minimumPasswordLength: Int = 8
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
    private static let endpoint = APIEndpoint.resolve(
        environment: ProcessInfo.processInfo.environment,
        info: Bundle.main.infoDictionary ?? [:]
    )
    #else
    private static let endpoint = APIEndpoint.production
    #endif
    static let scheme: String = endpoint.scheme
    static let domain: String = endpoint.domain
    static let port: String = endpoint.port

    static let appName: String = "Native App Template"

    // MARK: App Store page

    /// APP_STORE_ID from AppStore.xcconfig (built into Info.plist): the app's Apple ID, the
    /// number in its App Store URL. Empty, as committed, hides NeedAppUpdatesView's Update App
    /// button. See README "App Store page".
    static let appStoreId: String = Bundle.main.object(forInfoDictionaryKey: "AppStoreID") as? String ?? ""
    /// The page NeedAppUpdatesView's Update App button opens; nil while APP_STORE_ID is empty
    static let appStoreUrl: URL? = appStorePage(appStoreId: appStoreId)

    /// https://apps.apple.com/app/id<Apple ID>, or nil unless `appStoreId` is all digits
    /// (an Apple ID is a number; anything else, e.g. a pasted URL, would open a wrong page)
    static func appStorePage(appStoreId: String) -> URL? {
        guard !appStoreId.isEmpty, appStoreId.allSatisfy({ ("0"..."9").contains($0) }) else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(appStoreId)")
    }

    static let placeholderFullName: String = .init(localized: "John Smith")
    static let placeholderEmail: String = "you@example.com"
    static let placeholderPassword: String = .init(localized: "password")

    static let defaultTimeZone: String = "London"

    static let keychainAccountLoggedInShopkeeper =
        "com.nativeapptemplate.NativeAppTemplateFree.LoggedInShopkeeperAccount"
    static let keychainServiceLoggedInShopkeeper =
        "com.nativeapptemplate.NativeAppTemplateFree.LoggedInShopkeeperService"

    static let shops = String(localized: "Shops")
    static let settings = String(localized: "Settings")
    static let loading = String(localized: "Loading...")

    // MARK: Resend Confirmation Instructions View

    static let buttonSendMeConfirmationInstructions = String(localized: "Resend confirmation instructions")
    static let didntReceiveConfirmationInstructions = String(localized: "Didn't receive confirmation instructions?")

    // MARK: Forgot Password View

    static let buttonSendMeResetPasswordInstructions = String(localized: "Send me reset password instructions")
    static let forgotYourPassword = String(localized: "Forgot your password?")

    // MARK: Shop View

    static let shopName = String(localized: "Shop Name")
    static let addShop = String(localized: "Add Shop")
    static let addShopDescription = String(localized: "Add a new shop.")
    static let deleteShop = String(localized: "Delete Shop")
    static let shopNameIsInvalid = String(localized: "Shop name is invalid.")
    static let shopDescriptionIsInvalid = String(localized: "Shop description is too long.")

    static func shopNameHelp(maximumLength: Int) -> String {
        String(localized: "Name must be 1–\(maximumLength) characters.")
    }

    static func shopDescriptionHelp(maximumLength: Int) -> String {
        String(localized: "Description can be up to \(maximumLength) characters.")
    }

    static let timeZone = String(localized: "Time Zone")
    static let appLanguage = String(localized: "App Language")
    static let changeInSettings = String(localized: "Change in Settings")
    static let emailsAreSentInThisLanguageToo = String(localized: "Emails are sent in this language too.")
    static let tapShopBelow = String(localized: "Tap shop below.")
    static let haveFun = String(localized: "Have fun!")
    static let shopDetailInstruction = String(localized: "Swipe to change item tag status.")

    // MARK: Shop Settings View

    static let shopSettingsLabel = String(localized: "Shop Settings")
    static let shopSettingsBasicSettingsLabel = String(localized: "Basic Settings")
    static let shopSettingsManageItemTagsLabel = String(localized: "Manage Item Tags")

    // MARK: Item Tag View

    static let nameLabel = String(localized: "Name")
    static let descriptionLabel = String(localized: "Description")
    static let itemTagNamePlaceholder = String(localized: "Name")
    static let editItemTag = String(localized: "Edit Item Tag")
    static let addItemTag = String(localized: "Add Item Tag")
    static let addItemTagDescription = String(localized: "Add a new item tag and start changing item tag status.")
    static let buttonDeleteItemTag = String(localized: "Delete Item Tag")
    static let itemTagNameIsInvalid = String(localized: "Item tag name is invalid.")
    static let itemTagDescriptionIsInvalid = String(localized: "Item tag description is too long.")
    static let completedAtLabel = String(localized: "Completed at")
    static let markAsCompleted = String(localized: "Mark as completed")
    static let markAsIdled = String(localized: "Mark as idled")

    static func itemTagNameHelp(maximumLength: Int) -> String {
        String(localized: "Name must be 1–\(maximumLength) characters.")
    }

    static func itemTagDescriptionHelp(maximumLength: Int) -> String {
        String(localized: "Description can be up to \(maximumLength) characters.")
    }

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

    // MARK: Errors

    /// A request failed and the API sent no error_message (e.g. a 5xx without a JSON body)
    static let serverCommunicationError =
        String(localized: "Something went wrong while communicating with the server. Please try again later.")
    /// What the user sees for a developer-only error (a malformed response, a Keychain
    /// failure, ...); its details go to the log
    static let unexpectedError = String(localized: "An unexpected error occurred.")

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

    // MARK: Other

    static let ok = String(localized: "OK")
    static let cancel = String(localized: "Cancel")
    static let close = String(localized: "Close")
    static let save = String(localized: "Save")
    static let edit = String(localized: "Edit")
    static let delete = String(localized: "Delete")
    static let areYouSure = String(localized: "Are you sure?")
    static let name = String(localized: "Name")
    static let accept = String(localized: "Accept")
    static let descriptionString = String(localized: "Description")
    static let emailIsRequired = String(localized: "Email is required.")
    static let emailIsInvalid = String(localized: "Email is invalid.")
    static let passwordIsRequired = String(localized: "Password is required.")
    static let passwordIsInvalid = String(localized: "Password is invalid.")
    static let complete = String(localized: "Complete")
    static let forceSignOut = String(localized: "Force Sign Out?")
    static let signOut = String(localized: "Sign Out")
    static let noConnection = String(localized: "No Connection")
    static let checkInternetConnection = String(localized: "Please check internet connection and try again.")
    static let privacyPolicyUpdated = String(localized: "Privacy Policy Updated")
    static let termsOfUseUpdated = String(localized: "Terms of Use Updated")
    static let backToStartScreen = String(localized: "Back to Start Screen")
    static let fullName = String(localized: "Full Name")
    static let fullNameIsRequired = String(localized: "Full name is required.")
    static let idle = String(localized: "Idle")
}

extension TimeInterval {
    // MARK: Message Banner

    static let autoDismissTime: Self = 3
}
