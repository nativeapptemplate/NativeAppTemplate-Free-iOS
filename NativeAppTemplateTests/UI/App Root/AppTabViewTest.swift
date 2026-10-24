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

    /// The labels once every one of `expected` is there (a slow machine publishes the tab bar late)
    private func labels(cover: AppTabCover, expected: [String]) throws -> [String] {
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
        return try AccessibilityElements.of(view) { elements in
            expected.allSatisfy { label in elements.contains { $0.label == label } }
        }
        .map(\.label)
    }

    /// The tabs come from [AppTab]: the selected one (TabViewModel starts on .shops) shows its
    /// screen. The tab bar's own labels are UIKit's and reach the accessibility tree differently
    /// on each iOS version (CI's Xcode 26.6 simulator did not list them), so they are not checked
    @Test
    func theSelectedTabShowsItsScreen() throws {
        let labels = try labels(cover: .uncovered, expected: [screenText])

        #expect(labels.contains(screenText))
        #expect(!labels.contains("Second"))
    }

    /// Offline, OfflineView covers the screen, which stays underneath out of VoiceOver's reach
    @Test
    func offlineCoversTheScreen() throws {
        let labels = try labels(cover: .offline, expected: [Strings.noConnection])

        #expect(labels.contains(Strings.noConnection))
        #expect(!labels.contains(screenText))
    }

    @Test
    func needingAnUpdateReplacesTheScreen() throws {
        let labels = try labels(cover: .needsAppUpdate, expected: [Strings.updateApp])

        #expect(labels.contains(Strings.updateApp))
        #expect(!labels.contains(screenText))
    }
}
