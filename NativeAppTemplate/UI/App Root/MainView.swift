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
  @Environment(\.sessionController) private var sessionController
  @State var isShowingForceAppUpdatesAlert = false
  @State var itemTagId: String?
  @State var isResetting = false
  @State var isShowingResetConfirmationDialog = false
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
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleBackgroundTagReading)
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
        .confirmationDialog(
          String.itemTagAlreadyCompleted,
          isPresented: $isShowingResetConfirmationDialog
        ) {
          Button(String.reset, role: .destructive) {
            resetTag(itemTagId: itemTagId!)
          }
          Button(String.cancel, role: .cancel) {
            isShowingResetConfirmationDialog = false
          }
        } message: {
          Text(String.areYouSure)
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
          scanView: LoadingView.init,
          settingsView: LoadingView.init
        )
        .environment(tabViewModel)
      } else {
        if sessionController.shouldUpdateApp {
          AppTabView(
            shopListView: NeedAppUpdatesView.init,
            scanView: NeedAppUpdatesView.init,
            settingsView: NeedAppUpdatesView.init
          )
          .environment(tabViewModel)
        } else {
          AppTabView(
            shopListView: shopListView,
            scanView: scanView,
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
        scanView: OfflineView.init,
        settingsView: OfflineView.init
      )
      .environment(tabViewModel)
    case .unknown:
      LoadingView()
    }
  }
  
  func shopListView() -> ShopListView {
    let viewModel = ShopListViewModel(
      sessionController: sessionController,
      shopRepository: dataManager.shopRepository,
      itemTagRepository: dataManager.itemTagRepository,
      tabViewModel: tabViewModel,
      mainTab: .shops,
      messageBus: messageBus
    )
    return ShopListView(viewModel: viewModel)
  }
  
  func scanView() -> ScanView {
    .init(
      itemTagRepository: dataManager.itemTagRepository
    )
  }

  func settingsView() -> SettingsView {
    .init(accountPasswordRepository: dataManager.accountPasswordRepository)
  }

  func handleBackgroundTagReading(_ userActivity: NSUserActivity) {
    guard sessionController.isLoggedIn else {
      messageBus.post(message: Message(level: .error, message: String.pleaseSignIn, autoDismiss: false))
      return
    }
    
    let ndefMessage = userActivity.ndefMessagePayload
    guard !ndefMessage.records.isEmpty,
          ndefMessage.records[0].typeNameFormat != .empty else {
      return
    }
    
    let itemTagInfo = Utility.extractItemTagInfoFrom(message: ndefMessage)
    
    if itemTagInfo.success {
      itemTagId = itemTagInfo.id
      completeTag(itemTagId: itemTagId!)
    } else {
      messageBus.post(message: Message(level: .error, message: itemTagInfo.message, autoDismiss: false))
      tabViewModel.selectedTab = .scan
    }
  }
  
  func completeTag(itemTagId: String) {
    Task { @MainActor in
      do {
        let itemTag = try await dataManager.itemTagRepository.complete(id: itemTagId)

        sessionController.completeScanResult = CompleteScanResult(
          itemTag: itemTag,
          type: .completed
        )

        if itemTag.alreadyCompleted! {
          isShowingResetConfirmationDialog = true
        }
      } catch {
        sessionController.completeScanResult = CompleteScanResult(
          type: .failed,
          message: error.localizedDescription
        )
      }
      
      sessionController.didBackgroundTagReading = true
      tabViewModel.selectedTab = .scan
    }
  }
  
  private func resetTag(itemTagId: String) {
    Task { @MainActor in
      isResetting = true
      
      do {
        let itemTag = try await dataManager.itemTagRepository.reset(id: itemTagId)
        sessionController.completeScanResult = CompleteScanResult(
          itemTag: itemTag,
          type: .reset
        )
      } catch {
        sessionController.completeScanResult = CompleteScanResult(
          type: .failed,
          message: error.localizedDescription
        )
      }
      
      isResetting = false
      sessionController.didBackgroundTagReading = true
      tabViewModel.selectedTab = .scan
    }
  }

  func logout() {
    Task {
      try await sessionController.logout()
    }
  }
}
