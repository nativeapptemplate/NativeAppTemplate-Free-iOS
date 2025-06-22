//
//  ItemTagListView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI

struct ItemTagListView: View {
  @Environment(MessageBus.self) private var messageBus
  @Environment(\.sessionController) private var sessionController
  private var itemTagRepository: ItemTagRepositoryProtocol
  @State private var isShowingCreateSheet = false
  @State private var isDeleting = false
  @State private var isShowingDeleteConfirmationDialog = false
  private let shop: Shop
  
  init(
    itemTagRepository: ItemTagRepositoryProtocol,
    shop: Shop
  ) {
    self.itemTagRepository = itemTagRepository
    self.shop = shop
  }
  
  var body: some View {
    contentView
      .task {
        reload()
      }
  }
}

// MARK: - private
private extension ItemTagListView {
  var contentView: some View {
    @ViewBuilder var contentView: some View {
      if isDeleting {
        LoadingView()
      } else {
        switch itemTagRepository.state {
        case .initial, .loading:
          LoadingView()
        case .hasData:
          itemTagListView
        case .failed:
          reloadView
        }
      }
    }
    
    return contentView
  }
  
  var itemTagListView: some View {
    VStack {
      Text(shop.name)
        .font(.uiTitle1)
        .foregroundStyle(.titleText)
        .padding(.top, 24)
        .multilineTextAlignment(.center)
      
      if itemTagRepository.isEmpty {
        noResultsView
      } else {
        List(itemTagRepository.itemTags) { itemTag in
          NavigationLink(
            destination: ItemTagDetailView(itemTagRepository: itemTagRepository, shop: shop, itemTagId: itemTag.id)
          ) {
            ItemTagListCardView(
              itemTag: itemTag
            )
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
              Button(role: .destructive) { destroyItemTag(itemTagId: itemTag.id) } label: {
                Label(String.delete, systemImage: "trash")
                  .labelStyle(.titleOnly)
              }
              .tint(.red)
            }
          }
          .listRowBackground(Color.cardBackground)
        }
        .refreshable {
          reload()
        }
      }
    }
    .navigationTitle(String.shopSettingsManageNumberTagsLabel)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          isShowingCreateSheet.toggle()
        } label: {
          Image(systemName: "plus")
        }
      }
    }
    .sheet(isPresented: $isShowingCreateSheet,
           onDismiss: {
      reload()
    }, content: {
      ItemTagCreateView(itemTagRepository: itemTagRepository, shopId: shop.id)
    }
    )
  }
  
  func reload() {
    itemTagRepository.reload(shopId: shop.id)
  }
  
  func destroyItemTag(itemTagId: String) {
    Task { @MainActor in
      isDeleting = true
      
      do {
        try await itemTagRepository.destroy(id: itemTagId)
        messageBus.post(message: Message(level: .success, message: .itemTagDeleted))
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.itemTagDeletedError) \(error.localizedDescription)", autoDismiss: false))
      }
      
      isDeleting = false
      reload()
    }
  }
  
  var noResultsView: some View {
    VStack {
      Image(systemName: "01.square")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 96)
        .padding()
      
      Text(String.addTagDescription)
        .foregroundStyle(.contentText)
        .padding()
      
      MainButtonView(title: String.addTag, type: .primary(withArrow: false)) {
        isShowingCreateSheet.toggle()
      }
      .padding()
      
      Spacer()
    }
    .padding()
  }
  
  var reloadView: some View {
    ErrorView(buttonAction: reload)
  }
}
