//
//  ScanViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/20.
//

// swiftlint:disable file_length

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
// swiftlint:disable:next type_body_length
struct ScanViewModelTest {
  let itemTagRepository = TestItemTagRepository(itemTagsService: ItemTagsService())
  let sessionController = TestSessionController()
  let messageBus = MessageBus()
  let nfcManager = TestNFCManager()

  var testItemTag: ItemTag {
    var tag = ItemTag()
    tag.id = "test-tag-id"
    tag.shopId = "test-shop-id"
    tag.queueNumber = "123"
    tag.state = .idled
    tag.completedAt = nil
    tag.alreadyCompleted = false
    return tag
  }

  var testItemTagData: ItemTagData {
    ItemTagData(
      itemTagId: "test-tag-id",
      itemTagType: .server,
      isReadOnly: false,
      scannedAt: Date.now
    )
  }

  @Test
  func initializesCorrectly() {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    #expect(viewModel.scanType == ScanType.completeScan)
    #expect(viewModel.isShowingResetConfirmationDialog == false)
    #expect(viewModel.isFetching == false)
    #expect(viewModel.isResetting == false)
    #expect(viewModel.isBusy == false)
  }

  @Test
  func busyStateReflectsFetchingAndResettingStates() {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    #expect(viewModel.isBusy == false)

    viewModel.isFetching = true
    #expect(viewModel.isBusy == true)

    viewModel.isFetching = false
    viewModel.isResetting = true
    #expect(viewModel.isBusy == true)

    viewModel.isResetting = false
    #expect(viewModel.isBusy == false)

    // Both fetching and resetting
    viewModel.isFetching = true
    viewModel.isResetting = true
    #expect(viewModel.isBusy == true)
  }

  @Test
  func handleBackgroundTagReadingUpdatesScanType() {
    itemTagRepository.setItemTags(itemTags: [testItemTag])
    sessionController.didBackgroundTagReading = false

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    viewModel.scanType = ScanType.test
    viewModel.handleBackgroundTagReading()
    #expect(viewModel.scanType == ScanType.test) // Should not change
    #expect(sessionController.didBackgroundTagReading == false)

    sessionController.didBackgroundTagReading = true
    viewModel.handleBackgroundTagReading()
    #expect(viewModel.scanType == ScanType.completeScan)
    #expect(sessionController.didBackgroundTagReading == false)
  }

  @Test
  func handleScanResultChangedWithSuccessCompletesTag() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    nfcManager.reset()
    itemTagRepository.error = nil

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    // Setup successful scan result
    nfcManager.simulatedItemTagData = testItemTagData
    nfcManager.shouldSimulateSuccess = true
    nfcManager.simulateScanResult()

    viewModel.handleScanResultChanged()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

