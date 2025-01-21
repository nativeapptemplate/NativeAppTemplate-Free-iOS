//
//  ShopSettingsView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/12.
//

import SwiftUI

struct ShopSettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(MessageBus.self) private var messageBus
  @Environment(SessionController.self) private var sessionController
  @State private var isFetching = true
  @State private var isDeleting = false
  @State private var isShowingDeleteConfirmationDialog = false
  private let shopRepository: ShopRepository
  private var shopId: String
  
  private var shop: Binding<Shop> {
    Binding {
      shopRepository.findBy(id: shopId)
    } set: { _ in
    }
  }
  
  init(
    shopRepository: ShopRepository,
    shopId: String
  ) {
    self.shopRepository = shopRepository
    self.shopId = shopId
  }
}

// MARK: - View
extension ShopSettingsView {
  var body: some View {
    contentView
      .task {
        reload()
      }
  }
}

// MARK: - private
private extension ShopSettingsView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if isFetching || isDeleting {
        LoadingView()
      } else {
        shopSettingsView
      }
    }
    
    return contentView
  }
  
  var shopSettingsView: some View {
    VStack {
      Text(shop.wrappedValue.name)
        .font(.uiTitle1)
        .foregroundStyle(.titleText)
        .padding(.top, 24)
      
      List {
        Section {
          NavigationLink {
            ShopBasicSettingsView(shopRepository: shopRepository, shopId: shop.id)
          } label: {
            Label(String.shopSettingsBasicSettingsLabel, systemImage: "storefront")
          }
          .listRowBackground(Color.cardBackground)
        }
        
        Section {
          MainButtonView(title: String.deleteShop, type: .destructive(withArrow: false)) {
            isShowingDeleteConfirmationDialog = true
          }
          .listRowBackground(Color.clear)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.top)
      }
      .refreshable {
        reload()
      }
    }
    .navigationTitle(String.shopSettingsLabel)
    .confirmationDialog(
      String.deleteShop,
      isPresented: $isShowingDeleteConfirmationDialog
    ) {
      Button(String.deleteShop, role: .destructive) {
        destroyShop()
      }
      Button(String.cancel, role: .cancel) {
        isShowingDeleteConfirmationDialog = false
      }
    } message: {
      Text(String.areYouSure)
    }
  }
  
  func reload() {
    fetchShopDetail()
  }
  
  private func fetchShopDetail() {
    Task { @MainActor in
      isFetching = true

      do {
        _ = try await shopRepository.fetchDetail(id: shopId)
        isFetching = false
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
        isFetching = false
        dismiss()
      }
    }
  }
  
  private func destroyShop () {
    Task { @MainActor in
      isDeleting = true

      do {
        try await shopRepository.destroy(id: shop.id)
        messageBus.post(message: Message(level: .success, message: .shopDeleted))
        sessionController.shouldPopToRootView = true
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.shopDeletedError) \(error.localizedDescription)", autoDismiss: false))
        try await sessionController.logout()
      }
    }
  }
}
