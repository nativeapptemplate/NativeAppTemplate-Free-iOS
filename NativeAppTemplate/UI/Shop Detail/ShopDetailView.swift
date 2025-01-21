//
//  ShopDetailView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/09.
//

import SwiftUI
import TipKit

struct ShopDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.mainTab) private var mainTab
  @Environment(TabViewModel.self) private var tabViewModel
  @Environment(MessageBus.self) private var messageBus
  @Environment(SessionController.self) private var sessionController
  @State private var isFetching = true
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
extension ShopDetailView {
  var body: some View {
    contentView
      .onAppear {
        tabViewModel.showingDetailView[mainTab] = true
      }
      .task {
        reload()
      }
  }
}

// MARK: - private
private extension ShopDetailView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if isFetching {
        LoadingView()
      } else {
        shopDetailView
      }
    }
    
    return contentView
  }
  
  var shopDetailView: some View {
    VStack {
      Text(shop.wrappedValue.name)
        .font(.uiTitle1)
        .foregroundStyle(.titleText)
        .padding(.top)
      Text(shop.wrappedValue.description)
        .foregroundStyle(.contentText)
        .padding(.top, 4)
    }
    .navigationTitle(shop.wrappedValue.name)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink(
          destination: ShopSettingsView(
            shopRepository: shopRepository,
            shopId: shop.wrappedValue.id
          )
        ) {
          Image(systemName: "gearshape.fill")
        }
      }
    }
  }
  
  func reload() {
    // Avoid fetching shop detail error
    guard sessionController.isLoggedIn else {
      return
    }
    
    fetchShopDetail()
  }
  
  private func fetchShopDetail() {
    Task {
      isFetching = true
      
      do {
        _ = try await shopRepository.fetchDetail(id: shopId)
        isFetching = false
      } catch {
        messageBus.post(
          message: Message(
            level: .error,
            message: error.localizedDescription,
            autoDismiss: false
          )
        )
        
        dismiss()
      }
    }
  }
}
