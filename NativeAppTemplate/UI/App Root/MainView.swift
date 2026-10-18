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
                .overlay(alignment: .bottom) {
                    if !content.hasTabBar {
                        MessageBarView(messageBus: messageBus)
                    }
                }
                .alert(Strings.sessionExpired, isPresented: sessionExpiredAlertBinding) {
                    Button(Strings.ok) {}
                } message: {
                    Text(Strings.sessionExpiredDescription)
                }
                .onChange(of: sessionController.didExpireSession) {
                    // The alert says why; the failed request's own error would only
                    // repeat it as a status code
                    if sessionController.didExpireSession {
                        messageBus.dismiss()
                    }
                }
                .onAppear {
                    if viewModel == nil {
                        viewModel = MainViewModel(
                            sessionController: sessionController,
                            messageBus: messageBus
                        )
                    }
                }
        }
    }
}

// MARK: - private

private extension MainView {
    var sessionExpiredAlertBinding: Binding<Bool> {
        Binding(
            get: { sessionController.didExpireSession },
            set: { sessionController.didExpireSession = $0 }
        )
    }

    var content: MainContent {
        MainViewModel.content(
            sessionController: sessionController,
            isRebuildingRepositories: dataManager.isRebuildingRepositories
        )
    }

    @ViewBuilder var contentView: some View {
        switch content {
        case .onboarding:
            OnboardingView()
        case .acceptPrivacy:
            acceptPrivacySheet
        case .acceptTerms:
            acceptTermsSheet
        case .permissionsLoading:
            PermissionsLoadingView()
        case .permissionsError:
            ErrorView(
                buttonAction: { viewModel?.logout() },
                buttonTitle: Strings.backToStartScreen
            )
        case .sessionLoading:
            LoadingView()
        case .offline:
            AppTabView(
                shopListView: OfflineView.init,
                settingsView: OfflineView.init
            )
            .environment(tabViewModel)
        case .rebuildingRepositories:
            AppTabView(
                shopListView: LoadingView.init,
                settingsView: LoadingView.init
            )
            .environment(tabViewModel)
        case .needsAppUpdate:
            AppTabView(
                shopListView: { NeedAppUpdatesView() },
                settingsView: { NeedAppUpdatesView() }
            )
            .environment(tabViewModel)
        case .tabs:
            AppTabView(
                shopListView: shopListView,
                settingsView: settingsView
            )
            .environment(tabViewModel)
        }
    }

    var acceptPrivacySheet: some View {
        NavigationStack {
            AcceptPrivacyView(
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
                viewModel: AcceptTermsViewModel(
                    sessionController: sessionController,
                    messageBus: messageBus
                )
            )
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
