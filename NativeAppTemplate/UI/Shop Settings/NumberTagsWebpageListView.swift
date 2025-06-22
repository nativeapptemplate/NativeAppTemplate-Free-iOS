//
//  NumberTagsWebpageList.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI
import UniformTypeIdentifiers

enum NumberTagsWebpageListType: String, Identifiable, CaseIterable, Codable, Hashable {
  case server

  var id: Self { self }

  var displayString: String {
    switch self {
    case .server:
      return String.serverNumberTagsWebpage
    }
  }
}

struct NumberTagsWebpageListView: View {
  @State private var viewModel: NumberTagsWebpageListViewModel

  init(viewModel: NumberTagsWebpageListViewModel) {
    self._viewModel = State(wrappedValue: viewModel)
  }
}

// MARK: - View
extension NumberTagsWebpageListView {
  var body: some View {
    contentView
  }
}

// MARK: - private
private extension NumberTagsWebpageListView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      numberTagsWebpageListView
    }
    
    return contentView
  }

  var numberTagsWebpageListView: some View {
    VStack {
      Text(viewModel.shop.name)
        .font(.uiTitle1)
        .foregroundStyle(.titleText)
        .padding(.top, 24)
      List(NumberTagsWebpageListType.allCases) { numberTagsWebpageListType in
        switch numberTagsWebpageListType {
        case .server:
          Section {
            Link(numberTagsWebpageListType.displayString, destination: viewModel.shop.displayShopServerUrl)
          } header: {
            Label(String("Server"), systemImage: "storefront")
          } footer: {
            Button(String.copyWebpageUrl) {
              viewModel.copyWebpageUrl(viewModel.shop.displayShopServerUrl.absoluteString)
            }
          }
          .listRowBackground(Color.cardBackground)
        }
      }
    }
    .navigationTitle(String.shopSettingsNumberTagsWebpageLabel)
  }
}
