// Copyright (c) 2019 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SwiftUI
import TipKit

struct TapShopBelowTip: Tip {
  var title: Text {
    Text(String.tapShopBelow)
  }
  
  var message: Text? {
    Text(String.haveFun)
  }
  
  var image: Image? {
    Image(systemName: "info.circle")
  }
}

struct ShopListView: View {
  @Environment(DataManager.self) private var dataManager
  @Environment(TabViewModel.self) private var tabViewModel
  @Environment(\.mainTab) private var mainTab
  @Environment(MessageBus.self) private var messageBus

  @State private var viewModel: ShopListViewModel

  init(viewModel: ShopListViewModel) {
    self._viewModel = State(wrappedValue: viewModel)
  }
}

extension ShopListView {
  var body: some View {
    contentView
      .task {
        viewModel.reload()
      }
      .onAppear {
        viewModel.setTabViewModelShowingDetailViewToFalse()
      }
      .onChange(of: viewModel.state) {
        if viewModel.state == .initial {
          viewModel.reload()
        }
      }
    // Avoid showing deleted shop.
      .onChange(of: viewModel.shouldPopToRootView) {
        Task {
          try await Task.sleep(nanoseconds: 2_000_000_000)
          viewModel.reload()
        }
      }
  }
}

// MARK: - private
private extension ShopListView {
  var contentView: some View {
    @ViewBuilder var contentView: some View {
      switch viewModel.state {
      case .initial, .loading:
        LoadingView()
      case .hasData:
        shopListView
      case .failed:
        reloadView
      }
    }
    
    return contentView
  }
  
  var cardsView: some View {
    ForEach(viewModel.shops) { shop in
      NavigationLink(value: shop) {
        ShopListCardView(shop: shop)
      }
      .listRowBackground(Color.cardBackground)
    }
  }
  
  var shopListView: some View {
    VStack {
      if viewModel.isEmpty {
        noResultsView(leftInShopSlots: viewModel.leftInShopSlots)
      } else {
        List {
          Section {
            cardsView
          } header: {
            let tip = TapShopBelowTip()
            TipView(tip, arrowEdge: .bottom)
              .tint(.alarm)
            
            EmptyView()
              .id(viewModel.scrollToTopID())
          } footer: {
            VStack(spacing: 0) {
              HStack(alignment: .firstTextBaseline) {
                Text(String(viewModel.leftInShopSlots))
                  .font(.uiLabelBold)
                Text(verbatim: "left in shop slots.")
                  .font(.uiFootnote)
              }
            }
          }
        }
        .navigationDestination(for: Shop.self) { shop in
          ShopDetailView(
            viewModel: ShopDetailViewModel(
              sessionController: dataManager.sessionController,
              shopRepository: viewModel.shopRepository,
              itemTagRepository: viewModel.itemTagRepository,
              tabViewModel: tabViewModel,
              mainTab: mainTab,
              messageBus: messageBus,
              shopId: shop.id
            )
          )
        }
        .accessibility(identifier: "shopListView")
        .refreshable {
          viewModel.reload()
        }
      }
    }
    .navigationTitle(String.shops)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if viewModel.leftInShopSlots > 0 {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            viewModel.showCreateView()
          } label: {
            Image(systemName: "plus")
          }
        }
      }
    }
    .sheet(isPresented: $viewModel.isShowingCreateSheet,
           onDismiss: {
      viewModel.reload()
    }, content: {
      ShopCreateView(
        viewModel: ShopCreateViewModel(
          sessionController: dataManager.sessionController,
          shopRepository: dataManager.shopRepository,
          messageBus: messageBus
        )
      )
    }
    )
  }
  
  var reloadView: some View {
    ErrorView(buttonAction: viewModel.reload)
  }
  
  func noResultsView(leftInShopSlots: Int) -> some View {
    VStack {
      if leftInShopSlots > 0 {
        Image(systemName: "storefront")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 96)
          .padding()
        
        Text(String.addShopDescription)
          .foregroundStyle(.contentText)
          .padding()
        
        MainButtonView(title: String.addShop, type: .primary(withArrow: false)) {
          viewModel.showCreateView()
        }
        .padding()
        
        Spacer()
      } else {
        Image(systemName: "externaldrive.badge.exclamationmark")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 96)
          .padding()
        
        HStack(alignment: .firstTextBaseline) {
          Text(String(leftInShopSlots))
            .font(.uiTitle3)
          Text(verbatim: "left in shop slots.")
            .foregroundStyle(.contentText)
        }
        .padding()
        
        Spacer()
      }
    }
    .padding()
  }
}
