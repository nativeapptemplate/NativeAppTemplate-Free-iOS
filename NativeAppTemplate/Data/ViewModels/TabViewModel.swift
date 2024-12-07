//
//  TabViewModel.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import SwiftUI

@Observable class TabViewModel {
  var selectedTab: MainTab = .shops

  var showingDetailView = Dictionary(
    uniqueKeysWithValues: zip(MainTab.allCases, AnyIterator { false })
  )
}

extension MainTab: EnvironmentKey {
  static var defaultValue: Self { .shops }
}

extension EnvironmentValues {
  var mainTab: MainTab {
    get { self[MainTab.self] }
    set { self[MainTab.self] = newValue }
  }
}
