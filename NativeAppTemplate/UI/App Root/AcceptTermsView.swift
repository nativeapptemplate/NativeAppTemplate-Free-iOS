//
//  AcceptTermsView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/12/22.
//

import SwiftUI

struct AcceptTermsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(MessageBus.self) private var messageBus
  @Environment(SessionController.self) private var sessionController
  @Binding var areTermsAccepted: Bool
  @State private var isUpdating = false

  var body: some View {
    contentView
  }
}

// MARK: - private
private extension AcceptTermsView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if isUpdating {
        LoadingView()
      } else {
        acceptTermsView
      }
    }
    
    return contentView
  }
  
  var acceptTermsView: some View {
    VStack {
      let agreement = "Please accept updated [\(String.termsOfUse)](\(String.termsOfUseUrl))."
      Text(.init(agreement))
      .padding(.top, 48)

      MainButtonView(title: String.accept, type: .primary(withArrow: false)) {
        updateConfirmedTermsVersion()
      }
      .padding(24)
      
      Spacer()
    }
    .navigationTitle(String.termsOfUseUpdated)
    .navigationBarTitleDisplayMode(.inline)
  }
  
  private func updateConfirmedTermsVersion() {
    Task { @MainActor in
      do {
        isUpdating = true
        try await sessionController.updateConfirmedTermsVersion()
         messageBus.post(message: Message(level: .success, message: .confirmedTermsVersionUpdated))
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.confirmedTermsVersionUpdatedError) \(error.localizedDescription)", autoDismiss: false))
      }

      areTermsAccepted = true
      dismiss()
    }
  }
}

#Preview {
  @Previewable @State var areTermsAccepted = true
  
  return AcceptTermsView(areTermsAccepted: $areTermsAccepted)
}
