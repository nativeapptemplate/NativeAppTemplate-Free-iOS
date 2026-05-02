//
//  AppTabView.swift
//  NativeAppTemplate
//

import SwiftUI

struct AppTabView<
    ShopListView: View,
    SettingsView: View
> {
    @Environment(\.sessionController) private var sessionController
    @Environment(DataManager.self) private var dataManager
    @Environment(TabViewModel.self) private var model
    @State var navigationPathShops = NavigationPath()
    private let shopListView: () -> ShopListView
    private let settingsView: () -> SettingsView

    init(
        shopListView: @escaping () -> ShopListView,
        settingsView: @escaping () -> SettingsView
    ) {
        self.shopListView = shopListView
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
                    text: Strings.shops,
                    imageName: "storefront.fill",
                    tab: .shops
                )

                tab(
                    content: settingsView,
                    navigationPath: nil,
                    text: Strings.settings,
                    imageName: "gearshape.fill",
                    tab: .settings
                )
            }
        }
        .tint(.accent)
        .onChange(of: sessionController.client) {
            navigationPathShops = NavigationPath()
        }
        .onChange(of: sessionController.shouldPopToRootView) {
            if sessionController.shouldPopToRootView {
                navigationPathShops = NavigationPath()
                sessionController.shouldPopToRootView = false
            }
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView(
            shopListView: { Text(verbatim: "SHOPS") },
            settingsView: { Text(verbatim: "SETTINGS") }
        ).environment(TabViewModel())
    }
}

// MARK: - private

@MainActor private func tab(
    content: @escaping () -> some View,
    navigationPath: Binding<NavigationPath>?,
    text: String,
    imageName: String,
    tab: MainTab
) -> some View {
    if let navigationPath {
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
