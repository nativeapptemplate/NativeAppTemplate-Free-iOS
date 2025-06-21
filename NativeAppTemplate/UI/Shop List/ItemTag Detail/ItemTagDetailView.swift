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
  @Environment(MessageBus.self) private var messageBus
  @Environment(\.sessionController) private var sessionController
  private var itemTagRepository: ItemTagRepositoryProtocol
  @StateObject private var nfcManager = appSingletons.nfcManager
  @State private var isLocked = false
  @State private var isShowingEditSheet = false
  @State private var isShowingDeleteConfirmationDialog = false
  @State private var isFetching = true
  @State private var isGeneratingQrCode = false
  @State private var isDeleting = false
  @State private var customerTagQrCodeImage: UIImage?
  private let qrCodeGenerator = QRCodeGenerator()
  private let imageSaver = ImageSaver()
  
  private var shop: Shop
  private var itemTagId: String
  
  private var itemTag: Binding<ItemTag> {
    Binding {
      itemTagRepository.findBy(id: itemTagId)
    } set: { _ in
    }
  }
  
  init(
    itemTagRepository: ItemTagRepositoryProtocol,
    shop: Shop,
    itemTagId: String
  ) {
    self.itemTagRepository = itemTagRepository
    self.shop = shop
    self.itemTagId = itemTagId
  }
  
  var body: some View {
    contentView
      .task {
        reload()
      }
  }
}

// MARK: - private
private extension ItemTagDetailView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if isFetching || isDeleting || isGeneratingQrCode {
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
          
          Text(shop.name)
            .font(.title3)
            .padding(.top, 16)
          
