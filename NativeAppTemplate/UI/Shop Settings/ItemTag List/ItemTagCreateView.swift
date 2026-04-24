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
                        Text(String.tagNumberIsInvalid)
                            .font(.uiFootnote)
                            .foregroundStyle(viewModel.hasInvalidDataName ? .validationError : .clear)
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