    #expect(sessionController.completeScanResult.type == .completed)
    #expect(sessionController.completeScanResult.itemTag?.id == "test-tag-id")
  }

  @Test
  func handleScanResultChangedWithFailureSetsError() {
    itemTagRepository.setItemTags(itemTags: [testItemTag])
    nfcManager.reset()

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    // Setup failed scan result
    let testError = NSError(domain: "TestError", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test scan error"])
    nfcManager.simulatedError = testError
    nfcManager.shouldSimulateSuccess = false
    nfcManager.simulateScanResult()

    viewModel.handleScanResultChanged()

    #expect(sessionController.completeScanResult.type == .failed)
    #expect(sessionController.completeScanResult.message == "Test scan error")
  }

  @Test
  func handleScanResultChangedWithoutChangedResultDoesNothing() {
    itemTagRepository.setItemTags(itemTags: [testItemTag])
    nfcManager.reset()
    nfcManager.isScanResultChanged = false

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    let originalResult = sessionController.completeScanResult
    viewModel.handleScanResultChanged()

    #expect(sessionController.completeScanResult.type == originalResult.type)
  }

  @Test
  func handleScanResultChangedForTestingWithSuccessFetchesDetail() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])
    nfcManager.reset()
    itemTagRepository.error = nil

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    // Setup successful scan result for testing
    nfcManager.simulatedItemTagData = testItemTagData
    nfcManager.shouldSimulateSuccess = true
    nfcManager.simulateScanResultForTesting()

    viewModel.handleScanResultChangedForTesting()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

    #expect(sessionController.showTagInfoScanResult.type == .succeeded)
    #expect(sessionController.showTagInfoScanResult.itemTag?.id == "test-tag-id")
    #expect(sessionController.showTagInfoScanResult.itemTagType == .server)
    #expect(sessionController.showTagInfoScanResult.isReadOnly == false)
  }

  @Test
  func handleScanResultChangedForTestingWithFailureSetsError() {
    itemTagRepository.setItemTags(itemTags: [testItemTag])
    nfcManager.reset()

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    // Setup failed scan result for testing
    let testError = NSError(domain: "TestError", code: 456, userInfo: [NSLocalizedDescriptionKey: "Test fetch error"])
    nfcManager.simulatedError = testError
    nfcManager.shouldSimulateSuccess = false
    nfcManager.simulateScanResultForTesting()

    viewModel.handleScanResultChangedForTesting()

    #expect(sessionController.showTagInfoScanResult.type == .failed)
    #expect(sessionController.showTagInfoScanResult.message == "Test fetch error")
  }

  @Test
  func startCompleteScanInitializesResultAndStartsNFC() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])
    nfcManager.reset()

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    let startCompleteScanTask = Task {
      viewModel.startCompleteScan()
    }
    await startCompleteScanTask.value

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

    #expect(sessionController.completeScanResult.type == .idled)
    #expect(nfcManager.readingStarted)
  }

  @Test
  func startTestScanInitializesResultAndStartsNFC() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])
    nfcManager.reset()

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    let startTestScanTask = Task {
      viewModel.startTestScan()
    }
    await startTestScanTask.value

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

    #expect(sessionController.showTagInfoScanResult.type == .idled)
    #expect(nfcManager.testingStarted)
  }

  @Test
  func resetTagWithValidItemTagResetsSuccessfully() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    itemTagRepository.error = nil

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    // Setup a completed scan result with item tag
    sessionController.completeScanResult = CompleteScanResult(
      itemTag: testItemTag,
      type: .completed
    )

    viewModel.resetTag()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

    #expect(sessionController.completeScanResult.type == .reset)
    #expect(sessionController.completeScanResult.itemTag?.id == "test-tag-id")
  }

  @Test
  func resetTagWithoutItemTagDoesNothing() {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    // Setup scan result without item tag
    sessionController.completeScanResult = CompleteScanResult(type: .idled)
    let originalResult = sessionController.completeScanResult

    viewModel.resetTag()

    #expect(sessionController.completeScanResult.type == originalResult.type)
  }

  @Test
  func resetTagWithFailureUpdatesResult() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])
    itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, 500, "Reset failed")

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    // Setup a completed scan result with item tag
    sessionController.completeScanResult = CompleteScanResult(
      itemTag: testItemTag,
      type: .completed
    )

    viewModel.resetTag()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

    #expect(sessionController.completeScanResult.type == .failed)
    #expect(sessionController.completeScanResult.message.contains("Reset failed"))
  }

  @Test
  func dismissResetConfirmationDialogUpdatesState() {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    viewModel.isShowingResetConfirmationDialog = true
    #expect(viewModel.isShowingResetConfirmationDialog == true)

    viewModel.dismissResetConfirmationDialog()
    #expect(viewModel.isShowingResetConfirmationDialog == false)
  }

  @Test
  func completeTagWithAlreadyCompletedShowsDialog() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])
    itemTagRepository.error = nil

    var alreadyCompletedTag = ItemTag()
    alreadyCompletedTag.id = "completed-tag-id"
    alreadyCompletedTag.shopId = "test-shop-id"
    alreadyCompletedTag.queueNumber = "456"
    alreadyCompletedTag.state = .completed
    alreadyCompletedTag.completedAt = Date.now
    alreadyCompletedTag.alreadyCompleted = true

    // Add the already completed tag to repository
    itemTagRepository.itemTags.append(alreadyCompletedTag)

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    // Setup scan result for already completed tag
    let completedTagData = ItemTagData(
      itemTagId: "completed-tag-id",
      itemTagType: .server,
      isReadOnly: false,
      scannedAt: Date.now
    )

    nfcManager.simulatedItemTagData = completedTagData
    nfcManager.shouldSimulateSuccess = true
    nfcManager.simulateScanResult()

    viewModel.handleScanResultChanged()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

    #expect(viewModel.isShowingResetConfirmationDialog == true)
    #expect(sessionController.completeScanResult.type == .completed)
  }

  @Test
  func busyStateDuringReset() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])
    itemTagRepository.error = nil

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    // Setup a completed scan result with item tag
    sessionController.completeScanResult = CompleteScanResult(
      itemTag: testItemTag,
      type: .completed
    )

    let resetTask = Task {
      viewModel.resetTag()
    }

    // Check busy state immediately after starting
    #expect(viewModel.isBusy == viewModel.isResetting)

    await resetTask.value

    #expect(viewModel.isBusy == false)
    #expect(viewModel.isResetting == false)
  }

  @Test
  func busyStateDuringFetch() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])
    itemTagRepository.error = nil
    nfcManager.reset()

    let viewModel = ScanViewModel(
      itemTagRepository: itemTagRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      nfcManager: nfcManager
    )

    // Setup successful scan result for testing
    nfcManager.simulatedItemTagData = testItemTagData
    nfcManager.shouldSimulateSuccess = true
    nfcManager.simulateScanResultForTesting()

    let fetchTask = Task {
      viewModel.handleScanResultChangedForTesting()
    }

    // Check busy state immediately after starting
    #expect(viewModel.isBusy == viewModel.isFetching)

    await fetchTask.value

    #expect(viewModel.isBusy == false)
    #expect(viewModel.isFetching == false)
  }
}
