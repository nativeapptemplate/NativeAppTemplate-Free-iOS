//
//  ItemTagEditView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI

struct ItemTagEditView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(MessageBus.self) private var messageBus
  @Environment(SessionController.self) private var sessionController
  private var itemTagRepository: ItemTagRepository
  @State private var queueNumber = ""
  @State private var isFetching = true
  @State private var isUpdating = false
  private var itemTagId: String
  
  private var itemTag: Binding<ItemTag> {
    Binding {
      itemTagRepository.findBy(id: itemTagId)
    } set: { _ in
    }
  }
  
  init(
    itemTagRepository: ItemTagRepository,
    itemTagId: String
  ) {
    self.itemTagRepository = itemTagRepository
    self.itemTagId = itemTagId
  }
  
  private var hasInvalidData: Bool {
    if hasInvalidDataQueueNumber {
      return true
    }
    
    if itemTag.wrappedValue.queueNumber == queueNumber {
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
      .task {
        reload()
      }
  }
}

// MARK: - private
private extension ItemTagEditView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if isFetching || isUpdating {
        LoadingView()
      } else {
        itemTagEditView
      }
    }
    
    return contentView
  }
  
  var itemTagEditView: some View {
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
      .navigationTitle(String.editTag)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            updateItemTag()
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
  
  func reload() {
    fetchItemTagDetail()
  }
  
  private func fetchItemTagDetail() {
    Task { @MainActor in
      isFetching = true

      do {
        _ = try await itemTagRepository.fetchDetail(id: itemTagId)
        
        queueNumber = String(itemTag.wrappedValue.queueNumber)
        
        isFetching = false
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
        isFetching = false
        dismiss()
      }
    }
  }
  
  func updateItemTag() {
    Task { @MainActor in
      isUpdating = true

      do {
        let itemTag = ItemTag(queueNumber: queueNumber)
        _ = try await itemTagRepository.update(id: itemTagId, itemTag: itemTag)
        messageBus.post(message: Message(level: .success, message: .itemTagUpdated))
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
      }
      
      isUpdating = false
      dismiss()
    }
  }
}
