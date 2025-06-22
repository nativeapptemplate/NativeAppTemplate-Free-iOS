//
//  TestSessionController.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Foundation
@testable import NativeAppTemplate

@MainActor @Observable public class TestSessionController: SessionControllerProtocol {
  // MARK: - Properties
  public var sessionState: SessionState = .unknown
  public var userState: UserState = .loggedIn
  public var permissionState: PermissionState = .notLoaded
  public var didFetchPermissions: Bool = false

  public var shouldPopToRootView: Bool = false
  public var didBackgroundTagReading: Bool = false

  public var completeScanResult: CompleteScanResult = .init()
  public var showTagInfoScanResult: ShowTagInfoScanResult = .init()

  public var shouldUpdateApp: Bool = false
  public var shouldUpdatePrivacy: Bool = false
  public var shouldUpdateTerms: Bool = false
  public var shouldThrowPrivacyError: Bool = false
  public var shouldThrowTermsError: Bool = false
  public var maximumQueueNumberLength: Int = 4
  public var shopLimitCount: Int = 1

  public var shopkeeper: Shopkeeper?
  public private(set) var client = NativeAppTemplateAPI(authToken: "", client: "", expiry: "", uid: "", accountId: "")

  public var isLoggedIn: Bool {
    userState == .loggedIn
  }

  public var hasPermissions: Bool {
    switch permissionState {
    case .loaded:
      return true
    default:
      return false
    }
  }

  // MARK: - Initializer
  public nonisolated init() {}

  // MARK: - Methods
  public func login(email: String, password: String) async throws {
    userState = .loggedIn
    sessionState = .online
  }

  public func logout() async throws {
    userState = .notLoggedIn
    sessionState = .offline
    shopkeeper = nil
  }

  public func fetchPermissionsIfNeeded() {
    didFetchPermissions = true
    permissionState = .loaded
  }

  public func fetchPermissions() {
    permissionState = .loading
    // Mocking immediate load
    permissionState = .loaded
  }

  public func updateShopkeeper(shopkeeper: Shopkeeper?) throws {
    self.shopkeeper = shopkeeper
  }

  public func updateConfirmedPrivacyVersion() async throws {
    if shouldThrowPrivacyError {
      throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Privacy update failed"])
    }
    shouldUpdatePrivacy = false
  }

  public func updateConfirmedTermsVersion() async throws {
    if shouldThrowTermsError {
      throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Terms update failed"])
    }
    shouldUpdateTerms = false
  }
}
