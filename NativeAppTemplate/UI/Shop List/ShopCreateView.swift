//
//  ShopCreateView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2022/06/07.
//

import SwiftUI

struct ShopCreateView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var viewModel: ShopCreateViewModel

  init(viewModel: ShopCreateViewModel) {
    self._viewModel = State(wrappedValue: viewModel)
  }

  var body: some View {
    contentView
      .onChange(of: viewModel.shouldDismiss) {
        if viewModel.shouldDismiss {
          dismiss()
        }
      }
  }

  @ViewBuilder
  private var contentView: some View {
    if viewModel.isCreating {
      LoadingView()
    } else {
      shopCreateForm
    }
  }

  private var shopCreateForm: some View {
    NavigationStack {
      Form {
        Section {
          TextField(String.name, text: $viewModel.name)
        } footer: {
          Text(String.shopNameIsRequired)
            .foregroundStyle(viewModel.hasInvalidData ? .red : .clear)
        }

        Section {
          TextField(String.descriptionString, text: $viewModel.description, axis: .vertical)
            .lineLimit(10, reservesSpace: true)
        }

        Section {
          Picker(String.timeZone, selection: $viewModel.selectedTimeZone) {
            ForEach(timeZones.keys, id: \.self) { key in
              Text(timeZones[key]!).tag(key)
            }
          }
        }
      }
      .navigationTitle(String.addShop)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String.save) {
            viewModel.createShop()
          }
          .disabled(viewModel.hasInvalidData)
        }

        ToolbarItem(placement: .navigationBarLeading) {
          Button(String.cancel) {
            dismiss()
          }
        }
      }
    }
  }
}
