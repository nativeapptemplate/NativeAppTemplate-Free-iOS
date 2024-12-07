//
//  App.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2024/10/01.
//

import Foundation
import SwiftUI
import TipKit

@main
struct App {
  typealias Objects = ( // swiftlint:disable:this large_tuple
    loginRepository: LoginRepository,
    sessionController: SessionController,
    dataManager: DataManager,
    messageBus: MessageBus
  )
  
  private var loginRepository: LoginRepository
  private var sessionController: SessionController
  private var dataManager: DataManager
  private var messageBus: MessageBus

  init() {
    // setup objects
    let nativeAppTemplateObjects = App.objects
    loginRepository = nativeAppTemplateObjects.loginRepository
    sessionController = nativeAppTemplateObjects.sessionController
    dataManager = nativeAppTemplateObjects.dataManager
    messageBus = nativeAppTemplateObjects.messageBus
    
    // configure ui
    customizeNavigationBar()
    customizeTableView()
    customizeControls()
    
    try? Tips.configure()
  }
}

// MARK: - SwiftUI.App
extension App: SwiftUI.App {
  var body: some Scene {
    WindowGroup {
      ZStack {
        Rectangle()
          .fill(Color.backgroundColor)
          .edgesIgnoringSafeArea(.all)
        MainView()
          .preferredColorScheme(.dark) // Dark mode only
          .environment(loginRepository)
          .environment(sessionController)
          .environment(dataManager)
          .environment(messageBus)
      }
    }
  }
}

// MARK: - internal
extension App {
  // Initialise the database
  static var objects: Objects {
    let loginRepository = LoginRepository()
    let sessionController = SessionController(loginRepository: loginRepository)
    let messageBus = MessageBus()

    return (
      loginRepository: loginRepository,
      sessionController: sessionController,
      dataManager: .init(
        sessionController: sessionController
      ),
      messageBus: messageBus
    )
  }
}

// MARK: - private
private extension App {
  func customizeNavigationBar() {
    UINavigationBar.appearance().backgroundColor = .backgroundUiColor

    UINavigationBar.appearance().largeTitleTextAttributes = [
      .foregroundColor: UIColor(named: "titleText")!,
      .font: UIFont.uiLargeTitle
    ]
    UINavigationBar.appearance().titleTextAttributes = [
      .foregroundColor: UIColor(named: "titleText")!,
      .font: UIFont.uiHeadline
    ]
  }

  func customizeTableView() {
    UITableView.appearance().separatorColor = .clear
    UITableViewCell.appearance().backgroundColor = .backgroundUiColor
    UITableViewCell.appearance().selectionStyle = .none
    UITableView.appearance().backgroundColor = .backgroundUiColor
  }

  func customizeControls() {
    UISwitch.appearance().onTintColor = .accent
  }
}