          Text(String(itemTag.wrappedValue.queueNumber))
            .font(.largeTitle)
            .bold()
            .padding(.top, 8)
            .foregroundStyle(.lightestAccent)
        }
        
        GroupBox(label: Label(String("Lock"), systemImage: "lock") ) {
          Toggle(isOn: $isLocked) {
            Text(verbatim: "Lock")
          }
          .dynamicTypeSize(...DynamicTypeSize.large)
          .frame(width: 96)
          .tint(.lockForeground)
          
          if isLocked {
            Text(String.youCannotUndoAfterLockingTag)
              .font(.uiFootnote)
              .foregroundStyle(.alarm)
          }
        }
        .foregroundStyle(.lockForeground)
        .backgroundStyle(.lockBackground)
        
        GroupBox(label: Label(String("Server"), systemImage: "storefront") ) {
          MainButtonView(title: String.writeServerTag, type: .server(withArrow: false)) {
            guard NFCNDEFReaderSession.readingAvailable else {
              messageBus.post(
                message: Message(
                  level: .error,
                  message: String.thisDeviceDoesNotSupportTagScanning,
                  autoDismiss: false
                )
              )
              return
            }
            
            let ndefMessage = createNdefMessage(itemTag: itemTag.wrappedValue, itemTagType: .server)
            
            Task {
              await nfcManager.startWriting(ndefMessage: ndefMessage, isLock: isLocked)
            }
          }
          .padding()
        }
        .foregroundStyle(.serverForeground)
        .backgroundStyle(.serverBackground)
        
        GroupBox(label: Label(String("Customer"), systemImage: "person.2") ) {
          MainButtonView(title: String.writeCustomerTag, type: .customer(withArrow: false)) {
            guard NFCNDEFReaderSession.readingAvailable else {
              messageBus.post(
                message: Message(
                  level: .error,
                  message: String.thisDeviceDoesNotSupportTagScanning,
                  autoDismiss: false
                )
              )
              return
            }
            
            let ndefMessage = createNdefMessage(itemTag: itemTag.wrappedValue, itemTagType: .customer)
            
            Task {
              await nfcManager.startWriting(ndefMessage: ndefMessage, isLock: isLocked)
            }
          }
          .padding()
          
          if let customerTagQrCodeImage = customerTagQrCodeImage {
            Image(uiImage: customerTagQrCodeImage)
              .resizable()
              .frame(width: 96, height: 96)
            
            Button {
              getSaveToPhotoAlbumPermissionIfNeeded { granted in
                guard granted else { return }
                
                imageSaver.save(image: customerTagQrCodeImage) { error in
                  if let error {
                    messageBus.post(
                      message: Message(
                        level: .error,
                        message: "\(String.customerQrCodeImageSavedToPhotoAlbumError)(\(error))",
                        autoDismiss: false
                      )
                    )
                  } else {
                    messageBus.post(message: Message(level: .success, message: .customerQrCodeImageSavedToPhotoAlbum))
                  }
                }
              }
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
      isPresented: $isShowingEditSheet,
      onDismiss: {
        reload()
      },
      content: {
        ItemTagEditView(itemTagRepository: itemTagRepository, itemTagId: itemTagId)
      }
    )
    .confirmationDialog(
      String.buttonDeleteTag,
      isPresented: $isShowingDeleteConfirmationDialog
    ) {
      Button(String.buttonDeleteTag, role: .destructive) {
        destroyItemTag()
      }
      Button(String.cancel, role: .cancel) {
        isShowingDeleteConfirmationDialog = false
      }
    } message: {
      Text(String.areYouSure)
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          isShowingEditSheet.toggle()
        } label: {
          Text(String.edit)
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          isShowingDeleteConfirmationDialog.toggle()
        } label: {
          Image(systemName: "trash")
        }
      }
    }
  }
  
  private func reload() {
    fetchItemTagDetail()
  }
  
  private func reloadCustomerTagQrCodeImage() {
    isGeneratingQrCode = true
    
    let scanUrl = itemTag.wrappedValue.scanUrl(itemTagType: ItemTagType.customer)
    
    customerTagQrCodeImage = qrCodeGenerator.generateWithCenterText(
      inputText: scanUrl.absoluteString,
      centerText: String(itemTag.wrappedValue.queueNumber)
    )
    
    isGeneratingQrCode = false
  }
  
  private func fetchItemTagDetail() {
    Task { @MainActor in
      do {
        isFetching = true
        _ = try await itemTagRepository.fetchDetail(id: itemTagId)
        isFetching = false
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
        dismiss()
      }
    }
  }
  
  private var generateCustomerQrCodeView: some View {
    VStack {
      Button {
        reloadCustomerTagQrCodeImage()
      } label: {
        Text(String.generateCustomerQrCode)
      }
    }
  }
  
  private func destroyItemTag() {
    Task { @MainActor in
      isDeleting = true
      
      do {
        try await itemTagRepository.destroy(id: itemTag.id)
        messageBus.post(message: Message(level: .success, message: .itemTagDeleted))
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.itemTagDeletedError) \(error.localizedDescription)", autoDismiss: false))
      }
      
      dismiss()
    }
  }
  
  private func createNdefMessage(itemTag: ItemTag, itemTagType: ItemTagType) -> NFCNDEFMessage {
    let scanUrl = itemTag.scanUrl(itemTagType: itemTagType)
    let urlPayload = NFCNDEFPayload.wellKnownTypeURIPayload(url: scanUrl)
    let androidAarPayloadData = String.androidAar.data(using: .utf8)!
    let androidAarPayload = NFCNDEFPayload(format: .nfcExternal, type: Data(String.androidAarNfcndefPayloadType.utf8), identifier: Data(), payload: androidAarPayloadData)
    
    let ndefMessage = if itemTagType == ItemTagType.server {
      NFCNDEFMessage(records: [urlPayload!, androidAarPayload])
    } else {
      NFCNDEFMessage(records: [urlPayload!])
    }
    
    return ndefMessage
  }
  
  private func getSaveToPhotoAlbumPermissionIfNeeded(completionHandler: @escaping (Bool) -> Void) {
    guard PHPhotoLibrary.authorizationStatus(for: .addOnly) != .authorized else {
      completionHandler(true)
      return
    }
    
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
      completionHandler(status == .authorized ? true : false)
    }
  }
}
