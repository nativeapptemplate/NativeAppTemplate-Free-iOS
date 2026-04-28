//
//  ShopkeeperEditView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ShopkeeperEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) var openURL
    @State private var viewModel: ShopkeeperEditViewModel

    init(viewModel: ShopkeeperEditViewModel) {
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

private extension ShopkeeperEditView {
    var contentView: some View {
        @ViewBuilder var contentView: some View {
            if viewModel.isBusy {
                LoadingView()
            } else {
                shopkeeperEditView
            }
        }

        return contentView
    }

    var shopkeeperEditView: some View {
        Form {
            Section {
                TextField(Strings.placeholderFullName, text: $viewModel.name)
            } header: {
                Text(Strings.fullName)
            } footer: {
                Text(Strings.fullNameIsRequired)
                    .foregroundStyle(Utility.isBlank(viewModel.name) ? .validationError : .clear)
            }

            Section {
                TextField(Strings.placeholderEmail, text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
            } header: {
                Text(Strings.email)
            } footer: {
                if Utility.isBlank(viewModel.email) {
                    Text(Strings.emailIsRequired)
                        .foregroundStyle(.validationError)
                } else if viewModel.hasInvalidDataEmail {
                    Text(Strings.emailIsInvalid)
                        .foregroundStyle(.validationError)
                }
            }

            Section {
                Picker(Strings.timeZone, selection: $viewModel.selectedTimeZone) {
                    ForEach(timeZones.keys, id: \.self) { key in
                        Text(timeZones[key]!).tag(key)
                    }
                }
            }

            Spacer()
                .listRowBackground(Color.clear)

            Section {
                MainButtonView(title: Strings.deleteMyAccount, type: .destructive(withArrow: false)) {
                    viewModel.isShowingDeleteConfirmationDialog = true
                }
                .listRowBackground(Color.clear)
            }
        }
        .alert(
            Strings.deleteMyAccount,
            isPresented: $viewModel.isShowingDeleteConfirmationDialog
        ) {
            Button(Strings.deleteMyAccount, role: .destructive) {
                viewModel.destroyShopkeeper()
            }

            Button(Strings.cancel, role: .cancel) {
                viewModel.isShowingDeleteConfirmationDialog = false
            }
        } message: {
            Text(Strings.areYouSure)
        }
        .navigationTitle(Strings.editProfile)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.updateShopkeeper()
                } label: {
                    Text(Strings.save)
                }
                .disabled(viewModel.hasInvalidData)
            }
        }
    }
}
