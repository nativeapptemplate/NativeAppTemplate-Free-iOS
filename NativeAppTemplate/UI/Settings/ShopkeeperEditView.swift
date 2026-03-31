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
                TextField(String.placeholderFullName, text: $viewModel.name)
            } header: {
                Text(String.fullName)
            } footer: {
                Text(String.fullNameIsRequired)
                    .foregroundStyle(Utility.isBlank(viewModel.name) ? .validationError : .clear)
            }

            Section {
                TextField(String.placeholderEmail, text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
            } header: {
                Text(String.email)
            } footer: {
                if Utility.isBlank(viewModel.email) {
                    Text(String.emailIsRequired)
                        .foregroundStyle(.validationError)
                } else if viewModel.hasInvalidDataEmail {
                    Text(String.emailIsInvalid)
                        .foregroundStyle(.validationError)
                }
            }

            Section {
                Picker(String.timeZone, selection: $viewModel.selectedTimeZone) {
                    ForEach(timeZones.keys, id: \.self) { key in
                        Text(timeZones[key]!).tag(key)
                    }
                }
            }

            Spacer()
                .listRowBackground(Color.clear)

            Section {
                MainButtonView(title: String.deleteMyAccount, type: .destructive(withArrow: false)) {
                    viewModel.isShowingDeleteConfirmationDialog = true
                }
                .listRowBackground(Color.clear)
            }
        }
        .confirmationDialog(
            String.deleteMyAccount,
            isPresented: $viewModel.isShowingDeleteConfirmationDialog
        ) {
            Button(String.deleteMyAccount, role: .destructive) {
                viewModel.destroyShopkeeper()
            }

            Button(String.cancel, role: .cancel) {
                viewModel.isShowingDeleteConfirmationDialog = false
            }
        } message: {
            Text(String.areYouSure)
        }
        .navigationTitle(String.editProfile)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.updateShopkeeper()
                } label: {
                    Text(String.save)
                }
                .disabled(viewModel.hasInvalidData)
            }
        }
    }
}
