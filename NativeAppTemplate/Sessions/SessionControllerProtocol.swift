//
//  SessionControllerProtocol.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/04/25.
//

import Foundation

public enum UserState: Sendable {
  case loggedIn
  case loggingIn
  case notLoggedIn
}

public enum SessionState: Sendable {
  case unknown
  case online
  case offline
}

public enum PermissionState: Equatable, Sendable {
  case notLoaded
  case loading
  case loaded
  case error
}

@MainActor
protocol SessionControllerProtocol: AnyObject, Observable, Sendable {
  // MARK: - Properties
  var sessionState: SessionState { get }
  var userState: UserState { get }
  var permissionState: PermissionState { get }
  var didFetchPermissions: Bool { get }
  
  var shouldPopToRootView: Bool { get set }
  var didBackgroundTagReading: Bool { get set }
  
  var completeScanResult: CompleteScanResult { get set }
  var showTagInfoScanResult: ShowTagInfoScanResult { get set }
  
  var shouldUpdateApp: Bool { get set }
  var shouldUpdatePrivacy: Bool { get set }
  var shouldUpdateTerms: Bool { get set }
  var maximumQueueNumberLength: Int { get set }
  var shopLimitCount: Int { get set }
  
  var shopkeeper: Shopkeeper? { get set }
  var hasPermissions: Bool { get }

  var isLoggedIn: Bool { get }
  var client: NativeAppTemplateAPI { get }
  
  // MARK: - Methods
  func login(email: String, password: String) async throws
  func logout() async throws
  func fetchPermissionsIfNeeded()
  func fetchPermissions()
  func updateShopkeeper(shopkeeper: Shopkeeper?) throws
  func updateConfirmedPrivacyVersion() async throws
  func updateConfirmedTermsVersion() async throws
}
