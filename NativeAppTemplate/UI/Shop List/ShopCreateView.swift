//
//  ShopCreateView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ShopCreateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ShopCreateViewModel

    init(viewModel: ShopCreateViewModel) {
        _viewModel = State(wrappedValue: viewModel)
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
                    TextField(Strings.name, text: $viewModel.name)
                        .onChange(of: viewModel.name) {
                            viewModel.validateNameLength()
                        }
                } header: {
                    Text(Strings.shopName)
                } footer: {
                    VStack(alignment: .leading) {
                        Text(Strings.shopNameHelp(maximumLength: viewModel.maximumNameLength))
                            .font(.uiFootnote)
                        Text(Strings.shopNameIsInvalid)
                            .font(.uiFootnote)
                            .foregroundStyle(viewModel.hasInvalidDataName ? .validationError : .clear)
                    }
                }

                Section {
                    TextField(Strings.descriptionString, text: $viewModel.description, axis: .vertical)
                        .lineLimit(10, reservesSpace: true)
                        .onChange(of: viewModel.description) {
                            viewModel.validateDescriptionLength()
                        }
                } header: {
                    Text(Strings.descriptionString)
                } footer: {
                    VStack(alignment: .leading) {
                        Text(Strings.shopDescriptionHelp(maximumLength: viewModel.maximumDescriptionLength))
                            .font(.uiFootnote)
                        Text(Strings.shopDescriptionIsInvalid)
                            .font(.uiFootnote)
                            .foregroundStyle(viewModel.hasInvalidDataDescription ? .validationError : .clear)
                    }
                }

                Section {
                    Picker(Strings.timeZone, selection: $viewModel.selectedTimeZone) {
                        ForEach(timeZones.keys, id: \.self) { key in
                            Text(timeZones[key]!).tag(key)
                        }
                    }
                }
            }
            .navigationTitle(Strings.addShop)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Strings.save) {
                        viewModel.createShop()
                    }
                    .disabled(viewModel.hasInvalidData)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Strings.cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}
