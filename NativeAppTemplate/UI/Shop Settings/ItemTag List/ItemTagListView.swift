//
//  ItemTagListView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ItemTagListView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(MessageBus.self) private var messageBus
    @State private var viewModel: ItemTagListViewModel

    init(viewModel: ItemTagListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        contentView
            .task {
                viewModel.reload()
            }
    }
}

// MARK: - private

private extension ItemTagListView {
    var contentView: some View {
        @ViewBuilder var contentView: some View {
            if viewModel.isBusy {
                LoadingView()
            } else {
                switch viewModel.state {
                case .initial, .loading:
                    LoadingView()
                case .hasData:
                    itemTagListView
                case .failed:
                    reloadView
                }
            }
        }

        return contentView
    }

    var itemTagListView: some View {
        VStack {
            Text(viewModel.shop.name)
                .font(.uiTitle1)
                .foregroundStyle(.titleText)
                .padding(.top, NativeAppTemplateConstants.Spacing.md)
                .multilineTextAlignment(.center)

            if viewModel.isEmpty {
                noResultsView
            } else {
                List {
                    ForEach(viewModel.itemTags) { itemTag in
                        NavigationLink(
                            destination: ItemTagDetailView(
                                viewModel: ItemTagDetailViewModel(
                                    itemTagRepository: dataManager.itemTagRepository,
                                    messageBus: messageBus,
                                    sessionController: dataManager.sessionController,
                                    shop: viewModel.shop,
                                    itemTagId: itemTag.id
                                )
                            )
                        ) {
                            ItemTagListCardView(
                                itemTag: itemTag
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) { viewModel.destroyItemTag(itemTagId: itemTag.id) } label: {
                                    Label(String.delete, systemImage: "trash")
                                        .labelStyle(.titleOnly)
                                }
                                .tint(.validationError)
                            }
                        }
                        .listRowBackground(Color.cardBackground.opacity(0.7))
                    }

                    if viewModel.hasMorePages {
                        loadMoreRow
                    }
                }
                .refreshable {
                    viewModel.reload()
                }
            }
        }
        .navigationTitle(String.shopSettingsManageItemTagsLabel)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isShowingCreateSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(
            isPresented: $viewModel.isShowingCreateSheet,
            onDismiss: {
                viewModel.reload()
            },
            content: {
                ItemTagCreateView(
                    viewModel: ItemTagCreateViewModel(
                        itemTagRepository: dataManager.itemTagRepository,
                        messageBus: messageBus,
                        shopId: viewModel.shop.id
                    )
                )
            }
        )
    }

    var loadMoreRow: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding(NativeAppTemplateConstants.Spacing.xxs)
            Spacer()
        }
        .listRowBackground(Color.clear)
        .onAppear {
            viewModel.loadMore()
        }
    }

    var noResultsView: some View {
        VStack {
            Image(systemName: "01.square")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: NativeAppTemplateConstants.Spacing.xxxl)
                .padding()
            Text(String.addItemTagDescription)
                .foregroundStyle(.contentText)
                .padding()

            MainButtonView(title: String.addItemTag, type: .primary(withArrow: false)) {
                viewModel.isShowingCreateSheet.toggle()
            }
            .padding()

            Spacer()
        }
        .padding()
    }

    var reloadView: some View {
        ErrorView(buttonAction: viewModel.reload)
    }
}
