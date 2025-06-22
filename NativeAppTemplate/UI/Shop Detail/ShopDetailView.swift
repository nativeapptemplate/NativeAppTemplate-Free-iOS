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
  @State private var viewModel: ShopDetailViewModel
  
  init(viewModel: ShopDetailViewModel) {
    self._viewModel = State(wrappedValue: viewModel)
  }
}

// MARK: - View
extension ShopDetailView {
  var body: some View {
    contentView
      .onAppear {
        viewModel.setTabViewModelShowingDetailViewToTrue()
      }
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
private extension ShopDetailView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if viewModel.isBusy {
        LoadingView()
      } else if let shop = viewModel.shop {
        shopDetailView(shop: shop)
      }
    }
    
    return contentView
  }
  
  func header(shop: Shop) -> some View {
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
            let openServerNumberTagsWebpage = "\(String.open) [\(String.serverNumberTagsWebpage)](\(shop.displayShopServerUrl))."
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
    ForEach(viewModel.itemTags, id: \.id) { itemTag in
      ShopDetailCardView(itemTag: itemTag)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
          if itemTag.state == ItemTagState.idled {
            Button { viewModel.completeTag(itemTagId: itemTag.id) } label: {
              Label(String.complete, systemImage: "bolt.fill")
                .labelStyle(.titleOnly)
            }
            .tint(.blue)
          } else {
            Button(role: .destructive) { viewModel.resetTag(itemTagId: itemTag.id) } label: {
              Label(String.reset, systemImage: "trash")
                .labelStyle(.titleOnly)
            }
            .tint(.red)
          }
        }
        .listRowBackground(Color.cardBackground)
    }
  }
  
  func shopDetailView(shop: Shop) -> some View {
    VStack {
      header(shop: shop)
        .padding(.top)
        .padding(.horizontal, 8)
      List {
        Section {
          cardsView
        } header: {
          EmptyView()
            .id(viewModel.scrollToTopID())
        }
      }
      .scrollContentBackground(.hidden)
      .accessibility(identifier: "shopDetailView")
      .refreshable {
        viewModel.reload()
      }
    }
    .navigationTitle(viewModel.shop?.name ?? "")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink(
          destination: ShopSettingsView(
            viewModel: viewModel.createShopSettingsViewModel()
          )
        ) {
          Image(systemName: "gearshape.fill")
        }
      }
    }
  }
}
