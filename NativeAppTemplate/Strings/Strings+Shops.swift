//
//  Strings+Shops.swift
//  NativeAppTemplate
//

import Foundation

extension Strings {
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
}
