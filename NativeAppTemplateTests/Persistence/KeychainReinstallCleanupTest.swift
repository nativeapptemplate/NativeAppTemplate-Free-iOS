//
//  KeychainReinstallCleanupTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Security
import Testing

/// iOS deletes an app's UserDefaults and container files on uninstall but keeps its
/// Keychain items, so without this cleanup a reinstalled app restores the previous
/// install's session. Each test uses its own UserDefaults suite and keychain service,
/// so it never touches the app's real session.
@Suite(.serialized)
struct KeychainReinstallCleanupTest {
    private let defaults: UserDefaults
    private let suiteName = "KeychainReinstallCleanupTest-\(UUID().uuidString)"
    private let items = [
        KeychainReinstallCleanup.Item(
            service: "com.nativeapptemplate.NativeAppTemplateFree.KeychainReinstallCleanupTestService",
            account: "SessionAccount"
        ),
        KeychainReinstallCleanup.Item(
            service: "com.nativeapptemplate.NativeAppTemplateFree.KeychainReinstallCleanupTestService",
            account: "OtherAccount"
        )
    ]

    init() throws {
        defaults = try #require(UserDefaults(suiteName: suiteName))
        for item in items {
            KeychainOracle.delete(service: item.service, account: item.account)
            #expect(KeychainOracle
                .add(Data("stale".utf8), service: item.service, account: item.account) == errSecSuccess)
        }
    }

    private func cleanUp() {
        for item in items {
            KeychainOracle.delete(service: item.service, account: item.account)
        }
        defaults.removePersistentDomain(forName: suiteName)
    }

    private func remainingItemCount() -> Int {
        items.reduce(0) { $0 + KeychainOracle.count(service: $1.service, account: $1.account) }
    }

    /// Reinstall: no marker in UserDefaults and no TipKit datastore from an earlier
    /// launch, while the Keychain still holds the previous install's items.
    @Test
    func reinstallDeletesKeychainItems() {
        defer { cleanUp() }

        KeychainReinstallCleanup.run(defaults: defaults, items: items, earlierVersionLaunched: { false })

        #expect(remainingItemCount() == 0)
        #expect(defaults.string(forKey: KeychainReinstallCleanup.markerKey) == KeychainReinstallCleanup.doneValue)
    }

    /// Upgrade from a version without the marker: every earlier version created the
    /// TipKit datastore on launch, so its presence means the same install, and the
    /// session must survive.
    @Test
    func upgradeKeepsKeychainItems() {
        defer { cleanUp() }

        KeychainReinstallCleanup.run(defaults: defaults, items: items, earlierVersionLaunched: { true })

        #expect(remainingItemCount() == items.count)
        #expect(defaults.string(forKey: KeychainReinstallCleanup.markerKey) == KeychainReinstallCleanup.doneValue)
    }

    /// After the first launch (marker set), a sign-in made in this install must
    /// survive later launches, even though TipKit's datastore did not exist yet.
    @Test
    func laterLaunchKeepsKeychainItems() {
        defer { cleanUp() }
        defaults.set(KeychainReinstallCleanup.doneValue, forKey: KeychainReinstallCleanup.markerKey)

        KeychainReinstallCleanup.run(defaults: defaults, items: items, earlierVersionLaunched: { false })

        #expect(remainingItemCount() == items.count)
    }

    /// If deleting fails (e.g. the device is still locked), the next launch retries,
    /// even though Tips.configure() has created its datastore by then.
    @Test
    func failedDeletionIsRetriedOnNextLaunch() {
        defer { cleanUp() }

        KeychainReinstallCleanup.run(
            defaults: defaults,
            items: items,
            earlierVersionLaunched: { false },
            remove: { _ in throw NSError(domain: NSOSStatusErrorDomain, code: Int(errSecInteractionNotAllowed)) }
        )
        #expect(remainingItemCount() == items.count)
        #expect(defaults.string(forKey: KeychainReinstallCleanup.markerKey) == KeychainReinstallCleanup.pendingValue)

        KeychainReinstallCleanup.run(defaults: defaults, items: items, earlierVersionLaunched: { true })

        #expect(remainingItemCount() == 0)
        #expect(defaults.string(forKey: KeychainReinstallCleanup.markerKey) == KeychainReinstallCleanup.doneValue)
    }

    /// Every keychain item the app writes must be in the list it clears on reinstall:
    /// the signed-in session (LoggedInShopkeeperKeychainStore) is the only one.
    @Test
    func appItemsCoverEveryKeychainItemTheAppWrites() {
        let session = LoggedInShopkeeperKeychainStore()

        #expect(KeychainReinstallCleanup.appItems == [
            KeychainReinstallCleanup.Item(service: session.service, account: session.account)
        ])
    }
}
