//
//  AppTabViewTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import SwiftUI
import Testing

/// AppTabView builds its tabs from `[AppTab]`, and covers or replaces their screens
@MainActor
struct AppTabViewTest {
    private let screenText = "Screen of the first tab"

    private func labels(cover: AppTabCover) throws -> [String] {
        let view = AppTabView(
            tabs: [
                AppTab(.shops, title: "First Tab", systemImage: "1.circle") { Text(verbatim: screenText) },
                AppTab(.settings, title: "Second Tab", systemImage: "2.circle") { Text(verbatim: "Second") }
            ],
            cover: cover
        )
        .environment(TabViewModel())
        .environment(MessageBus())
        .environment(\.sessionController, TestSessionController())
        return try AccessibilityElements.of(view).map(\.label)
    }

    /// Each AppTab is a tab, labeled with its title: adding a tab is adding one AppTab
    @Test
    func everyTabIsInTheTabBar() throws {
        let labels = try labels(cover: .uncovered)

        #expect(labels.contains("First Tab"))
        #expect(labels.contains("Second Tab"))
        #expect(labels.contains(screenText))
    }

    /// Offline, OfflineView covers the screen, which stays underneath out of VoiceOver's reach
    @Test
    func offlineCoversTheScreen() throws {
        let labels = try labels(cover: .offline)

        #expect(labels.contains(Strings.noConnection))
        #expect(!labels.contains(screenText))
    }

    @Test
    func needingAnUpdateReplacesTheScreen() throws {
        let labels = try labels(cover: .needsAppUpdate)

        #expect(labels.contains(Strings.updateApp))
        #expect(!labels.contains(screenText))
    }
}
