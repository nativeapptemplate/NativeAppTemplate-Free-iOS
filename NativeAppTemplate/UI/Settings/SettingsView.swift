// Copyright (c) 2019 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SwiftUI
import MessageUI

struct SettingsView: View {
  @Environment(MessageBus.self) private var messageBus
  @Environment(SessionController.self) private var sessionController
  @Environment(TabViewModel.self) private var tabViewModel
  @State var isShowingMailView = false
  @State var alertNoMail = false
  @State var result: Result<MFMailComposeResult, Error>?
  private var signUpRepository = SignUpRepository()
  private var accountPasswordRepository: AccountPasswordRepository
  
  init(
    accountPasswordRepository: AccountPasswordRepository
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
            Label(String.supportWebsite, systemImage: "info")
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
