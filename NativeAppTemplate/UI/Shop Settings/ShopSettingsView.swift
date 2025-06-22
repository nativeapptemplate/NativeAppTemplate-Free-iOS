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
    self._viewModel = State(wrappedValue: viewModel)
  }
}

// MARK: - View
extension ShopSettingsView {
  var body: some View {
    contentView
      .task {
        viewModel.reload()
      }
      .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
        if shouldDismiss {
          dismiss()
        }
      }
  }
}

// MARK: - private
private extension ShopSettingsView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if viewModel.isBusy {
        LoadingView()
      } else {
        shopSettingsView
      }
    }
    
    return contentView
  }
  
  var shopSettingsView: some View {
    VStack {
      if let shop = viewModel.shop {
        Text(shop.name)
          .font(.uiTitle1)
          .foregroundStyle(.titleText)
          .padding(.top, 24)
      }
      
      List {
        Section {
          NavigationLink {
            ShopBasicSettingsView(
              viewModel: viewModel.createShopBasicSettingsViewModel()
            )
          } label: {
            Label(String.shopSettingsBasicSettingsLabel, systemImage: "storefront")
          }
          .listRowBackground(Color.cardBackground)
        }
        
        Section {
          if let shop = viewModel.shop {
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
        }
        
        Section {
          if viewModel.shop != nil {
            NavigationLink {
              NumberTagsWebpageListView(
                viewModel: viewModel.createNumberTagsWebpageListViewModel()
              )
            } label: {
              Label(String.shopSettingsNumberTagsWebpageLabel, systemImage: "globe")
            }
            .listRowBackground(Color.cardBackground)
          }
        }
        
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
        viewModel.reload()
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
}
