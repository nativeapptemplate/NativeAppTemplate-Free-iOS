//
//  ScanViewModel.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/15.
//

import SwiftUI
import Observation
import CoreNFC

@Observable
@MainActor
final class ScanViewModel {
  var scanType: ScanType = .completeScan
  var isShowingResetConfirmationDialog = false
  var isFetching = false
  var isResetting = false
  
  private let itemTagRepository: ItemTagRepositoryProtocol
  private let sessionController: SessionControllerProtocol
  private let messageBus: MessageBus
  private let nfcManager: NFCManagerProtocol
  
  init(
    itemTagRepository: ItemTagRepositoryProtocol,
    sessionController: SessionControllerProtocol,
    messageBus: MessageBus,
    nfcManager: NFCManagerProtocol
  ) {
    self.itemTagRepository = itemTagRepository
    self.sessionController = sessionController
    self.messageBus = messageBus
    self.nfcManager = nfcManager
  }
  
  var isBusy: Bool {
    isFetching || isResetting
  }
  
  func handleBackgroundTagReading() {
    if sessionController.didBackgroundTagReading {
      sessionController.didBackgroundTagReading = false
      scanType = .completeScan
    }
  }
  
  func handleScanResultChanged() {
    guard nfcManager.isScanResultChanged else { return }
    guard nfcManager.scanResult != nil else { return }
    
    switch nfcManager.scanResult {
    case .success(let itemTagData):
      completeTag(itemTagId: itemTagData.itemTagId)
    case .failure(let error):
      sessionController.completeScanResult = CompleteScanResult(
        type: .failed,
        message: error.localizedDescription
      )
    default:
      break
    }
  }
  
  func handleScanResultChangedForTesting() {
    guard nfcManager.isScanResultChangedForTesting else { return }
    guard nfcManager.scanResult != nil else { return }
    
    switch nfcManager.scanResult {
    case .success(let itemTagData):
      fetchItemTagDetail(itemTagData: itemTagData)
    case .failure(let error):
      sessionController.showTagInfoScanResult = ShowTagInfoScanResult(
        type: .failed,
        message: error.localizedDescription
      )
    default:
      break
    }
  }
  
  func startCompleteScan() {
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
    
    sessionController.completeScanResult = CompleteScanResult()
    
    Task {
      await nfcManager.startReading()
    }
  }
  
  func startTestScan() {
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
    
    sessionController.showTagInfoScanResult = ShowTagInfoScanResult()
    
    Task {
      await nfcManager.startReadingForTesting()
    }
  }
  
  func resetTag() {
    guard let itemTagId = sessionController.completeScanResult.itemTag?.id else { return }
    resetTag(itemTagId: itemTagId)
  }
  
  func dismissResetConfirmationDialog() {
    isShowingResetConfirmationDialog = false
  }
  
  private func completeTag(itemTagId: String) {
    Task {
      do {
        let itemTag = try await itemTagRepository.complete(id: itemTagId)
        
        sessionController.completeScanResult = CompleteScanResult(
          itemTag: itemTag,
          type: .completed
        )
        
        if itemTag.alreadyCompleted! {
          isShowingResetConfirmationDialog = true
        }
      } catch {
        sessionController.completeScanResult = CompleteScanResult(
          type: .failed,
          message: error.localizedDescription
        )
      }
    }
  }
  
  private func resetTag(itemTagId: String) {
    Task {
      isResetting = true
      
      do {
        let itemTag = try await itemTagRepository.reset(id: itemTagId)
        sessionController.completeScanResult = CompleteScanResult(
          itemTag: itemTag,
          type: .reset
        )
      } catch {
        sessionController.completeScanResult = CompleteScanResult(
          type: .failed,
          message: error.localizedDescription
        )
      }
      
      isResetting = false
    }
  }
  
  private func fetchItemTagDetail(itemTagData: ItemTagData) {
    Task {
      isFetching = true
      
      do {
        let itemTag = try await itemTagRepository.fetchDetail(id: itemTagData.itemTagId)
        
        sessionController.showTagInfoScanResult = ShowTagInfoScanResult(
          itemTag: itemTag,
          itemTagType: itemTagData.itemTagType,
          isReadOnly: itemTagData.isReadOnly,
          type: .succeeded,
          scannedAt: itemTagData.scannedAt
        )
      } catch {
        sessionController.showTagInfoScanResult = ShowTagInfoScanResult(
          type: .failed,
          message: error.localizedDescription
        )
      }
      
      isFetching = false
    }
  }
}
