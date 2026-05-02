//
//  AcceptPrivacyView.swift
//  NativeAppTemplate
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
            let agreement = "Please accept updated [\(Strings.privacyPolicy)](\(Strings.privacyPolicyUrl))."
            Text(.init(agreement))
                .padding(.top, NativeAppTemplateConstants.Spacing.xl)

            MainButtonView(title: Strings.accept, type: .primary(withArrow: false)) {
                viewModel.updateConfirmedPrivacyVersion()
            }
            .padding(NativeAppTemplateConstants.Spacing.md)

            Spacer()
        }
        .navigationTitle(Strings.privacyPolicyUpdated)
        .navigationBarTitleDisplayMode(.inline)
    }
}
