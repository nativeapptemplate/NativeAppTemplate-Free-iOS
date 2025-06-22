//
//  TabView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/05/04.
//

import SwiftUI

struct AppTabView<
  ShopListView: View,
  ScanView: View,
  SettingsView: View
> {
  
  @Environment(\.sessionController) private var sessionController
  @Environment(DataManager.self) private var dataManager
  @Environment(TabViewModel.self) private var model
  @State var navigationPathShops = NavigationPath()
  @State var navigationPathStats = NavigationPath()
  private let shopListView: () -> ShopListView
  private let scanView: () -> ScanView
  private let settingsView: () -> SettingsView

  init(
    shopListView: @escaping () -> ShopListView,
    scanView: @escaping () -> ScanView,
    settingsView: @escaping () -> SettingsView
  ) {
    self.shopListView = shopListView
    self.scanView = scanView
    self.settingsView = settingsView
  }
}

// MARK: - View
extension AppTabView: View {
  var body: some View {
    ScrollViewReader { proxy in
      TabView(
        selection: .init(
          get: { model.selectedTab },
          set: { selection in
            switch model.selectedTab {
            case selection:
              withAnimation {
                proxy.scrollTo(
                  ScrollToTopID(
                    mainTab: selection, detail: model.showingDetailView[selection]!
                  ),
                  anchor: .top
                )
              }
            default:
              model.selectedTab = selection
            }
          }
        )
      ) {
        tab(
          content: shopListView,
          navigationPath: $navigationPathShops,
          text: .shops,
          imageName: "storefront.fill",
          tab: .shops
        )
 
        tab(
          content: scanView,
          navigationPath: nil,
          text: .scan,
          imageName: "platter.filled.bottom.iphone",
          tab: .scan
        )

        tab(
          content: settingsView,
          navigationPath: nil,
          text: .settings,
          imageName: "gearshape.fill",
          tab: .settings
        )
      }
    }
    .tint(.accent)
    .onChange(of: sessionController.client) {
      navigationPathShops = NavigationPath()
      navigationPathStats = NavigationPath()
    }
    .onChange(of: sessionController.shouldPopToRootView) {
      if sessionController.shouldPopToRootView {
        navigationPathShops = NavigationPath()
        navigationPathStats = NavigationPath()
        sessionController.shouldPopToRootView = false
      }
    }
  }
}

struct AppTabView_Previews: PreviewProvider {
  static var previews: some View {
    AppTabView(
      shopListView: { Text(verbatim: "SHOPS") },
      scanView: { Text(verbatim: "SCAN") },
      settingsView: { Text(verbatim: "SETTINGS") }
    ).environment(TabViewModel())
  }
}

// MARK: - private
@MainActor private func tab<Content: View>(
  content: @escaping () -> Content,
  navigationPath: Binding<NavigationPath>?,
  text: String,
  imageName: String,
  tab: MainTab
) -> some View {
  if let navigationPath = navigationPath {
    NavigationStack(path: navigationPath, root: content)
      .tabItem {
        Text(text)
        Image(systemName: imageName)
      }
      .tag(tab)
      .environment(\.mainTab, tab)
      .accessibility(label: .init(text))
  } else {
    NavigationStack(root: content)
      .tabItem {
        Text(text)
        Image(systemName: imageName)
      }
      .tag(tab)
      .environment(\.mainTab, tab)
      .accessibility(label: .init(text))
  }
}
