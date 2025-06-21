//
//  SignUpOrSignInView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2024/01/16.
//

import SwiftUI

struct SignUpOrSignInView: View {
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

          Image("onboarding1Slim")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 256)
            .padding()

          let agreement = "By signing up or signing in, you agree to the [\(String.termsOfUse)](\(String.termsOfUseUrl)) and [\(String.privacyPolicy)](\(String.privacyPolicyUrl))."
          Text(.init(agreement))
            .padding(.top, 16)
            .padding(.horizontal, 24)

          VStack {
            NavigationLink(destination: SignUpView(signUpRepository: SignUpRepository() as SignUpRepositoryProtocol)) {
              MainButtonImageView(title: String.signUpForAnAccount, type: .primary(withArrow: false))
                .padding(.top, 8)
                .padding(.horizontal, 24)
            }
            
            Text(verbatim: "or")
              .padding(.top, 8)
            
            NavigationLink(destination: SignInEmailAndPasswordView(signUpRepository: SignUpRepository() as SignUpRepositoryProtocol)) {
              Text(String.signInToYourAccount)
                .font(.uiLabel)
            }
            .padding(.top, 8)
          }
          .padding(.top, 4)
          
          Spacer()
        }
        .padding(.bottom)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Link(String.supportWebsite, destination: URL(string: String.supportWebsiteUrl)!)
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
