//
//  SettingsView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
  @Environment(MessageBus.self) private var messageBus
  @Environment(\.sessionController) private var sessionController
  @Environment(TabViewModel.self) private var tabViewModel
  @State var isShowingMailView = false
  @State var alertNoMail = false
  @State var result: Result<MFMailComposeResult, Error>?
  private var signUpRepository: SignUpRepositoryProtocol = SignUpRepository()
  private var accountPasswordRepository: AccountPasswordRepositoryProtocol
  
  init(
    accountPasswordRepository: AccountPasswordRepositoryProtocol
  ) {
    self.accountPasswordRepository = accountPasswordRepository
  }
  
  var body: some View {
    VStack(spacing: 0) {
      List {
        Section(header: Text(String.myAccount)) {
          if let shopkeeper = sessionController.shopkeeper {
            NavigationLink(
              destination: ShopkeeperEditView(signUpRepository: signUpRepository, shopkeeper: shopkeeper)
            ) {
              Label(String.profile, systemImage: "person")
            }
          }
          
          NavigationLink(
            destination: PasswordEditView(accountPasswordRepository: accountPasswordRepository)
          ) {
            Label(String.password, systemImage: "key")
          }
        }
        .listRowBackground(Color.cardBackground)
        
        Section(header: Text(String.information)) {
          Link(destination: URL(string: String.supportWebsiteUrl)!) {
            Label(String.supportWebsite, systemImage: "globe")
          }
          
          Link(destination: URL(string: String.howToUseUrl)!) {
            Label(String.howToUse, systemImage: "info")
          }

          Link(destination: URL(string: String.faqsUrl)!) {
            Label(String.faqs, systemImage: "questionmark")
          }

          Link(destination: URL(string: String.discussionsUrl)!) {
            Label(String.discussions, systemImage: "bubble.left.and.bubble.right")
          }

          Button {
            MFMailComposeViewController.canSendMail() ? self.isShowingMailView.toggle() : self.alertNoMail.toggle()
          } label: {
            Label(String.contact, systemImage: "envelope")
          }
          
          Link(destination: URL(string: "\(String.appStoreUrl)?action=write-review")!) {
            Label(String.rateApp, systemImage: "hand.thumbsup")
          }
          
          Link(destination: URL(string: String.privacyPolicyUrl)!) {
            Text(String.privacyPolicy)
          }
          Link(destination: URL(string: String.termsOfUseUrl)!) {
            Text(String.termsOfUse)
          }
        }
        .listRowBackground(Color.cardBackground)
        
        Section {
          VStack {
            Text("Logged in as \(sessionController.shopkeeper?.name ?? "")")
            MainButtonView(title: "Sign Out", type: .destructive(withArrow: false)) {
              signOut()
            }
          }
          .listRowBackground(Color.clear)
        }
        
#if DEBUG
        if sessionController.isLoggedIn {
          Section {
            Text(verbatim: sessionController.client.accountId)
          } header: {
            Text(verbatim: "Account ID")
          }
        }
#endif
      }
    }
    .navigationTitle(String.settings)
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $isShowingMailView) {
      let systemVersion = UIDevice.current.systemVersion
      let device = Utility.deviceModel
      
      MailView(
        result: self.$result,
        recipients: [String.supportMail],
        subject: "\(Bundle.main.displayName) for iPhone support",
        messageBody: "\n\n\n-----\n\(Bundle.main.displayName) \(Bundle.main.appVersionLong)\n\(device) (\(systemVersion))\n\(Locale.preferredLanguages[0])"
      )
    }
    .alert(
      "NO MAIL SETUP",
      isPresented: $alertNoMail
    ) {
    }
  }
  
  func signOut() {
    Task { @MainActor in
      do {
        try await sessionController.logout()
#if DEBUG
        messageBus.post(message: Message(level: .success, message: .signedOut))
#endif
      } catch {
#if DEBUG
        messageBus.post(message: Message(level: .error, message: "\(String.signedOutError) \(error.localizedDescription)", autoDismiss: false))
#endif
      }
      
      tabViewModel.selectedTab = .shops
    }
  }
}
