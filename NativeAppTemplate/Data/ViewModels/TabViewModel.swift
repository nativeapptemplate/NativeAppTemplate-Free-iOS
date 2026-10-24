//
//  TabViewModel.swift
//  NativeAppTemplate
//

import SwiftUI

@Observable class TabViewModel {
    var selectedTab: MainTab = .initial

    var showingDetailView = Dictionary(
        uniqueKeysWithValues: zip(MainTab.allCases, AnyIterator { false })
    )
}

extension MainTab: EnvironmentKey {
    /// The tab the app opens on, set only here: `TabViewModel` starts on it and views
    /// outside a tab read it as the environment default
    static let initial: MainTab = .shops

    static var defaultValue: Self {
        initial
    }
}

extension EnvironmentValues {
    var mainTab: MainTab {
        get { self[MainTab.self] }
        set { self[MainTab.self] = newValue }
    }
}
