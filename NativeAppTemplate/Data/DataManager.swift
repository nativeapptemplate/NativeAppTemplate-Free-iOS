//
//  DataManager.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import SwiftUI

@Observable class DataManager {

  // MARK: - Properties
  // Initialiser Arguments
  var sessionController: SessionController

  // Repositories
  private(set) var accountPasswordRepository: AccountPasswordRepository!
  private(set) var shopRepository: ShopRepository!
  private(set) var isRebuildingRepositories = false

  // MARK: - Initializers
  init(sessionController: SessionController) {
    self.sessionController = sessionController
    rebuildRepositories()
  }
  
  func rebuildRepositories() {
    isRebuildingRepositories = true

    withObservationTracking {
      _ = sessionController.client
    } onChange: {
      Task { @MainActor in
        self.rebuildRepositories()
      }
    }

    let accountPasswordService = AccountPasswordService(networkClient: sessionController.client)
    let shopsService = ShopsService(networkClient: sessionController.client)
    accountPasswordRepository = AccountPasswordRepository(accountPasswordService: accountPasswordService)
    shopRepository = ShopRepository(shopsService: shopsService)
    
    isRebuildingRepositories = false
  }
}
