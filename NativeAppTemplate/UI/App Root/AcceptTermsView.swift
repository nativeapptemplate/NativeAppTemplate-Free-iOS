//
//  AcceptTermsView.swift
//  NativeAppTemplate
//

import SwiftUI

struct AcceptTermsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var areTermsAccepted: Bool
    let viewModel: AcceptTermsViewModel

    var body: some View {
        contentView
            .onChange(of: viewModel.areTermsAccepted) { _, areTermsAccepted in
                if areTermsAccepted {
                    self.areTermsAccepted = true
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

private extension AcceptTermsView {
    var contentView: some View {
        @ViewBuilder var contentView: some View {
            if viewModel.isUpdating {
                LoadingView()
            } else {
                acceptTermsView
            }
        }

        return contentView
    }

    var acceptTermsView: some View {
        VStack {
            let agreement = "Please accept updated [\(Strings.termsOfUse)](\(Strings.termsOfUseUrl))."
            Text(.init(agreement))
                .padding(.top, NativeAppTemplateConstants.Spacing.xl)

            MainButtonView(title: Strings.accept, type: .primary(withArrow: false)) {
                viewModel.updateConfirmedTermsVersion()
            }
            .padding(NativeAppTemplateConstants.Spacing.md)

            Spacer()
        }
        .navigationTitle(Strings.termsOfUseUpdated)
        .navigationBarTitleDisplayMode(.inline)
    }
}
