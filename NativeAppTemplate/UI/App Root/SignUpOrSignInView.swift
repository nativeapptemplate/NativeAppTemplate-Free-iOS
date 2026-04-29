//
//  SignUpOrSignInView.swift
//  NativeAppTemplate
//

import SwiftUI

struct SignUpOrSignInView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.sessionController) private var sessionController: SessionControllerProtocol
    @Environment(MessageBus.self) private var messageBus

    var body: some View {
        contentView
    }
}

// MARK: - private

private extension SignUpOrSignInView {
    var contentView: some View {
        @ViewBuilder var contentView: some View {
            ScrollView {
                VStack {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 384, height: 24)
                        .padding()

                    Image("hero")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 256)
                        .padding()

                    let agreement = "By signing up or signing in, you agree to the " +
                        "[\(Strings.termsOfUse)](\(Strings.termsOfUseUrl)) " +
                        "and [\(Strings.privacyPolicy)](\(Strings.privacyPolicyUrl))."
                    Text(.init(agreement))
                        .padding(.top, NativeAppTemplateConstants.Spacing.sm)
                        .padding(.horizontal, NativeAppTemplateConstants.Spacing.md)

                    VStack {
                        NavigationLink(destination: SignUpView(
                            viewModel: SignUpViewModel(
                                signUpRepository: dataManager.signUpRepository,
                                messageBus: messageBus
                            )
                        )) {
                            MainButtonImageView(title: Strings.signUpForAnAccount, type: .primary(withArrow: false))
                                .padding(.top, NativeAppTemplateConstants.Spacing.xxs)
                                .padding(.horizontal, NativeAppTemplateConstants.Spacing.md)
                        }

                        Text(verbatim: "or")
                            .padding(.top, NativeAppTemplateConstants.Spacing.xxs)

                        NavigationLink(destination: SignInEmailAndPasswordView(
                            viewModel: SignInEmailAndPasswordViewModel(
                                sessionController: sessionController,
                                messageBus: messageBus
                            )
                        )) {
                            Text(Strings.signInToYourAccount)
                                .font(.uiLabel)
                        }
                        .padding(.top, NativeAppTemplateConstants.Spacing.xxs)
                    }
                    .padding(.top, NativeAppTemplateConstants.Spacing.xxxs)

                    Spacer()
                }
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Link(Strings.supportWebsite, destination: URL(string: Strings.supportWebsiteUrl)!)
                }
            }
            .background(Color.backgroundColor)
        }

        return contentView
    }
}

#Preview {
    SignUpOrSignInView()
}
