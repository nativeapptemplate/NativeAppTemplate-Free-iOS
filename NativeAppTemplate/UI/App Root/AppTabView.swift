//
//  AppTabView.swift
//  NativeAppTemplate
//

import SwiftUI

/// One tab of `AppTabView`: where it is in `MainTab`, its label and its screen. Adding a
/// tab is adding one of these to `MainView.tabs` (and its case to `MainTab`).
struct AppTab {
    let tab: MainTab
    let title: String
    let systemImage: String
    /// The tab's navigation path is kept, so it can go back to its root when the session
    /// or the organization changes
    let keepsNavigationPath: Bool
    let content: () -> AnyView

    init(
        _ tab: MainTab,
        title: String,
        systemImage: String,
        keepsNavigationPath: Bool = false,
        @ViewBuilder content: @escaping () -> some View
    ) {
        self.tab = tab
        self.title = title
        self.systemImage = systemImage
        self.keepsNavigationPath = keepsNavigationPath
        self.content = { AnyView(content()) }
    }
}

/// What the tabs show besides their screens
enum AppTabCover: Equatable {
    /// The screens
    case uncovered
    /// The screens stay, with `OfflineView` over them: replacing a screen closed the sheet it
    /// had open, with what was typed in it
    case offline
    /// `LoadingView` instead of the screens, while the repositories are rebuilt
    case loading
    /// `NeedAppUpdatesView` instead of the screens
    case needsAppUpdate

    /// The screens stay underneath
    var keepsScreens: Bool {
        switch self {
        case .uncovered, .offline:
            true
        case .loading, .needsAppUpdate:
            false
        }
    }
}

struct AppTabView {
    @Environment(\.sessionController) private var sessionController: SessionControllerProtocol
    @Environment(TabViewModel.self) private var model
    @State private var navigationPaths: [MainTab: NavigationPath] = [:]
    private let tabs: [AppTab]
    private let cover: AppTabCover

    init(tabs: [AppTab], cover: AppTabCover = .uncovered) {
        self.tabs = tabs
        self.cover = cover
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
                ForEach(tabs, id: \.tab) { appTab in
                    navigationStack(appTab)
                        // Before the overlay: applied after it, it would replace the message's labels
                        .accessibility(label: .init(appTab.title))
                        // Inside the tab, so the bar sits above the tab bar instead of covering it
                        .overlay(alignment: .bottom) {
                            TabMessageBarView()
                        }
                        .tabItem {
                            Text(appTab.title)
                            Image(systemName: appTab.systemImage)
                        }
                        .tag(appTab.tab)
                        .environment(\.mainTab, appTab.tab)
                }
            }
        }
        .tint(.accent)
        .onChange(of: sessionController.client) {
            navigationPaths = [:]
        }
        .onChange(of: sessionController.shouldPopToRootView) {
            if sessionController.shouldPopToRootView {
                navigationPaths = [:]
                sessionController.shouldPopToRootView = false
            }
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView(tabs: [
            AppTab(.shops, title: "SHOPS", systemImage: "storefront.fill") { Text(verbatim: "SHOPS") },
            AppTab(.settings, title: "SETTINGS", systemImage: "gearshape.fill") { Text(verbatim: "SETTINGS") }
        ])
        .environment(TabViewModel())
        .environment(MessageBus())
    }
}

// MARK: - private

/// MainActor like the View conformance: Xcode 26 does not infer it for this extension
@MainActor
private extension AppTabView {
    @ViewBuilder
    func navigationStack(_ appTab: AppTab) -> some View {
        if appTab.keepsNavigationPath {
            NavigationStack(path: navigationPath(appTab.tab)) {
                root(appTab)
            }
        } else {
            NavigationStack {
                root(appTab)
            }
        }
    }

    /// The screen is the same view whether covered or not, so going offline and back keeps it
    /// (and the sheet it has open)
    @ViewBuilder
    func root(_ appTab: AppTab) -> some View {
        if cover.keepsScreens {
            appTab.content()
                .accessibilityHidden(cover != .uncovered)
                .overlay {
                    if cover == .offline {
                        OfflineView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.backgroundColor)
                    }
                }
        } else if cover == .loading {
            LoadingView()
        } else {
            NeedAppUpdatesView()
        }
    }

    func navigationPath(_ tab: MainTab) -> Binding<NavigationPath> {
        Binding(
            get: { navigationPaths[tab] ?? NavigationPath() },
            set: { navigationPaths[tab] = $0 }
        )
    }
}

/// The app's message bar, in a tab
private struct TabMessageBarView: View {
    @Environment(MessageBus.self) private var messageBus

    var body: some View {
        MessageBarView(messageBus: messageBus)
    }
}
