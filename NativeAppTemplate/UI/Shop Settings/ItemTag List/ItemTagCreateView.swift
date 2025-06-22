//
//  ItemTagCreateView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI

struct ItemTagCreateView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var viewModel: ItemTagCreateViewModel
  
  init(viewModel: ItemTagCreateViewModel) {
    self._viewModel = State(wrappedValue: viewModel)
  }
  
  var body: some View {
    contentView
      .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
        if shouldDismiss {
          dismiss()
        }
      }
  }
}

// MARK: - private
private extension ItemTagCreateView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if viewModel.isBusy {
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
          TextField(String("A001"), text: $viewModel.queueNumber)
            .keyboardType(.asciiCapable)
            .onChange(of: viewModel.queueNumber) { _, _ in
              viewModel.validateQueueNumberLength()
            }
        } header: {
          Text(String.tagNumber)
        } footer: {
          VStack(alignment: .leading) {
            Text("Tag Number must be a 2-\(viewModel.maximumQueueNumberLength) alphanumeric characters.")
              .font(.uiFootnote)
            Text(String.zeroPadding)
              .font(.uiFootnote)
            Text(String.tagNumberIsInvalid)
              .font(.uiFootnote)
              .foregroundStyle(viewModel.hasInvalidDataQueueNumber ? .red : .clear)
          }
        }
      }
      .navigationTitle(String.addTag)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            viewModel.createItemTag()
          } label: {
            Text(String.save)
          }
          .disabled(viewModel.hasInvalidData)
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
}
