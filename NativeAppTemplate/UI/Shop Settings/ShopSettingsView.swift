//
//  ShopSettingsView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/12.
//

import SwiftUI

struct ShopSettingsView: View {
  @Environment(DataManager.self) private var dataManager
  @Environment(\.dismiss) private var dismiss
  @Environment(MessageBus.self) private var messageBus
  @State private var viewModel: ShopSettingsViewModel
  
  init(viewModel: ShopSettingsViewModel) {
    self.viewModel = viewModel
  }
}

// MARK: - View
extension ShopSettingsView {
  var body: some View {
    contentView
      .onChange(of: viewModel.shouldDismiss) {
        if viewModel.shouldDismiss {
          dismiss()
        }
      }
      .task {
        reload()
      }
  }
}

// MARK: - private
private extension ShopSettingsView {
  var contentView: some View {
    @ViewBuilder var contentView: some View {
      if viewModel.isBusy {
        LoadingView()
      } else if let shop = viewModel.shop {
        shopSettingsView(shop: shop)
      }
    }
    
    return contentView
  }
  
  func shopSettingsView(shop: Shop) -> some View { // swiftlint:disable:this function_body_length
    VStack {
      Text(shop.name)
        .font(.uiTitle1)
        .foregroundStyle(.titleText)
        .padding(.top, 24)
      
      List {
        Section {
          NavigationLink {
            ShopBasicSettingsView(
              viewModel: ShopBasicSettingsViewModel(
                sessionController: dataManager.sessionController,
                shopRepository: dataManager.shopRepository,
                messageBus: messageBus,
                shopId: viewModel.shopId
              )
            )
          } label: {
            Label(String.shopSettingsBasicSettingsLabel, systemImage: "storefront")
          }
          .listRowBackground(Color.cardBackground)
        }
        
        Section {
          NavigationLink {
            ItemTagListView(
              viewModel: ItemTagListViewModel(
                itemTagRepository: dataManager.itemTagRepository,
                messageBus: messageBus,
                sessionController: dataManager.sessionController,
                shop: shop
              )
            )
          } label: {
            Label(String.shopSettingsManageNumberTagsLabel, systemImage: "rectangle.stack")
          }
          .listRowBackground(Color.cardBackground)
        }
        
        Section {
          NavigationLink {
            NumberTagsWebpageListView(
              viewModel: NumberTagsWebpageListViewModel(
                shop: shop,
                messageBus: messageBus
              )
            )
          } label: {
            Label(String.shopSettingsNumberTagsWebpageLabel, systemImage: "globe")
          }
        }
        .listRowBackground(Color.cardBackground)
        
        Section {
          VStack(spacing: 8) {
            MainButtonView(title: String.resetNumberTags, type: .destructive(withArrow: false)) {
              viewModel.isShowingResetConfirmationDialog = true
            }
            .listRowBackground(Color.clear)
            Text(String.resetNumberTagsDescription)
              .font(.uiFootnote)
              .foregroundStyle(.contentText)
              .listRowBackground(Color.clear)
          }
          .listRowBackground(Color.clear)
          
          MainButtonView(title: String.deleteShop, type: .destructive(withArrow: false)) {
            viewModel.isShowingDeleteConfirmationDialog = true
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
      isPresented: $viewModel.isShowingResetConfirmationDialog
    ) {
      Button(String.resetNumberTags, role: .destructive) {
        viewModel.resetShop()
      }
      Button(String.cancel, role: .cancel) {
        viewModel.isShowingResetConfirmationDialog = false
      }
    } message: {
      Text(String.areYouSure)
    }
    .confirmationDialog(
      String.deleteShop,
      isPresented: $viewModel.isShowingDeleteConfirmationDialog
    ) {
      Button(String.deleteShop, role: .destructive) {
        viewModel.destroyShop()
      }
      Button(String.cancel, role: .cancel) {
        viewModel.isShowingDeleteConfirmationDialog = false
      }
    } message: {
      Text(String.areYouSure)
    }
  }
  
  func reload() {
    viewModel.reload()
  }
}
