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
                    TextField(Strings.itemTagNamePlaceholder, text: $viewModel.name)
                        .onChange(of: viewModel.name) {
                            viewModel.validateNameLength()
                        }
                } header: {
                    Text(Strings.nameLabel)
                } footer: {
                    VStack(alignment: .leading) {
                        Text(Strings.itemTagNameHelp(maximumLength: viewModel.maximumNameLength))
                            .font(.uiFootnote)
                        Text(Strings.itemTagNameIsInvalid)
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
                    Text(Strings.descriptionLabel)
                } footer: {
                    VStack(alignment: .leading) {
                        Text(Strings.itemTagDescriptionHelp(maximumLength: viewModel.maximumDescriptionLength))
                            .font(.uiFootnote)
                        Text(Strings.itemTagDescriptionIsInvalid)
                            .font(.uiFootnote)
                            .foregroundStyle(viewModel.hasInvalidDataDescription ? .validationError : .clear)
                    }
                }
            }
            .navigationTitle(Strings.addItemTag)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.createItemTag()
                    } label: {
                        Text(Strings.save)
                    }
                    .disabled(viewModel.hasInvalidData)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(Strings.cancel)
                    }
                }
            }
        }
    }
}
