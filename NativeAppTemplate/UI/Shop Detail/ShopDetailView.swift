//
//  ShopDetailView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/09.
//

import SwiftUI
import TipKit

struct ReadInstructionsTip: Tip {
  var title: Text {
    Text(String.readInstructions)
  }
  
  var message: Text? {
    Text(String.haveFun)
  }
  
  var image: Image? {
    Image(systemName: "info.circle")
  }
}

struct ShopDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.mainTab) private var mainTab
  @Environment(TabViewModel.self) private var tabViewModel
  @Environment(MessageBus.self) private var messageBus
  @Environment(\.sessionController) private var sessionController
  @State private var isFetching = true
  @State private var isResetting = false
  @State private var isCompleting = false
  @State private var itemTags: [ItemTag]?
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
      if isFetching || isResetting || isCompleting {
        LoadingView()
      } else {
        shopDetailView
      }
    }
    
    return contentView
  }
  
  var header: some View {
    ScrollView(.horizontal) {
      VStack(alignment: .leading, spacing: 0) {
        let tip = ReadInstructionsTip()
        TipView(tip, arrowEdge: .bottom)
          .tint(.alarm)
        
        Text("\(String.instructions):")
          .foregroundStyle(.contentText)
        HStack(alignment: .firstTextBaseline) {
          Text(verbatim: "1.")
            .font(.uiCaption)
            .foregroundStyle(.contentText)
          HStack {
            let openServerNumberTagsWebpage = "\(String.open) [\(String.serverNumberTagsWebpage)](\(shop.wrappedValue.displayShopServerUrl))."
            Text(.init(openServerNumberTagsWebpage))
              .font(.uiCaption)
              .foregroundStyle(.contentText)
          }
        }
        HStack(alignment: .firstTextBaseline) {
          Text(verbatim: "2.")
            .font(.uiCaption)
            .foregroundStyle(.contentText)
          Text("\(String.swipeNumberTagBelow) \(String.tapDisplayedButton)")
            .font(.uiCaption)
            .foregroundStyle(.contentText)
        }
        HStack(alignment: .firstTextBaseline) {
          Text(verbatim: "3.")
            .font(.uiCaption)
            .foregroundStyle(.contentText)
          Text(String.serverNumberTagsWebpageWillBeUpdated)
            .font(.uiCaption)
            .foregroundStyle(.contentText)
        }
        Link(String.learnMore, destination: URL(string: String.howToUseUrl)!)
      }
    }
  }
  
  var cardsView: some View {
    ForEach(itemTagRepository.itemTags, id: \.id) { itemTag in
      ShopDetailCardView(itemTag: itemTag)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
          if itemTag.state == ItemTagState.idled {
            Button { completeTag(itemTagId: itemTag.id) } label: {
              Label(String.complete, systemImage: "bolt.fill")
                .labelStyle(.titleOnly)
            }
            .tint(.blue)
          } else {
            Button(role: .destructive) { resetTag(itemTagId: itemTag.id) } label: {
              Label(String.reset, systemImage: "trash")
                .labelStyle(.titleOnly)
            }
            .tint(.red)
          }
        }
        .listRowBackground(Color.cardBackground)
    }
  }
  
  var shopDetailView: some View {
    VStack {
      header
        .padding(.top)
        .padding(.horizontal, 8)
      List {
        Section {
          cardsView
        } header: {
          EmptyView()
            .id(ScrollToTopID(mainTab: mainTab, detail: true))
        }
      }
      .scrollContentBackground(.hidden)
      .accessibility(identifier: "shopDetailView")
      .refreshable {
        reload()
      }
    }
    .navigationTitle(shop.wrappedValue.name)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink(
          destination: ShopSettingsView(
            viewModel: ShopSettingsViewModel(
              sessionController: sessionController,
              shopRepository: shopRepository,
              itemTagRepository: itemTagRepository,
              messageBus: messageBus,
              shopId: shop.wrappedValue.id
            )
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
    Task { @MainActor in
      isFetching = true
      
      do {
        _ = try await shopRepository.fetchDetail(id: shopId)
        _ = try await itemTagRepository.fetchAll(shopId: shopId)
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
  
  func completeTag(itemTagId: String) {
    Task { @MainActor in
      isCompleting = true
      
      do {
        let itemTag = try await itemTagRepository.complete(id: itemTagId)
        if itemTag.alreadyCompleted! {
          messageBus.post(message: Message(level: .warning, message: .itemTagAlreadyCompleted, autoDismiss: false))
        } else {
          messageBus.post(message: Message(level: .success, message: .itemTagCompleted))
        }
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.itemTagCompletedError) \(error.localizedDescription)", autoDismiss: false))
      }
      
      isCompleting = false
      reload()
    }
  }
  
  func resetTag(itemTagId: String) {
    Task { @MainActor in
      isResetting = true
      
      do {
        _ = try await itemTagRepository.reset(id: itemTagId)
        messageBus.post(message: Message(level: .success, message: .itemTagReset))
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.itemTagResetError) \(error.localizedDescription)", autoDismiss: false))
      }
      
      isResetting = false
      reload()
    }
  }
}
