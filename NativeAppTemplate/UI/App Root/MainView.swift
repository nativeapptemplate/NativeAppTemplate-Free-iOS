// Copyright (c) 2019 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SwiftUI

struct MainView: View {
  @Environment(MessageBus.self) private var messageBus
  @Environment(DataManager.self) private var dataManager
  @Environment(SessionController.self) private var sessionController
  @State var isShowingForceAppUpdatesAlert = false
  @State var isResetting = false
  @State private var isShowingAcceptPrivacySheet = false
  @State private var arePrivacyAccepted = false
  @State private var isShowingAcceptTermsSheet = false
  @State private var areTermsAccepted = false
  
  private let tabViewModel = TabViewModel()
  
  var body: some View {
    ZStack {
      contentView
        .background(Color.backgroundColor)
        .overlay(MessageBarView(messageBus: messageBus), alignment: .bottom)
        .onChange(of: sessionController.shouldUpdatePrivacy) {
          if sessionController.shouldUpdatePrivacy {
            isShowingAcceptPrivacySheet = true
          }
        }
        .onChange(of: sessionController.shouldUpdateTerms) {
          if sessionController.shouldUpdateTerms {
            isShowingAcceptTermsSheet = true
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
    } else {
      switch sessionController.permissionState {
      case .loaded:
        tabBarView
      case .notLoaded, .loading:
        PermissionsLoadingView()
      case .error:
        ErrorView(
          buttonAction: logout,
          buttonTitle: .backToStartScreen
        )
      }
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
          .sheet(isPresented: $isShowingAcceptPrivacySheet) {
            NavigationStack {
              AcceptPrivacyView(arePrivacyAccepted: $arePrivacyAccepted)
                .interactiveDismissDisabled(!arePrivacyAccepted)
            }
          }
          .sheet(isPresented: $isShowingAcceptTermsSheet) {
            NavigationStack {
              AcceptTermsView(areTermsAccepted: $areTermsAccepted)
                .interactiveDismissDisabled(!areTermsAccepted)
            }
          }
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
      shopRepository: dataManager.shopRepository
    )
  }
  
  func settingsView() -> SettingsView {
    .init(accountPasswordRepository: dataManager.accountPasswordRepository)
  }
  
  func logout() {
    Task {
      try await sessionController.logout()
    }
  }
}
