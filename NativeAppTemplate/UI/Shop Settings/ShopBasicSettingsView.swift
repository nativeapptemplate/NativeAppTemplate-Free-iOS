//
//  ShopBasicSettingsView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/09/15.
//

import SwiftUI

struct ShopBasicSettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(MessageBus.self) private var messageBus
  @Environment(SessionController.self) private var sessionController
  private var shopRepository: ShopRepository
  @State private var isFetching = true
  @State private var isUpdating = false
  @State private var name = ""
  @State private var description = ""
  @State private var selectedTimeZone = String.defaultTimeZone
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

  private var hasInvalidData: Bool {
    if Utility.isBlank(name) {
      return true
    }
    
    let wrappedShop = shop.wrappedValue

    if wrappedShop.name == name &&
        wrappedShop.description == description &&
        wrappedShop.timeZone == selectedTimeZone {
      return true
    }
    
    return false
  }

  var body: some View {
    contentView
      .task {
        reload()
      }
  }
}

// MARK: - private
private extension ShopBasicSettingsView {
  var contentView: some View {

    @ViewBuilder var contentView: some View {
      if isFetching || isUpdating {
        LoadingView()
      } else {
        shopBasicSettingsView
      }
    }

    return contentView
  }

  var shopBasicSettingsView: some View {
    Form {
      Section {
        TextField(String.shopName, text: $name)
      } header: {
        Text(String.shopName)
      } footer: {
        Text(String.shopNameIsRequired)
          .font(.uiFootnote)
          .foregroundStyle(Utility.isBlank(name) ? .red : .clear)
      }
      
      Section {
        TextField(String.descriptionString, text: $description, axis: .vertical)
          .lineLimit(10, reservesSpace: true)
      } header: {
        Text(String.descriptionString)
      }
      
      Section {
        Picker(String.timeZone, selection: $selectedTimeZone) {
          ForEach(timeZones.keys, id: \.self) { key in
            Text(timeZones[key]!).tag(key)
          }
        }
      }
    }
    .padding()
    .navigationTitle(String.shopSettingsBasicSettingsLabel)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          updateShop()
        } label: {
          Text(String.save)
        }
        .disabled(hasInvalidData)
      }
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

        name = shop.wrappedValue.name
        description = shop.wrappedValue.description
        selectedTimeZone = shop.wrappedValue.timeZone
        
        isFetching = false
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
        dismiss()
      }
    }
  }

  func updateShop() {
    Task { @MainActor in
      isUpdating = true

      do {
        let shop = Shop(
          id: shop.id,
          name: name,
          description: description,
          timeZone: selectedTimeZone
       )
        _ = try await shopRepository.update(id: shop.id, shop: shop)
        messageBus.post(message: Message(level: .success, message: .basicSettingsUpdated))
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
      }
      
      isUpdating = false
      dismiss()
    }
  }
}
