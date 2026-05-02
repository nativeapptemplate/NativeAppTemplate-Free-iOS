//
//  ShopSettingsView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ShopSettingsView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss
    @Environment(MessageBus.self) private var messageBus
    @State private var viewModel: ShopSettingsViewModel

    init(viewModel: ShopSettingsViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension ShopSettingsView {
    var body: some View {
        contentView
            .onChange(of: viewModel.shouldDismiss) {
                if viewModel.shouldDismiss {
                    dismiss()
                }
            }
            .task {
                reload()
            }
    }
}

// MARK: - private

private extension ShopSettingsView {
    var contentView: some View {
        @ViewBuilder var contentView: some View {
            if viewModel.isBusy {
                LoadingView()
            } else if let shop = viewModel.shop {
                shopSettingsView(shop: shop)
            }
        }

        return contentView
    }

    func shopSettingsView(shop: Shop) -> some View {
        VStack {
            Text(shop.name)
                .font(.uiTitle1)
                .foregroundStyle(.titleText)
                .padding(.top, NativeAppTemplateConstants.Spacing.md)

            List {
                Section {
                    NavigationLink {
                        ShopBasicSettingsView(
                            viewModel: ShopBasicSettingsViewModel(
                                sessionController: dataManager.sessionController,
                                shopRepository: dataManager.shopRepository,
                                messageBus: messageBus,
                                shopId: viewModel.shopId
                            )
                        )
                    } label: {
                        Label(Strings.shopSettingsBasicSettingsLabel, systemImage: "storefront")
                    }
                    .listRowBackground(Color.cardBackground.opacity(0.7))
                }

                Section {
                    NavigationLink {
                        ItemTagListView(
                            viewModel: ItemTagListViewModel(
                                itemTagRepository: dataManager.itemTagRepository,
                                messageBus: messageBus,
                                sessionController: dataManager.sessionController,
                                shop: shop
                            )
                        )
                    } label: {
                        Label(Strings.shopSettingsManageItemTagsLabel, systemImage: "rectangle.stack")
                    }
                    .listRowBackground(Color.cardBackground.opacity(0.7))
                }

                Section {
                    MainButtonView(title: Strings.deleteShop, type: .destructive(withArrow: false)) {
                        viewModel.isShowingDeleteConfirmationDialog = true
                    }
                    .listRowBackground(Color.clear)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .padding(.top)
            }
            .refreshable {
                reload()
            }
        }
        .navigationTitle(Strings.shopSettingsLabel)
        .alert(
            Strings.deleteShop,
            isPresented: $viewModel.isShowingDeleteConfirmationDialog
        ) {
            Button(Strings.deleteShop, role: .destructive) {
                viewModel.destroyShop()
            }
            Button(Strings.cancel, role: .cancel) {
                viewModel.isShowingDeleteConfirmationDialog = false
            }
        } message: {
            Text(Strings.areYouSure)
        }
    }

    func reload() {
        viewModel.reload()
    }
}
