//
//  AcceptPrivacyView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/12/22.
//

import SwiftUI

struct AcceptPrivacyView: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var arePrivacyAccepted: Bool
  let viewModel: AcceptPrivacyViewModel

  var body: some View {
    contentView
      .onChange(of: viewModel.arePrivacyAccepted) { _, arePrivacyAccepted in
        if arePrivacyAccepted {
          self.arePrivacyAccepted = true
        }
      }
      .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
        if shouldDismiss {
          dismiss()
        }
      }
  }
}

// MARK: - private
private extension AcceptPrivacyView {
  var contentView: some View {

    @ViewBuilder var contentView: some View {
      if viewModel.isUpdating {
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
        viewModel.updateConfirmedPrivacyVersion()
      }
      .padding(24)

      Spacer()
    }
    .navigationTitle(String.privacyPolicyUpdated)
    .navigationBarTitleDisplayMode(.inline)
  }
}
