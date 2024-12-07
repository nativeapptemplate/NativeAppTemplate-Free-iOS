//
//  ShopCreateView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2022/06/07.
//

import SwiftUI

struct ShopCreateView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(SessionController.self) private var sessionController
  @Environment(MessageBus.self) private var messageBus
  private var shopRepository: ShopRepository
  @State private var name = ""
  @State private var description = ""
  @State private var selectedTimeZone: String
  @State private var isCreating = false

  init(
    shopRepository: ShopRepository
  ) {
    self.shopRepository = shopRepository
    _selectedTimeZone = State(initialValue: Utility.currentTimeZone())
  }

  private var hasInvalidData: Bool { Utility.isBlank(name) }
  
  var body: some View {
    contentView
  }
}

// MARK: - private
private extension ShopCreateView {
  var contentView: some View {

    @ViewBuilder var contentView: some View {
      if isCreating {
        LoadingView()
      } else {
        shopCreateView
      }
    }

    return contentView
  }

  private var shopCreateView: some View {
    NavigationStack {
      Form {
        Section {
          TextField(String.name, text: $name)
        } footer: {
          Text(String.shopNameIsRequired)
            .foregroundStyle(Utility.isBlank(name) ? .red : .clear)
        }

        Section {
          TextField(String.descriptionString, text: $description, axis: .vertical)
            .lineLimit(10, reservesSpace: true)
        }
        
        Section {
          Picker(String.timeZone, selection: $selectedTimeZone) {
            ForEach(timeZones.keys, id: \.self) { key in
              Text(timeZones[key]!).tag(key)
            }
          }
        }
      }
      .navigationTitle(String.addShop)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            createShop()
          } label: {
            Text(String.save)
          }
          .disabled(hasInvalidData)
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Text(String.cancel)
          }
        }
      }
    }
  }
  
  func createShop() {
    Task { @MainActor in
      isCreating = true

      do {
        let shop = Shop(
          id: "",
          name: name,
          description: description,
          timeZone: selectedTimeZone
        )
        _ = try await shopRepository.create(shop: shop)
        messageBus.post(message: Message(level: .success, message: .shopCreated))
      } catch {
        messageBus.post(
          message: Message(
            level: .error,
            message: error.localizedDescription,
            autoDismiss: false
          )
        )
        
        // e.g. Limit shopps count error
        guard case NativeAppTemplateAPIError.requestFailed(_, 422, _) = error else {
          try await sessionController.logout()
          return
        }
      }
      
      dismiss()
    }
  }
}
