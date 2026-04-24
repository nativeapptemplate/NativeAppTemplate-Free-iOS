//
//  ItemTagDetailView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ItemTagDetailView: View {
    @Environment(\.dismiss) private var dismiss
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
        if viewModel.isBusy {
            LoadingView()
        } else if let itemTag = viewModel.itemTag {
            itemTagDetailView(itemTag: itemTag)
        }
    }

    func itemTagDetailView(itemTag: ItemTag) -> some View {
        VStack(alignment: .leading, spacing: NativeAppTemplateConstants.Spacing.md) {
            Text(itemTag.name)
                .font(.largeTitle)
                .bold()

            if !itemTag.description.isEmpty {
                Text(itemTag.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Text("State: \(itemTag.state.rawValue.capitalized)")
                .font(.subheadline)

            if let completedAt = itemTag.completedAt {
                Text("Completed at: \(completedAt.formatted())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .sheet(
            isPresented: $viewModel.isShowingEditSheet,
            onDismiss: {
                viewModel.reload()
            },
            content: {
                ItemTagEditView(
                    viewModel: ItemTagEditViewModel(
                        itemTagRepository: viewModel.itemTagRepository,
                        messageBus: viewModel.messageBus,
                        sessionController: viewModel.sessionController,
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
        .toolbar {
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
}
