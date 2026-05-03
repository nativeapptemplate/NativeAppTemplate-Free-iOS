//
//  SettingsView.swift
//  NativeAppTemplate
//

import StoreKit
import SwiftUI

struct SettingsView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(MessageBus.self) private var messageBus
    @Environment(TabViewModel.self) private var tabViewModel
    @Environment(\.requestReview) private var requestReview
    @State private var viewModel: SettingsViewModel

    init(
        viewModel: SettingsViewModel
    ) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: Text(Strings.myAccount)) {
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
                            Label(Strings.profile, systemImage: "person")
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
                        Label(Strings.password, systemImage: "key")
                    }
                }
                .listRowBackground(Color.cardBackground.opacity(0.7))

                Section(header: Text(verbatim: "Support")) {
                    Link(destination: URL(string: Strings.faqsUrl)!) {
                        Label(Strings.faqs, systemImage: "questionmark")
                    }

                    Link(destination: supportEmailURL) {
                        Label(Strings.contact, systemImage: "envelope")
                    }

                    Button {
                        requestReview()
                    } label: {
                        Label(Strings.rateApp, systemImage: "hand.thumbsup")
                    }
                }
                .listRowBackground(Color.cardBackground.opacity(0.7))

                Section(header: Text(verbatim: "About")) {
                    Link(destination: URL(string: Strings.supportWebsiteUrl)!) {
                        Label("Website", systemImage: "globe")
                    }
                    Link(destination: URL(string: Strings.privacyPolicyUrl)!) {
                        Label(Strings.privacyPolicy, systemImage: "hand.raised")
                    }
                    Link(destination: URL(string: Strings.termsOfUseUrl)!) {
                        Label(Strings.termsOfUse, systemImage: "doc.text")
                    }
                }
                .listRowBackground(Color.cardBackground.opacity(0.7))

                Section(header: Text(verbatim: "App")) {
                    HStack {
                        Text(verbatim: "Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                }
                .listRowBackground(Color.cardBackground.opacity(0.7))

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
        .navigationTitle(Strings.settings)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appVersion: String {
        "\(Bundle.main.appVersionLong) (\(Bundle.main.appBuild))"
    }

    var supportEmailURL: URL {
        let appName = Strings.appName
        let appVersion = "\(Bundle.main.appVersionLong)"
        let device = Utility.deviceModel
        let systemVersion = UIDevice.current.systemVersion
        let locale = Locale.current
        let region = locale.region?.identifier ?? "Unknown"
        let language = locale.language.languageCode?.identifier ?? "Unknown"

        let body = """


        ---
        App: \(appName) \(appVersion)
        Device: \(device)
        iOS: \(systemVersion)
        Region: \(region)
        Locale: \(language)-\(region)
        """

        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "mailto:\(Strings.supportMail)?body=\(encodedBody)")!
    }
}
