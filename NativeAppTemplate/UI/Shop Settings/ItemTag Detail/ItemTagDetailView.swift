//
//  ItemTagDetailView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ItemTagDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DataManager.self) private var dataManager
    @Environment(MessageBus.self) private var messageBus
    @State private var viewModel: ItemTagDetailViewModel

    init(viewModel: ItemTagDetailViewModel) {
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

private extension ItemTagDetailView {
    @ViewBuilder var contentView: some View {
        if viewModel.isBusy, viewModel.itemTag == nil {
            LoadingView()
        } else if let itemTag = viewModel.itemTag {
            itemTagDetailView(itemTag: itemTag)
        }
    }

    func itemTagDetailView(itemTag: ItemTag) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: NativeAppTemplateConstants.Spacing.md) {
                headerRow(itemTag: itemTag)
                descriptionSection(itemTag: itemTag)
                completedAtRow(itemTag: itemTag)
                stateToggleButton(itemTag: itemTag)

                Spacer()
            }
            .padding()
        }
        .sheet(
            isPresented: $viewModel.isShowingEditSheet,
            onDismiss: {
                viewModel.reload()
            },
            content: {
                ItemTagEditView(
                    viewModel: ItemTagEditViewModel(
                        itemTagRepository: dataManager.itemTagRepository,
                        messageBus: messageBus,
                        itemTagId: viewModel.itemTagId
                    )
                )
            }
        )
        .alert(
            String.buttonDeleteTag,
            isPresented: $viewModel.isShowingDeleteConfirmationDialog
        ) {
            Button(String.buttonDeleteTag, role: .destructive) {
                viewModel.destroyItemTag()
            }
            Button(String.cancel, role: .cancel) {
                viewModel.isShowingDeleteConfirmationDialog = false
            }
        } message: {
            Text(String.areYouSure)
        }
        .toolbar { toolbarContent }
    }

    func headerRow(itemTag: ItemTag) -> some View {
        HStack {
            Text(itemTag.name)
                .font(.largeTitle)
                .bold()

            Spacer()

            if itemTag.state == .completed {
                CompletedTag()
            } else {
                IdlingTag()
            }
        }
    }

    @ViewBuilder
    func descriptionSection(itemTag: ItemTag) -> some View {
        if !itemTag.description.isEmpty {
            VStack(alignment: .leading, spacing: NativeAppTemplateConstants.Spacing.xxs) {
                Text(String.descriptionLabel)
                    .font(.uiTitle4)
                    .foregroundStyle(.titleText)
                Text(itemTag.description)
                    .font(.body)
                    .foregroundStyle(.contentText)
            }
        }
    }

    @ViewBuilder
    func completedAtRow(itemTag: ItemTag) -> some View {
        if let completedAt = itemTag.completedAt, itemTag.state == .completed {
            HStack {
                Text(String.completedAtLabel)
                    .font(.uiFootnote)
                    .foregroundStyle(.contentText)
                Text(completedAt.cardDateTimeString)
                    .font(.uiFootnote)
                    .foregroundStyle(.contentText)
            }
        }
    }

    @ViewBuilder
    func stateToggleButton(itemTag: ItemTag) -> some View {
        if itemTag.state == .idled {
            MainButtonView(
                title: String.markAsCompleted,
                type: .primary(withArrow: false)
            ) {
                viewModel.completeItemTag()
            }
            .disabled(viewModel.isToggling)
        } else {
            MainButtonView(
                title: String.markAsIdled,
                type: .secondary(withArrow: false)
            ) {
                viewModel.idleItemTag()
            }
            .disabled(viewModel.isToggling)
        }
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewModel.isShowingEditSheet.toggle()
            } label: {
                Text(String.edit)
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewModel.isShowingDeleteConfirmationDialog.toggle()
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}
