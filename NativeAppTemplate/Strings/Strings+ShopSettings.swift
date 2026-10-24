//
//  Strings+ShopSettings.swift
//  NativeAppTemplate
//

import Foundation

extension Strings {
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
}
