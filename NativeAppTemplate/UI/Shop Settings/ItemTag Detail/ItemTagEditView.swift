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
            } else if viewModel.itemTag != nil {
                itemTagEditView
            }
        }

        return contentView
    }

    var itemTagEditView: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String.itemTagNamePlaceholder, text: $viewModel.name)
                        .onChange(of: viewModel.name) {
                            viewModel.validateNameLength()
                        }
                } header: {
                    Text(String.nameLabel)
                } footer: {
                    VStack(alignment: .leading) {
                        Text(String.itemTagNameHelp(maximumLength: viewModel.maximumNameLength))
                            .font(.uiFootnote)
                        Text(String.itemTagNameIsInvalid)
                            .font(.uiFootnote)
                            .foregroundStyle(viewModel.hasInvalidDataName ? .validationError : .clear)
                    }
                }

                Section {
                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 100)
                        .onChange(of: viewModel.description) {
                            viewModel.validateDescriptionLength()
                        }
                } header: {
                    Text(String.descriptionLabel)
                } footer: {
                    VStack(alignment: .leading) {
                        Text(String.itemTagDescriptionHelp(maximumLength: viewModel.maximumDescriptionLength))
                            .font(.uiFootnote)
                        Text(String.itemTagDescriptionIsInvalid)
                            .font(.uiFootnote)
                            .foregroundStyle(viewModel.hasInvalidDataDescription ? .validationError : .clear)
                    }
                }
            }
            .navigationTitle(String.editItemTag)
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
