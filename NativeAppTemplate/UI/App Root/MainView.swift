//
//  MainView.swift
//  NativeAppTemplate
//

import SwiftUI

struct MainView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.sessionController) private var sessionController: SessionControllerProtocol
    @Environment(MessageBus.self) private var messageBus
    @Environment(\.mainTab) private var mainTab
    @State private var viewModel: MainViewModel?

    private let tabViewModel = TabViewModel()

    var body: some View {
        ZStack {
            contentView
                .background(Color.backgroundColor)
                .overlay(MessageBarView(messageBus: messageBus), alignment: .bottom)
                .onAppear {
                    if viewModel == nil {
                        viewModel = MainViewModel(
                            sessionController: sessionController,
                            dataManager: dataManager,
                            messageBus: messageBus,
                            tabViewModel: tabViewModel
                        )
                    }
                }
        }
    }
}

// MARK: - private

private extension MainView {
    @ViewBuilder var contentView: some View {
        if !sessionController.isLoggedIn {
            OnboardingView()
        } else if sessionController.shouldUpdatePrivacy {
            acceptPrivacySheet
        } else if sessionController.shouldUpdateTerms {
            acceptTermsSheet
        } else {
            switch sessionController.permissionState {
            case .loaded:
                tabBarView
            case .notLoaded, .loading:
                PermissionsLoadingView()
            case .error:
                ErrorView(
                    buttonAction: { viewModel?.logout() },
                    buttonTitle: Strings.backToStartScreen
                )
            }
        }
    }

    var acceptPrivacySheet: some View {
        NavigationStack {
            AcceptPrivacyView(
                arePrivacyAccepted: Binding(
                    get: { viewModel?.arePrivacyAccepted ?? false },
                    set: { viewModel?.arePrivacyAccepted = $0 }
                ),
                viewModel: AcceptPrivacyViewModel(
                    sessionController: sessionController,
                    messageBus: messageBus
                )
            )
        }
    }

    var acceptTermsSheet: some View {
        NavigationStack {
            AcceptTermsView(
                areTermsAccepted: Binding(
                    get: { viewModel?.areTermsAccepted ?? false },
                    set: { viewModel?.areTermsAccepted = $0 }
                ),
                viewModel: AcceptTermsViewModel(
                    sessionController: sessionController,
                    messageBus: messageBus
                )
            )
        }
    }

    @ViewBuilder var tabBarView: some View {
        switch sessionController.sessionState {
        case .online:
            if dataManager.isRebuildingRepositories {
                AppTabView(
                    shopListView: LoadingView.init,
                    settingsView: LoadingView.init
                )
                .environment(tabViewModel)
            } else {
                if sessionController.shouldUpdateApp {
                    AppTabView(
                        shopListView: NeedAppUpdatesView.init,
                        settingsView: NeedAppUpdatesView.init
                    )
                    .environment(tabViewModel)
                } else {
                    AppTabView(
                        shopListView: shopListView,
                        settingsView: settingsView
                    )
                    .environment(tabViewModel)
                }
            }
        case .offline:
            AppTabView(
                shopListView: OfflineView.init,
                settingsView: OfflineView.init
            )
            .environment(tabViewModel)
        case .unknown:
            LoadingView()
        }
    }

    func shopListView() -> ShopListView {
        .init(
            viewModel: ShopListViewModel(
                sessionController: dataManager.sessionController,
                shopRepository: dataManager.shopRepository,
                tabViewModel: tabViewModel,
                mainTab: mainTab
            )
        )
    }

    func settingsView() -> SettingsView {
        .init(
            viewModel: SettingsViewModel(
                sessionController: dataManager.sessionController,
                tabViewModel: tabViewModel,
                messageBus: messageBus
            )
        )
    }
}
