//
//  MainViewModel.swift
//  NativeAppTemplate
//

import CoreNFC
import Observation
import SwiftUI

@Observable
@MainActor
final class MainViewModel {
    var isShowingForceAppUpdatesAlert = false
    var itemTagId: String?
    var isResetting = false
    var isShowingResetConfirmationDialog = false
    var arePrivacyAccepted = false
    var areTermsAccepted = false

    private let sessionController: SessionControllerProtocol
    private let dataManager: DataManager
    private let messageBus: MessageBus
    private let tabViewModel: TabViewModel

    init(
        sessionController: SessionControllerProtocol,
        dataManager: DataManager,
        messageBus: MessageBus,
        tabViewModel: TabViewModel
    ) {
        self.sessionController = sessionController
        self.dataManager = dataManager
        self.messageBus = messageBus
        self.tabViewModel = tabViewModel
    }

    func resetTag() {
        guard let itemTagId else { return }
        resetTag(itemTagId: itemTagId)
    }

    func cancelResetDialog() {
        isShowingResetConfirmationDialog = false
    }

    func handleBackgroundTagReading(_ userActivity: NSUserActivity) {
        guard sessionController.isLoggedIn else {
            messageBus.post(message: Message(level: .error, message: String.pleaseSignIn, autoDismiss: false))
            return
        }

        let ndefMessage = userActivity.ndefMessagePayload
        guard !ndefMessage.records.isEmpty,
              ndefMessage.records[0].typeNameFormat != .empty else {
            return
        }

        let itemTagInfo = Utility.extractItemTagInfoFrom(message: ndefMessage)

        if itemTagInfo.success {
            itemTagId = itemTagInfo.id
            completeTag(itemTagId: itemTagInfo.id)
        } else {
            messageBus.post(message: Message(level: .error, message: itemTagInfo.message, autoDismiss: false))
            tabViewModel.selectedTab = .scan
        }
    }

    func logout() {
        Task {
            try await sessionController.logout()
        }
    }

    // MARK: - Private Methods

    private func completeTag(itemTagId: String) {
        Task {
            do {
                let itemTag = try await dataManager.itemTagRepository.complete(id: itemTagId)

                sessionController.completeScanResult = CompleteScanResult(
                    itemTag: itemTag,
                    type: .completed
                )

                // TODO: removed in Phase 2A-2 — alreadyCompleted branch dropped with ItemTag schema v2
            } catch {
                sessionController.completeScanResult = CompleteScanResult(
                    type: .failed,
                    message: error.codedDescription
                )
            }

            sessionController.didBackgroundTagReading = true
            tabViewModel.selectedTab = .scan
        }
    }

    private func resetTag(itemTagId: String) {
        Task {
            isResetting = true

            do {
                let itemTag = try await dataManager.itemTagRepository.reset(id: itemTagId)
                sessionController.completeScanResult = CompleteScanResult(
                    itemTag: itemTag,
                    type: .reset
                )
            } catch {
                sessionController.completeScanResult = CompleteScanResult(
                    type: .failed,
                    message: error.codedDescription
                )
            }

            isResetting = false
            sessionController.didBackgroundTagReading = true
            tabViewModel.selectedTab = .scan
        }
    }
}
