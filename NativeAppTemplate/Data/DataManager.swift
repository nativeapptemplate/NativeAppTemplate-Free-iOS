//
//  DataManager.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import SwiftUI

@MainActor @Observable class DataManager {

  // MARK: - Properties
  // Initialiser Arguments
  var sessionController: SessionControllerProtocol

  // Repositories
  private(set) var onboardingRepository: OnboardingRepositoryProtocol!
  private(set) var signUpRepository: SignUpRepositoryProtocol!
  private(set) var accountPasswordRepository: AccountPasswordRepositoryProtocol!
  private(set) var shopRepository: ShopRepositoryProtocol!
  private(set) var itemTagRepository: ItemTagRepositoryProtocol!
  private(set) var isRebuildingRepositories = false

  // MARK: - Initializers
  init(sessionController: SessionControllerProtocol) {
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
    let itemTagsService = ItemTagsService(networkClient: sessionController.client)

    onboardingRepository = OnboardingRepository()
    signUpRepository = SignUpRepository()
    accountPasswordRepository = AccountPasswordRepository(accountPasswordService: accountPasswordService)
    shopRepository = ShopRepository(shopsService: shopsService)
    itemTagRepository = ItemTagRepository(itemTagsService: itemTagsService)

    isRebuildingRepositories = false
  }
}
