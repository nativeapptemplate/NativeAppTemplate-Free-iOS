//
//  TabViewModel.swift
//  NativeAppTemplate
//

import SwiftUI

@Observable class TabViewModel {
    var selectedTab: MainTab = .shops

    var showingDetailView = Dictionary(
        uniqueKeysWithValues: zip(MainTab.allCases, AnyIterator { false })
    )
}

extension MainTab: EnvironmentKey {
    static var defaultValue: Self {
        .shops
    }
}

extension EnvironmentValues {
    var mainTab: MainTab {
        get { self[MainTab.self] }
        set { self[MainTab.self] = newValue }
    }
}
