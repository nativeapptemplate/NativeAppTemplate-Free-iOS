//
//  ShopListView.swift
//  NativeAppTemplate
//

import SwiftUI
import TipKit

struct TapShopBelowTip: Tip {
    var title: Text {
        Text(String.tapShopBelow)
    }

    var message: Text? {
        Text(String.haveFun)
    }

    var image: Image? {
        Image(systemName: "info.circle")
    }
}

struct ShopListView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(TabViewModel.self) private var tabViewModel
    @Environment(\.mainTab) private var mainTab
    @Environment(MessageBus.self) private var messageBus

    @State private var viewModel: ShopListViewModel

    init(viewModel: ShopListViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
}

extension ShopListView {
    var body: some View {
        contentView
            .task {
                viewModel.reload()
            }
            .onAppear {
                viewModel.setTabViewModelShowingDetailViewToFalse()
            }
            .onChange(of: viewModel.state) {
                if viewModel.state == .initial {
                    viewModel.reload()
                }
            }
            // Avoid showing deleted shop.
            .onChange(of: viewModel.shouldPopToRootView) {
                Task {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    viewModel.reload()
                }
            }
    }
}

// MARK: - private

private extension ShopListView {
    var contentView: some View {
        @ViewBuilder var contentView: some View {
            switch viewModel.state {
            case .initial, .loading:
                LoadingView()
            case .hasData:
                shopListView
            case .failed:
                reloadView
            }
        }

        return contentView
    }

    var cardsView: some View {
        ForEach(viewModel.shops) { shop in
            NavigationLink(value: shop) {
                ShopListCardView(shop: shop)
            }
            .listRowBackground(Color.cardBackground.opacity(0.7))
        }
    }

    var shopListView: some View {
        VStack {
            if viewModel.isEmpty {
                noResultsView(leftInShopSlots: viewModel.leftInShopSlots)
            } else {
                List {
                    Section {
                        cardsView
                    } header: {
                        let tip = TapShopBelowTip()
                        TipView(tip, arrowEdge: .bottom)
                            .tint(.alarm)

                        EmptyView()
                            .id(viewModel.scrollToTopID())
                    } footer: {
                        VStack(spacing: 0) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(String(viewModel.leftInShopSlots))
                                    .font(.uiLabelBold)
                                Text(verbatim: "left in shop slots.")
                                    .font(.uiFootnote)
                            }
                        }
                    }
                }
                .navigationDestination(for: Shop.self) { shop in
                    ShopDetailView(
                        viewModel: ShopDetailViewModel(
                            sessionController: dataManager.sessionController,
                            shopRepository: dataManager.shopRepository,
                            itemTagRepository: dataManager.itemTagRepository,
                            tabViewModel: tabViewModel,
                            mainTab: mainTab,
                            messageBus: messageBus,
                            shopId: shop.id
                        )
                    )
                }
                .accessibility(identifier: "shopListView")
                .refreshable {
                    viewModel.reload()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(String.shops)
                        .font(.uiHeadline)
                    if !viewModel.accountName.isEmpty {
                        Text(viewModel.accountName)
                            .font(.uiCaption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if viewModel.leftInShopSlots > 0 {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showCreateView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(
            isPresented: $viewModel.isShowingCreateSheet,
            onDismiss: {
                viewModel.reload()
            },
            content: {
                ShopCreateView(
                    viewModel: ShopCreateViewModel(
                        sessionController: dataManager.sessionController,
                        shopRepository: dataManager.shopRepository,
                        messageBus: messageBus
                    )
                )
            }
        )
    }

    var reloadView: some View {
        ErrorView(buttonAction: viewModel.reload)
    }

    func noResultsView(leftInShopSlots: Int) -> some View {
        VStack {
            if leftInShopSlots > 0 {
                Image(systemName: "storefront")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: NativeAppTemplateConstants.Spacing.xxxl)
                    .padding()

                Text(String.addShopDescription)
                    .foregroundStyle(.contentText)
                    .padding()

                MainButtonView(title: String.addShop, type: .primary(withArrow: false)) {
                    viewModel.showCreateView()
                }
                .padding()

                Spacer()
            } else {
                Image(systemName: "externaldrive.badge.exclamationmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: NativeAppTemplateConstants.Spacing.xxxl)
                    .padding()

                HStack(alignment: .firstTextBaseline) {
                    Text(String(leftInShopSlots))
                        .font(.uiTitle3)
                    Text(verbatim: "left in shop slots.")
                        .foregroundStyle(.contentText)
                }
                .padding()

                Spacer()
            }
        }
        .padding()
    }
}
