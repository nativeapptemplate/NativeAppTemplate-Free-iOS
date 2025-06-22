//
//  TestNFCManager.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/20.
//

import Foundation
import CoreNFC
@testable import NativeAppTemplate

final class TestNFCManager: NFCManagerProtocol, @unchecked Sendable {
  var scanResult: Result<ItemTagData, Error>?
  var isScanResultChanged = false
  var isScanResultChangedForTesting = false

  // Test control properties
  var shouldSimulateSuccess = true
  var simulatedItemTagData: ItemTagData?
  var simulatedError: Error?
  var readingStarted = false
  var testingStarted = false
  var writingStarted = false

  func startReading() async {
    readingStarted = true
    await simulateScanResult()
  }

  func startReadingForTesting() async {
    testingStarted = true
    await simulateScanResultForTesting()
  }

  func startWriting(ndefMessage: NFCNDEFMessage, isLock: Bool) async {
    writingStarted = true
  }

  // Test helper methods
  @MainActor func simulateScanResult() {
    if shouldSimulateSuccess, let itemTagData = simulatedItemTagData {
      scanResult = .success(itemTagData)
    } else if let error = simulatedError {
      scanResult = .failure(error)
    }
    isScanResultChanged = true
  }

  @MainActor func simulateScanResultForTesting() {
    if shouldSimulateSuccess, let itemTagData = simulatedItemTagData {
      scanResult = .success(itemTagData)
    } else if let error = simulatedError {
      scanResult = .failure(error)
    }
    isScanResultChangedForTesting = true
  }

  @MainActor func reset() {
    scanResult = nil
    isScanResultChanged = false
    isScanResultChangedForTesting = false
    readingStarted = false
    testingStarted = false
    writingStarted = false
    shouldSimulateSuccess = true
    simulatedItemTagData = nil
    simulatedError = nil
  }
}
