//
//  KeychainReinstallCleanup.swift
//  NativeAppTemplate
//

import Foundation

/// Deletes the previous install's Keychain items on the first launch after a reinstall.
///
/// iOS removes an app's UserDefaults and container files when it is deleted but keeps
/// its Keychain items, so a reinstalled app would otherwise restore the old session
/// (token, client, uid). A UserDefaults marker tells a reinstall apart from a later launch.
///
/// Must run before anything reads the Keychain (the session is restored in `App.objects`).
enum KeychainReinstallCleanup {
    struct Item: Hashable {
        let service: String
        let account: String
    }

    /// Every Keychain item the app writes.
    static let appItems = [
        Item(service: Strings.keychainServiceLoggedInShopkeeper, account: Strings.keychainAccountLoggedInShopkeeper)
    ]

    static let markerKey = "UserDefaultsKeychainReinstallCleanup"
    static let doneValue = "done"
    /// Deleting failed on a fresh install; retry on the next launch.
    static let pendingValue = "pending"

    /// Earlier versions wrote no UserDefaults key, but every one of them called
    /// `Tips.configure()` on each launch, which creates TipKit's datastore in
    /// Application Support. That directory goes with the app on delete, so finding it
    /// without the marker means an upgrade of the same install, not a reinstall.
    /// (`App.init` runs this cleanup before `Tips.configure()`.)
    static func earlierVersionLaunched() -> Bool {
        FileManager.default.fileExists(atPath: URL.applicationSupportDirectory.appending(path: ".tipkit").path)
    }

    static func run(
        defaults: UserDefaults = .standard,
        items: [Item] = appItems,
        earlierVersionLaunched: () -> Bool = earlierVersionLaunched,
        remove: (Item) throws -> Void = { try Keychain(service: $0.service).remove($0.account) }
    ) {
        let state = defaults.string(forKey: markerKey)
        if state == doneValue {
            return
        }

        if state == nil, earlierVersionLaunched() {
            defaults.set(doneValue, forKey: markerKey)
            return
        }

        var failed = false
        for item in items {
            do {
                try remove(item)
            } catch {
                failed = true
                appLogger.debug("KeychainReinstallCleanup remove error: \(error, privacy: .private)")
            }
        }
        defaults.set(failed ? pendingValue : doneValue, forKey: markerKey)
    }
}
