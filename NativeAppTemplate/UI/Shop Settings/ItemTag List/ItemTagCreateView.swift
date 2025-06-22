//
//  ItemTagCreateView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI

struct ItemTagCreateView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(MessageBus.self) private var messageBus
  @Environment(\.sessionController) private var sessionController
  private var itemTagRepository: ItemTagRepositoryProtocol
  @State private var queueNumber = ""
  @State private var isCreating = false
  private var shopId: String
  
  init(
    itemTagRepository: ItemTagRepositoryProtocol,
    shopId: String
  ) {
    self.itemTagRepository = itemTagRepository
    self.shopId = shopId
  }

  private var hasInvalidData: Bool {
    if hasInvalidDataQueueNumber {
      return true
    }
    
    return false
  }

  private var hasInvalidDataQueueNumber: Bool {
    if Utility.isBlank(queueNumber) {
      return true
    }
    
    if !queueNumber.isAlphanumeric(ignoreDiacritics: true) {
      return true
    }
        
    if !(2 <= queueNumber.count && queueNumber.count <= sessionController.maximumQueueNumberLength) {
      return true
    }
    
    return false
  }
  
  var body: some View {
    contentView
  }
}

// MARK: - private
private extension ItemTagCreateView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if isCreating {
        LoadingView()
      } else {
        itemTagCreateView
      }
    }
    
    return contentView
  }
  
  var itemTagCreateView: some View {
    NavigationStack {
      Form {
        Section {
          TextField(String("A001"), text: $queueNumber)
            .keyboardType(.asciiCapable)
            .onChange(of: queueNumber) {
              queueNumber = String(queueNumber.prefix(sessionController.maximumQueueNumberLength))
            }
        } header: {
          Text(String.tagNumber)
        } footer: {
          VStack(alignment: .leading) {
            Text("Tag Number must be a 2-\(sessionController.maximumQueueNumberLength) alphanumeric characters.")
              .font(.uiFootnote)
            Text(String.zeroPadding)
              .font(.uiFootnote)
            Text(String.tagNumberIsInvalid)
              .font(.uiFootnote)
              .foregroundStyle(hasInvalidDataQueueNumber ? .red : .clear)
          }
        }
      }
      .navigationTitle(String.addTag)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            createItemTag()
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
  
  func createItemTag() {
    Task { @MainActor in
      isCreating = true

      do {
        let itemTag = ItemTag(queueNumber: queueNumber)
        _ = try await itemTagRepository.create(shopId: shopId, itemTag: itemTag)
        messageBus.post(message: Message(level: .success, message: .itemTagCreated))
      } catch {
        messageBus.post(
          message: Message(
            level: .error,
            message: error.localizedDescription,
            autoDismiss: false
          )
        )
      }
      
      dismiss()
    }
  }
}
