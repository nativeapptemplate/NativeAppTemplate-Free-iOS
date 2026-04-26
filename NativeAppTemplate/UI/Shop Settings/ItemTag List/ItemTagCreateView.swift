//
//  ItemTagCreateView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ItemTagCreateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ItemTagCreateViewModel

    init(viewModel: ItemTagCreateViewModel) {
        _viewModel = State(wrappedValue: viewModel)
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
