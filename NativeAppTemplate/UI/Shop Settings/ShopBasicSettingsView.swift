//
//  ShopBasicSettingsView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ShopBasicSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ShopBasicSettingsViewModel

    init(viewModel: ShopBasicSettingsViewModel) {
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
                    .onChange(of: viewModel.name) {
                        viewModel.validateNameLength()
                    }
            } header: {
                Text(String.shopName)
            } footer: {
                VStack(alignment: .leading) {
                    Text(String.shopNameHelp(maximumLength: viewModel.maximumNameLength))
                        .font(.uiFootnote)
                    Text(String.shopNameIsInvalid)
                        .font(.uiFootnote)
                        .foregroundStyle(viewModel.hasInvalidDataName ? .validationError : .clear)
                }
            }

            Section {
                TextField(String.descriptionString, text: $viewModel.description, axis: .vertical)
                    .lineLimit(10, reservesSpace: true)
                    .onChange(of: viewModel.description) {
                        viewModel.validateDescriptionLength()
                    }
            } header: {
                Text(String.descriptionString)
            } footer: {
                VStack(alignment: .leading) {
                    Text(String.shopDescriptionHelp(maximumLength: viewModel.maximumDescriptionLength))
                        .font(.uiFootnote)
                    Text(String.shopDescriptionIsInvalid)
                        .font(.uiFootnote)
                        .foregroundStyle(viewModel.hasInvalidDataDescription ? .validationError : .clear)
                }
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
