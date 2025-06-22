//
//  ItemTagDetailView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI
import Photos
import CoreNFC

struct ItemTagDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var viewModel: ItemTagDetailViewModel
  
  init(viewModel: ItemTagDetailViewModel) {
    self._viewModel = State(wrappedValue: viewModel)
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
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if viewModel.isBusy {
        LoadingView()
      } else {
        itemTagDetailView
      }
    }
    
    return contentView
  }
  
  private var itemTagDetailView: some View {
    ScrollView {
      VStack(alignment: .center) {
        VStack(alignment: .center, spacing: 0) {
          Text(verbatim: "Write Info to Tag / Save Customer QR code")
            .font(.title2)
            .padding(.top, 8)
          
          Text(viewModel.shop.name)
            .font(.title3)
            .padding(.top, 16)
          
          if let itemTag = viewModel.itemTag {
            Text(String(itemTag.queueNumber))
              .font(.largeTitle)
              .bold()
              .padding(.top, 8)
              .foregroundStyle(.lightestAccent)
          }
        }
        
        GroupBox(label: Label(String("Lock"), systemImage: "lock") ) {
          Toggle(isOn: $viewModel.isLocked) {
            Text(verbatim: "Lock")
          }
          .dynamicTypeSize(...DynamicTypeSize.large)
          .frame(width: 96)
          .tint(.lockForeground)
          
          if viewModel.isLocked {
            Text(String.youCannotUndoAfterLockingTag)
              .font(.uiFootnote)
              .foregroundStyle(.alarm)
          }
        }
        .foregroundStyle(.lockForeground)
        .backgroundStyle(.lockBackground)
        
        GroupBox(label: Label(String("Server"), systemImage: "storefront") ) {
          MainButtonView(title: String.writeServerTag, type: .server(withArrow: false)) {
            viewModel.writeServerTag()
          }
          .padding()
        }
        .foregroundStyle(.serverForeground)
        .backgroundStyle(.serverBackground)
        
        GroupBox(label: Label(String("Customer"), systemImage: "person.2") ) {
          MainButtonView(title: String.writeCustomerTag, type: .customer(withArrow: false)) {
            viewModel.writeCustomerTag()
          }
          .padding()
          
          if let customerTagQrCodeImage = viewModel.customerTagQrCodeImage {
            Image(uiImage: customerTagQrCodeImage)
              .resizable()
              .frame(width: 96, height: 96)
            
            Button {
              viewModel.saveImageToPhotoAlbum()
            } label: {
              Text(String.saveToPhotoAlbum)
            }
          } else {
            generateCustomerQrCodeView
          }
        }
        .padding(.top, 24)
        .foregroundStyle(.customerForeground)
        .backgroundStyle(.customerBackground)
      }
    }
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
    .confirmationDialog(
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
  
  private var generateCustomerQrCodeView: some View {
    VStack {
      Button {
        viewModel.generateCustomerQrCode()
      } label: {
        Text(String.generateCustomerQrCode)
      }
    }
  }
}
