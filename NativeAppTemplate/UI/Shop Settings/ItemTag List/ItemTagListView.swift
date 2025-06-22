//
//  ItemTagListView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI

struct ItemTagListView: View {
  @Environment(DataManager.self) private var dataManager
  @Environment(MessageBus.self) private var messageBus
  @State private var viewModel: ItemTagListViewModel

  init(viewModel: ItemTagListViewModel) {
    self._viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    contentView
      .task {
        viewModel.reload()
      }
  }
}

// MARK: - private
private extension ItemTagListView {
  var contentView: some View {
    @ViewBuilder var contentView: some View {
      if viewModel.isBusy {
        LoadingView()
      } else {
        switch viewModel.state {
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
      Text(viewModel.shop.name)
        .font(.uiTitle1)
        .foregroundStyle(.titleText)
        .padding(.top, 24)
        .multilineTextAlignment(.center)
      
      if viewModel.isEmpty {
        noResultsView
      } else {
        List(viewModel.itemTags) { itemTag in
          NavigationLink(
            destination: ItemTagDetailView(
              viewModel: viewModel.createItemTagDetailViewModel(itemTagId: itemTag.id)
            )
          ) {
            ItemTagListCardView(
              itemTag: itemTag
            )
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
              Button(role: .destructive) { viewModel.destroyItemTag(itemTagId: itemTag.id) } label: {
                Label(String.delete, systemImage: "trash")
                  .labelStyle(.titleOnly)
              }
              .tint(.red)
            }
          }
          .listRowBackground(Color.cardBackground)
        }
        .refreshable {
          viewModel.reload()
        }
      }
    }
    .navigationTitle(String.shopSettingsManageNumberTagsLabel)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          viewModel.isShowingCreateSheet.toggle()
        } label: {
          Image(systemName: "plus")
        }
      }
    }
    .sheet(isPresented: $viewModel.isShowingCreateSheet,
           onDismiss: {
      viewModel.reload()
    }, content: {
      ItemTagCreateView(
        viewModel: viewModel.createItemTagCreateViewModel()
      )
    }
    )
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
        viewModel.isShowingCreateSheet.toggle()
      }
      .padding()
      
      Spacer()
    }
    .padding()
  }
  
  var reloadView: some View {
    ErrorView(buttonAction: viewModel.reload)
  }
}
