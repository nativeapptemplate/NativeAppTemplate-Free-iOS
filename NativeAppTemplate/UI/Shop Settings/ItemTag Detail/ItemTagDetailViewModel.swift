//
//  ItemTagDetailViewModel.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import SwiftUI
import Observation
import Photos
import CoreNFC

@Observable
@MainActor
final class ItemTagDetailViewModel {
  var isLocked = false
  var isShowingEditSheet = false
  var isShowingDeleteConfirmationDialog = false
  var isFetching = true
  var isGeneratingQrCode = false
  var isDeleting = false
  var customerTagQrCodeImage: UIImage?
  var shouldDismiss = false
  private(set) var itemTag: ItemTag?
  
  let itemTagRepository: ItemTagRepositoryProtocol
  let messageBus: MessageBus
  let sessionController: SessionControllerProtocol
  private let nfcManager: NFCManager
  private let qrCodeGenerator = QRCodeGenerator()
  private let imageSaver = ImageSaver()
  let shop: Shop
  let itemTagId: String
  
  init(
    itemTagRepository: ItemTagRepositoryProtocol,
    messageBus: MessageBus,
    sessionController: SessionControllerProtocol,
    nfcManager: NFCManager,
    shop: Shop,
    itemTagId: String
  ) {
    self.itemTagRepository = itemTagRepository
    self.messageBus = messageBus
    self.sessionController = sessionController
    self.nfcManager = nfcManager
    self.shop = shop
    self.itemTagId = itemTagId
  }
  
  var isBusy: Bool {
    isFetching || isDeleting || isGeneratingQrCode
  }
  
  func reload() {
    fetchItemTagDetail()
  }
  
  func generateCustomerQrCode() {
    guard let itemTag = itemTag else { return }
    
    isGeneratingQrCode = true
    
    let scanUrl = itemTag.scanUrl(itemTagType: ItemTagType.customer)
    
    customerTagQrCodeImage = qrCodeGenerator.generateWithCenterText(
      inputText: scanUrl.absoluteString,
      centerText: String(itemTag.queueNumber)
    )
    
    isGeneratingQrCode = false
  }
  
  func writeServerTag() {
    guard let itemTag = itemTag else { return }
    
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
    
    let ndefMessage = createNdefMessage(itemTag: itemTag, itemTagType: .server)
    
    Task {
      await nfcManager.startWriting(ndefMessage: ndefMessage, isLock: isLocked)
    }
  }
  
  func writeCustomerTag() {
    guard let itemTag = itemTag else { return }
    
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
    
    let ndefMessage = createNdefMessage(itemTag: itemTag, itemTagType: .customer)
    
    Task {
      await nfcManager.startWriting(ndefMessage: ndefMessage, isLock: isLocked)
    }
  }
  
  func saveImageToPhotoAlbum() {
    guard let customerTagQrCodeImage = customerTagQrCodeImage else { return }
    
    getSaveToPhotoAlbumPermissionIfNeeded { granted in
      guard granted else { return }
      
      self.imageSaver.save(image: customerTagQrCodeImage) { error in
        if let error {
          self.messageBus.post(
            message: Message(
              level: .error,
              message: "\(String.customerQrCodeImageSavedToPhotoAlbumError)(\(error))",
              autoDismiss: false
            )
          )
        } else {
          self.messageBus.post(message: Message(level: .success, message: .customerQrCodeImageSavedToPhotoAlbum))
        }
      }
    }
  }
  
  func destroyItemTag() {
    guard let itemTag = itemTag else { return }

    Task {
      isDeleting = true
      
      do {
        try await itemTagRepository.destroy(id: itemTag.id)
        messageBus.post(message: Message(level: .success, message: .itemTagDeleted))
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.itemTagDeletedError) \(error.localizedDescription)", autoDismiss: false))
      }
      
      shouldDismiss = true
    }
  }
  
  private func fetchItemTagDetail() {
    Task {
      do {
        isFetching = true
        itemTag = try await itemTagRepository.fetchDetail(id: itemTagId)
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
        shouldDismiss = true
      }
      
      isFetching = false
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
