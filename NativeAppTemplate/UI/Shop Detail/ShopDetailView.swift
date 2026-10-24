//
//  ShopDetailView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ShopDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ShopDetailViewModel

    init(viewModel: ShopDetailViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
}

// MARK: - View

extension ShopDetailView {
    var body: some View {
        contentView
            .onAppear {
                viewModel.setTabViewModelShowingDetailViewToTrue()
            }
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

private extension ShopDetailView {
    var contentView: some View {
        @ViewBuilder var contentView: some View {
            if viewModel.isBusy {
                LoadingView()
            } else if viewModel.shop != nil {
                shopDetailView
            }
        }

        return contentView
    }

    var header: some View {
        Text(Strings.shopDetailInstruction)
            .foregroundStyle(.contentText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
    }

    var cardsView: some View {
        ForEach(viewModel.itemTags, id: \.id) { itemTag in
            ShopDetailCardView(itemTag: itemTag)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if itemTag.state == ItemTagState.idled {
                        Button { viewModel.completeTag(itemTagId: itemTag.id) } label: {
                            Label(Strings.complete, systemImage: "bolt.fill")
                                .labelStyle(.titleOnly)
                        }
                        .tint(.blue)
                    } else {
                        Button(role: .destructive) { viewModel.idleTag(itemTagId: itemTag.id) } label: {
                            Label(Strings.idle, systemImage: "trash")
                                .labelStyle(.titleOnly)
                        }
                        .tint(.validationError)
                    }
                }
                .listRowBackground(Color.cardBackground.opacity(0.7))
        }
    }

    var shopDetailView: some View {
        VStack {
            header
                .padding(.top)
                .padding(.horizontal, NativeAppTemplateConstants.Spacing.xxs)
            List {
                Section {
                    cardsView
                } header: {
                    EmptyView()
                        .id(viewModel.scrollToTopID())
                }
            }
            .scrollContentBackground(.hidden)
            .accessibility(identifier: "shopDetailView")
            .refreshable {
                viewModel.reload()
            }
        }
        .navigationTitle(viewModel.shop?.name ?? "")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: ShopSettingsView(
                        viewModel: viewModel.createShopSettingsViewModel()
                    )
                ) {
                    Image(systemName: "gearshape.fill")
                }
                .accessibilityLabel(Strings.shopSettingsLabel)
            }
        }
    }
}
