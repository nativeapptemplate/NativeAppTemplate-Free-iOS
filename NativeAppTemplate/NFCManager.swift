//
//  NFCManager.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import Foundation
import CoreNFC

protocol NFCManagerProtocol: Sendable {
  @MainActor var scanResult: Result<ItemTagData, Error>? { get }
  @MainActor var isScanResultChanged: Bool { get }
  @MainActor var isScanResultChangedForTesting: Bool { get }

  func startReading() async
  func startReadingForTesting() async

  func startWriting(ndefMessage: sending NFCNDEFMessage, isLock: Bool) async
}

final class NFCManager: NSObject, ObservableObject, @unchecked Sendable {
  @MainActor static let shared = NFCManager()

  @MainActor @Published var scanResult: Result<ItemTagData, Error>?
  @MainActor @Published var isScanResultChanged = false
  @MainActor @Published var isScanResultChangedForTesting = false

  private var internalScanResult: Result<ItemTagData, Error>? {
    @Sendable didSet {
      Task { [internalScanResult] in
        await MainActor.run {
          self.scanResult = internalScanResult
        }
      }
    }
  }

  private var internalIsScanResultChanged: Bool = false {
    @Sendable didSet {
      Task { [internalIsScanResultChanged] in
        await MainActor.run {
          self.isScanResultChanged = internalIsScanResultChanged
        }
      }
    }
  }

  private var internalIsScanResultChangedForTesting: Bool = false {
    @Sendable didSet {
      Task { [internalIsScanResultChangedForTesting] in
        await MainActor.run {
          self.isScanResultChangedForTesting = internalIsScanResultChangedForTesting
        }
      }
    }
  }

  enum NFCOperation {
    case read
    case readForTesting
    case write
  }

  var nfcSession: NFCNDEFReaderSession?
  var nfcOperation = NFCOperation.read
  private var userNdefMessage: NFCNDEFMessage?
  private var isLock = false

  @MainActor override init() {
  }
}

extension NFCManager: NFCManagerProtocol {
  func startReading() async {
    internalScanResult = nil
    internalIsScanResultChanged = false
    nfcOperation = .read
    startSesstion()
  }

  func startReadingForTesting() async {
    internalScanResult = nil
    internalIsScanResultChangedForTesting = false
    nfcOperation = .readForTesting
    startSesstion()
  }

  func startWriting(ndefMessage: NFCNDEFMessage, isLock: Bool) async {
    nfcOperation = .write
    userNdefMessage = ndefMessage
    self.isLock = isLock
    startSesstion()
  }

  private func startSesstion() {
    nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
    nfcSession?.begin()
  }
}

extension NFCManager: NFCNDEFReaderSessionDelegate {
  func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
  }

  func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
    guard let tag = tags.first else { return }

    session.connect(to: tag) { error in
      if let error = error {
        session.invalidate(errorMessage: "Connection error: \(error.localizedDescription)")
        return
      }

      tag.queryNDEFStatus { status, capacity, error in
        if let error = error {
          session.invalidate(errorMessage: "Checking NDEF status error: \(error.localizedDescription)")
          return
        }

        switch status {
        case .notSupported:
          session.invalidate(errorMessage: String.tagIsNotNdefFormatted)
        case .readOnly:
          switch self.nfcOperation {
          case .read:
            self.read(session: session, tag: tag, status: status)
          case .readForTesting:
            self.read(session: session, tag: tag, status: status, test: true)
          case .write:
            session.invalidate(errorMessage: String.tagIsNotWritable)
          }
        case .readWrite:
          switch self.nfcOperation {
          case .read:
            self.read(session: session, tag: tag, status: status)
          case .readForTesting:
            self.read(session: session, tag: tag, status: status, test: true)
          case .write:
            if capacity < self.userNdefMessage!.length {
              let errorMessage = "Tag capacity is too small. Minimum size requirement is \(self.userNdefMessage!.length) bytes."
              session.invalidate(errorMessage: errorMessage)
              return
            }

            self.write(session: session, tag: tag)
          }

        @unknown default:
          session.invalidate(errorMessage: String.unknownNdefStatus)
        }
      }
    }
  }

  private func read(
    session: NFCNDEFReaderSession,
    tag: NFCNDEFTag,
    status: NFCNDEFStatus,
    test: Bool = false
  ) {
    tag.readNDEF { [weak self] message, error in
      if let error {
        session.invalidate(errorMessage: "Reading error: \(error.localizedDescription)")
        if test {
          self?.internalIsScanResultChangedForTesting = true
        } else {
          self?.internalIsScanResultChanged = true
        }
        return
      }

      guard let message else {
        session.invalidate(errorMessage: String.noRecrodsFound)
        self?.internalScanResult = .failure(ScanResultError.failed(String.tagNotValid))

        if test {
          self?.internalIsScanResultChangedForTesting = true
        } else {
          self?.internalIsScanResultChanged = true
        }
        return
      }

      let isReadOnly = status == .readOnly
      self?.setResultExtractedFrom(message: message, isReadOnly: isReadOnly, test: test)

      if test {
        self?.internalIsScanResultChangedForTesting = true
      } else {
        self?.internalIsScanResultChanged = true
      }

      session.invalidate()
    }
  }

  private func write(session: NFCNDEFReaderSession, tag: NFCNDEFTag) {
    guard let userNdefMessage = self.userNdefMessage else { return }

    write(
      session: session,
      tag: tag,
      ndefMessage: userNdefMessage,
      isLock: isLock
      ) { error in
        guard  error == nil else { return }
        print(">>> Write: \(userNdefMessage)")
    }
  }

  private func write(
    session: NFCNDEFReaderSession,
    tag: NFCNDEFTag,
    ndefMessage: NFCNDEFMessage,
    isLock: Bool = false,
    completion: @escaping ((Error?) -> Void)
  ) {
    tag.writeNDEF(ndefMessage) { error in
      if let error = error {
        session.invalidate(errorMessage: "Writing error: \(error.localizedDescription)")
        completion(error)
      } else {
        if isLock {
          tag.writeLock { error in
            if let error = error {
              session.invalidate(errorMessage: "Writing lock error: \(error.localizedDescription)")
              completion(error)
            } else {
              session.alertMessage = String.writingSucceeded
              session.invalidate()
              completion(nil)
            }
          }
        } else {
          session.alertMessage = String.writingSucceeded
          session.invalidate()
          completion(nil)
        }
      }
    }
  }

  private func setResultExtractedFrom(message: NFCNDEFMessage, isReadOnly: Bool, test: Bool) {
    let itemTagInfo = Utility.extractItemTagInfoFrom(message: message, test: test)

    if itemTagInfo.success {
      let itemTagData = ItemTagData(
        itemTagId: itemTagInfo.id,
        itemTagType: ItemTagType(string: itemTagInfo.type),
        isReadOnly: isReadOnly,
        scannedAt: Date.now
      )
      internalScanResult = .success(itemTagData)
    } else {
      internalScanResult = .failure(ScanResultError.failed(itemTagInfo.message))
    }
  }

  func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}

  func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
    print( "readerSession error: \(error.localizedDescription)")
  }
}
