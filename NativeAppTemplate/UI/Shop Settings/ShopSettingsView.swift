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
  @Environment(\.sessionController) private var sessionController
  @State private var isFetching = true
  @State private var isResetting = false
  @State private var isDeleting = false
  @State private var isShowingResetConfirmationDialog = false
  @State private var isShowingDeleteConfirmationDialog = false
  private let shopRepository: ShopRepositoryProtocol
  private let itemTagRepository: ItemTagRepositoryProtocol
  private var shopId: String
  
  private var shop: Binding<Shop> {
    Binding {
      shopRepository.findBy(id: shopId)
    } set: { _ in
    }
  }
  
  init(
    shopRepository: ShopRepositoryProtocol,
    itemTagRepository: ItemTagRepositoryProtocol,
    shopId: String
  ) {
    self.shopRepository = shopRepository
    self.itemTagRepository = itemTagRepository
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
      if isFetching || isResetting || isDeleting {
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
          NavigationLink {
            ItemTagListView(
              itemTagRepository: itemTagRepository,
              shop: shop.wrappedValue
            )
          } label: {
            Label(String.shopSettingsManageNumberTagsLabel, systemImage: "rectangle.stack")
          }
          .listRowBackground(Color.cardBackground)
        }
        
        Section {
          NavigationLink {
            NumberTagsWebpageListView(shop: shop.wrappedValue)
          } label: {
            Label(String.shopSettingsNumberTagsWebpageLabel, systemImage: "globe")
          }
        }
        .listRowBackground(Color.cardBackground)
        
        Section {
          VStack(spacing: 8) {
            MainButtonView(title: String.resetNumberTags, type: .destructive(withArrow: false)) {
              isShowingResetConfirmationDialog = true
            }
            .listRowBackground(Color.clear)
            Text(String.resetNumberTagsDescription)
              .font(.uiFootnote)
              .foregroundStyle(.contentText)
              .listRowBackground(Color.clear)
          }
          .listRowBackground(Color.clear)
          
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
      String.resetNumberTags,
      isPresented: $isShowingResetConfirmationDialog
    ) {
      Button(String.resetNumberTags, role: .destructive) {
        resetShop()
      }
      Button(String.cancel, role: .cancel) {
        isShowingResetConfirmationDialog = false
      }
    } message: {
      Text(String.areYouSure)
    }
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
  
  private func resetShop () {
    Task { @MainActor in
      isResetting = true
      
      do {
        try await shopRepository.reset(id: shop.id)
        messageBus.post(message: Message(level: .success, message: .shopReset))
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.shopResetError) \(error.localizedDescription)", autoDismiss: false))
      }
      
      dismiss()
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
