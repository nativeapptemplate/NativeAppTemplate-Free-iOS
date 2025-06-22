//
//  ShopBasicSettingsView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/09/15.
//

import SwiftUI

struct ShopBasicSettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var viewModel: ShopBasicSettingsViewModel

  init(viewModel: ShopBasicSettingsViewModel) {
    self._viewModel = State(wrappedValue: viewModel)
  }

  var body: some View {
    contentView
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
private extension ShopBasicSettingsView {
  var contentView: some View {

    @ViewBuilder var contentView: some View {
      if viewModel.isBusy {
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
        TextField(String.shopName, text: $viewModel.name)
      } header: {
        Text(String.shopName)
      } footer: {
        Text(String.shopNameIsRequired)
          .font(.uiFootnote)
          .foregroundStyle(Utility.isBlank(viewModel.name) ? .red : .clear)
      }
      
      Section {
        TextField(String.descriptionString, text: $viewModel.description, axis: .vertical)
          .lineLimit(10, reservesSpace: true)
      } header: {
        Text(String.descriptionString)
      }
      
      Section {
        Picker(String.timeZone, selection: $viewModel.selectedTimeZone) {
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
          viewModel.updateShop()
        } label: {
          Text(String.save)
        }
        .disabled(viewModel.hasInvalidData)
      }
    }
  }
}
