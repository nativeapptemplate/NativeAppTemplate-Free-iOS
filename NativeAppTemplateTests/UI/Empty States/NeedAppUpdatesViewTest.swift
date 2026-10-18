//
//  NeedAppUpdatesViewTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import SwiftUI
import Testing

/// The forced-update screen's Update App button opens the app's App Store page, which comes
/// from APP_STORE_ID (AppStore.xcconfig). It used to open a hardcoded page of another app
/// (MyTurnTag Creator, id1516198303), so every app built from the template sent its users there.
@MainActor
struct NeedAppUpdatesViewTest {
    // MARK: - App Store page

    /// Empty (as committed) or not an Apple ID: no page, so the button is hidden rather than
    /// opening someone else's page
    @Test(arguments: ["", " ", "id1234567890", "https://apps.apple.com/app/id1234567890", "12a4"])
    func noAppleIdHasNoAppStorePage(appStoreId: String) {
        #expect(Strings.appStorePage(appStoreId: appStoreId) == nil)
    }

    /// Apple's short App Store URL form is https://apps.apple.com/app/id<Apple ID>
    @Test
    func appleIdOpensItsAppStorePage() {
        #expect(
            Strings.appStorePage(appStoreId: "1234567890")
                == URL(string: "https://apps.apple.com/app/id1234567890")
        )
    }

    // MARK: - Update App button

    private func updateAppButtons(appStoreUrl: URL?) throws -> [AccessibilityElements.Element] {
        try AccessibilityElements.of(NeedAppUpdatesView(appStoreUrl: appStoreUrl))
            .filter { $0.traits.contains(.button) }
    }

    @Test
    func appStorePageShowsTheUpdateAppButton() throws {
        let buttons = try updateAppButtons(appStoreUrl: URL(string: "https://apps.apple.com/app/id1234567890"))

        #expect(buttons.map(\.label) == ["Update App"]) // Strings.updateApp; the tests run in English
    }

    /// Without a page there is no button, but the screen still says what to do
    @Test
    func noAppStorePageHidesTheUpdateAppButton() throws {
        #expect(try updateAppButtons(appStoreUrl: nil).isEmpty)

        let labels = try AccessibilityElements.of(NeedAppUpdatesView(appStoreUrl: nil)).map(\.label)
        #expect(labels.contains("Please install new version app."))
    }
}
