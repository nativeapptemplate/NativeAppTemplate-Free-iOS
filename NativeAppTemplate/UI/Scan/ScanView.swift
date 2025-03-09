//
//  ScanView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI
import CoreNFC

enum ScanType: String {
  case completeScan
  case test
  
  var displayString: String {
    switch self {
    case .completeScan:
      return "Complete Scan"
    case .test:
      return "Test"
    }
  }
}

// MARK: - CaseIterable
extension ScanType: CaseIterable {
  var index: Self.AllCases.Index {
    get {
      Self.allCases.firstIndex(of: self)!
    }
    set {
      self = Self.allCases[newValue]
    }
  }
  
  var count: Int {
    Self.allCases.count
  }
}

// MARK: - Identifiable
extension ScanType: Identifiable {
  var id: Self { self }
}

struct ScanView: View {
  @Environment(MessageBus.self) private var messageBus
  @Environment(SessionController.self) private var sessionController
  @StateObject private var nfcManager = appSingletons.nfcManager
  @State private var scanType: ScanType = .completeScan
  @State private var isShowingResetConfirmationDialog = false
  @State private var isFetching = false
  @State private var isResetting = false
  private let itemTagRepository: ItemTagRepository
  
  init(
    itemTagRepository: ItemTagRepository
  ) {
    self.itemTagRepository = itemTagRepository
  }
  
  var body: some View {
    contentView
      .onChange(of: sessionController.didBackgroundTagReading) {
        Task { @MainActor in
          if sessionController.didBackgroundTagReading {
            sessionController.didBackgroundTagReading = false
            scanType = .completeScan
          }
        }
      }
  }
}

// MARK: - private
private extension ScanView {
  var contentView: some View {
    @ViewBuilder var contentView: some View {
      if isFetching {
        LoadingView()
      } else {
        scanView
          .onChange(of: nfcManager.isScanResultChanged) {
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
          .onChange(of: nfcManager.isScanResultChangedForTesting) {
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
      }
    }
    
    return contentView
  }
  
  var scanView: some View {
    ScrollView {
      VStack(spacing: 64) {
        switch scanType {
        case .completeScan:
          if !isShowingResetConfirmationDialog {
            GroupBox(label: Label(String.completeScan, systemImage: "flag.checkered") ) {
              MainButtonView(title: String.scan, type: .coloredPrimary(withArrow: false)) {
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
              .padding()
              
              Text(String.completeScanHelp)
                .font(.uiFootnote)
                .foregroundStyle(.coloredPrimaryFootnoteText)
            }
            .foregroundStyle(.coloredPrimaryForeground)
            .backgroundStyle(.coloredPrimaryBackground)
          }
          
          CompleteScanResultView(
            completeScanResult: sessionController.completeScanResult
          )
        case .test:
          GroupBox(label: Label(String.showTagInfoScan, systemImage: "info.circle") ) {
            MainButtonView(title: String.scan, type: .coloredSecondary(withArrow: false)) {
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
            .padding()
            
            Text(String.showTagInfoScanHelp)
              .font(.uiFootnote)
              .foregroundStyle(.coloredSecondaryFootnoteText)
          }
          .foregroundStyle(.coloredSecondaryForeground)
          .backgroundStyle(.coloredSecondaryBackground)
          
          ShowTagInfoScanResultView(
            showTagInfoScanResult: sessionController.showTagInfoScanResult
          )
        }
        
        Spacer()
      }
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Picker(String("ScanType"), selection: $scanType) {
          Text(String.completeScan).tag(ScanType.completeScan)
          Text(String.showTagInfoScan).tag(ScanType.test)
        }
        .pickerStyle(SegmentedPickerStyle())
      }
    }
    .toolbarBackground(.black, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .padding()
    .confirmationDialog(
      String.itemTagAlreadyCompleted,
      isPresented: $isShowingResetConfirmationDialog
    ) {
      Button(String.reset, role: .destructive) {
        if let itemTagId = sessionController.completeScanResult.itemTag?.id {
          resetTag(itemTagId: itemTagId)
        }
      }
      Button(String.cancel, role: .cancel) {
        isShowingResetConfirmationDialog = false
      }
    } message: {
      Text(String.areYouSure)
    }
    .accessibility(identifier: "scanView")
    .scrollContentBackground(.hidden)
  }
  
  func completeTag(itemTagId: String) {
    Task { @MainActor in
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
    Task { @MainActor in
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
