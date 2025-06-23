//
//  SettingsView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
  @Environment(DataManager.self) private var dataManager
  @Environment(MessageBus.self) private var messageBus
  @Environment(TabViewModel.self) private var tabViewModel
  @State private var viewModel: SettingsViewModel

  init(
    viewModel: SettingsViewModel,
  ) {
    self._viewModel = State(wrappedValue: viewModel)
  }
  
  var body: some View {
    VStack(spacing: 0) {
      List {
        Section(header: Text(String.myAccount)) {
          if let shopkeeper = viewModel.shopkeeper {
            NavigationLink(
              destination: ShopkeeperEditView(
                viewModel: ShopkeeperEditViewModel(
                  signUpRepository: dataManager.signUpRepository,
                  sessionController: dataManager.sessionController,
                  messageBus: messageBus,
                  tabViewModel: tabViewModel,
                  shopkeeper: shopkeeper
                )
              )
            ) {
              Label(String.profile, systemImage: "person")
            }
          }

          NavigationLink(
            destination: PasswordEditView(
              viewModel: PasswordEditViewModel(
                accountPasswordRepository: dataManager.accountPasswordRepository,
                messageBus: messageBus
              )
            )
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
            MFMailComposeViewController.canSendMail() ? viewModel.isShowingMailView.toggle() : viewModel.alertNoMail.toggle()
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
            Text("Logged in as \(viewModel.shopkeeper?.name ?? "")")
            MainButtonView(title: "Sign Out", type: .destructive(withArrow: false)) {
              viewModel.signOut()
            }
          }
          .listRowBackground(Color.clear)
        }
        
#if DEBUG
        if viewModel.isLoggedIn {
          Section {
            Text(verbatim: viewModel.accountId)
          } header: {
            Text(verbatim: "Account ID")
          }
        }
#endif
      }
    }
    .navigationTitle(String.settings)
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $viewModel.isShowingMailView) {
      let systemVersion = UIDevice.current.systemVersion
      let device = Utility.deviceModel
      
      MailView(
        result: $viewModel.result,
        recipients: [String.supportMail],
        subject: "\(Bundle.main.displayName) for iPhone support",
        messageBody: "\n\n\n-----\n\(Bundle.main.displayName) \(Bundle.main.appVersionLong)\n\(device) (\(systemVersion))\n\(Locale.preferredLanguages[0])"
      )
    }
    .alert(
      "NO MAIL SETUP",
      isPresented: $viewModel.alertNoMail
    ) {
    }
  }
}
