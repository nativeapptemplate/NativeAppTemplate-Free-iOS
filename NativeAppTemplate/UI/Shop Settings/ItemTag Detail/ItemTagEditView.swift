//
//  ItemTagEditView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ItemTagEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ItemTagEditViewModel

    init(viewModel: ItemTagEditViewModel) {
        _viewModel = State(wrappedValue: viewModel)
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

private extension ItemTagEditView {
    var contentView: some View {
        @ViewBuilder var contentView: some View {
            if viewModel.isBusy {
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
                    TextField(String("A001"), text: $viewModel.name)
                        .keyboardType(.asciiCapable)
                        .onChange(of: viewModel.name) { _, _ in
                            viewModel.validateNameLength()
                        }
                } header: {
                    Text(String.tagNumber)
                } footer: {
                    VStack(alignment: .leading) {
                        Text("Name must be a 2-\(viewModel.maximumQueueNumberLength) alphanumeric characters.")
                            .font(.uiFootnote)
                        Text(String.zeroPadding)
                            .font(.uiFootnote)
                        Text(String.tagNumberIsInvalid)
                            .font(.uiFootnote)
                            .foregroundStyle(viewModel.hasInvalidDataName ? .validationError : .clear)
                    }
                }
            }
            .navigationTitle(String.editTag)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.updateItemTag()
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
