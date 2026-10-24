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

/// The app's text. Each screen's strings are in an extension in `Strings/`
/// (`Strings+Shops.swift` and so on), so a new screen adds a file instead of
/// growing this one past SwiftLint's type and file length limits
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
