//
//  AcceptPrivacyView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/12/22.
//

import SwiftUI

struct AcceptPrivacyView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(MessageBus.self) private var messageBus
  @Environment(\.sessionController) private var sessionController
  @Binding var arePrivacyAccepted: Bool
  @State private var isUpdating = false

  var body: some View {
    contentView
  }
}

// MARK: - private
private extension AcceptPrivacyView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if isUpdating {
        LoadingView()
      } else {
        acceptPrivacyView
      }
    }
    
    return contentView
  }
  
  var acceptPrivacyView: some View {
    VStack {
      let agreement = "Please accept updated [\(String.privacyPolicy)](\(String.privacyPolicyUrl))."
      Text(.init(agreement))
      .padding(.top, 48)

      MainButtonView(title: String.accept, type: .primary(withArrow: false)) {
        updateConfirmedPrivacyVersion()
      }
      .padding(24)
      
      Spacer()
    }
    .navigationTitle(String.privacyPolicyUpdated)
    .navigationBarTitleDisplayMode(.inline)
  }
  
  private func updateConfirmedPrivacyVersion() {
    Task { @MainActor in
      do {
        isUpdating = true
        try await sessionController.updateConfirmedPrivacyVersion()
         messageBus.post(message: Message(level: .success, message: .confirmedPrivacyVersionUpdated))
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.confirmedPrivacyVersionUpdatedError) \(error.localizedDescription)", autoDismiss: false))
      }

      arePrivacyAccepted = true
      dismiss()
    }
  }
}

#Preview {
  @Previewable @State var arePrivacyAccepted = true
  
  return AcceptPrivacyView(arePrivacyAccepted: $arePrivacyAccepted)
}
