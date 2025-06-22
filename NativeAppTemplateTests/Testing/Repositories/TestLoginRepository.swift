//
//  TestLoginRepository.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Foundation
@testable import NativeAppTemplate

@MainActor
public final class TestLoginRepository: LoginRepositoryProtocol {

  public var currentShopkeeper: Shopkeeper?

  public var loginCalled = false
  public var logoutCalled = false
  public var updateShopkeeperCalled = false

  public init() {}

  public func login(email: String, password: String) async throws -> Shopkeeper {
    loginCalled = true

    guard let shopkeeper = Shopkeeper(
      id: UUID().uuidString,
      accountId: "mockAccountId",
      personalAccountId: "mockPersonalAccountId",
      accountOwnerId: "mockAccountOwnerId",
      accountName: "Mock Account",
      email: email,
      name: "Mock Name",
      timeZone: "UTC",
      uid: "mockUID",
      token: "mockToken",
      client: "mockClient",
      expiry: "9999999999"
    ) else {
      throw NSError(
        domain: "TestLoginRepository",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Failed to create mock Shopkeeper"]
      )
    }

    currentShopkeeper = shopkeeper
    return shopkeeper
  }

  public func logout(networkClient: NativeAppTemplateAPI) async throws {
    logoutCalled = true
    currentShopkeeper = nil
  }

  public func updateShopkeeper(shopkeeper: Shopkeeper?) throws {
    updateShopkeeperCalled = true
    currentShopkeeper = shopkeeper
  }
}
