//
//  SessionController.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/12/23.
//

import Foundation
import Network
import Observation

@MainActor @Observable class SessionController: SessionControllerProtocol {
  // Managing the state of the current session
  private(set) var sessionState: SessionState = .unknown
  private(set) var userState: UserState = .notLoggedIn
  private(set) var permissionState: PermissionState = .notLoaded
  private(set) var didFetchPermissions = false
  var shouldPopToRootView = false
  var didBackgroundTagReading = false

  var completeScanResult = CompleteScanResult()
  var showTagInfoScanResult = ShowTagInfoScanResult()

  var shouldUpdateApp = false
  var shouldUpdatePrivacy = false
  var shouldUpdateTerms = false
  var maximumQueueNumberLength = 0
  var shopLimitCount = 0
  
  var shopkeeper: Shopkeeper? {
    didSet {
      setClient()
      
      if let theShopkeeper = shopkeeper {
        userState = .loggedIn
        
        if shopLimitCount == 0 {
          permissionState = .notLoaded
          fetchPermissions()
        } else {
          permissionState = .loaded
        }
      } else {
        userState = .notLoggedIn
        permissionState = .notLoaded
      }
    }
  }
  
  private(set) var client: NativeAppTemplateAPI
  
  private(set) var loginRepository: LoginRepositoryProtocol
  private let connectionMonitor = NWPathMonitor()
  private(set) var permissionsService: PermissionsService
  private(set) var meService: MeService
  
  var isLoggedIn: Bool { userState == .loggedIn }
  
  var hasPermissions: Bool {
    if case .loaded = permissionState {
      return true
    }
    return false
  }
  
  // MARK: - Initializers
  init(loginRepository: LoginRepositoryProtocol) {
    self.loginRepository = loginRepository
    
    let shopkeeper = Shopkeeper.backdoor ?? loginRepository.currentShopkeeper
    let token = shopkeeper?.token ?? ""
    let tokenClient = shopkeeper?.client ?? ""
    let expiry = shopkeeper?.expiry ?? ""
    let uid = shopkeeper?.uid ?? ""
    let accountId = shopkeeper?.accountId ?? ""
    
    let client = NativeAppTemplateAPI(authToken: token, client: tokenClient, expiry: expiry, uid: uid, accountId: accountId)
    self.client = client
    permissionsService = .init(networkClient: client)
    meService = .init(networkClient: client)
    setShopkeeper(shopkeeper: shopkeeper)
    prepareConnectionMonitor()
  }
  
  func login(email: String, password: String) async throws {
    guard userState != .loggingIn else { return }
    
    userState = .loggingIn
    
    if isLoggedIn {
      if !hasPermissions {
        fetchPermissions()
      }
    } else {
      do {
        shopkeeper = try await loginRepository.login(email: email, password: password)
        Event
          .login(from: Self.self)
          .log()
        fetchPermissions()
      } catch {
        userState = .notLoggedIn
        permissionState = .notLoaded
        
        Failure
          .login(from: Self.self, reason: error.localizedDescription)
          .log()
        
        throw error
      }
    }
  }
  
  func logout() async throws {
    do {
      shouldPopToRootView = true
      try await loginRepository.logout(networkClient: client)
      
      userState = .notLoggedIn
      permissionState = .notLoaded
      shopkeeper = nil
    } catch {
      Failure
        .login(from: Self.self, reason: error.localizedDescription)
        .log()
      
      userState = .notLoggedIn
      permissionState = .notLoaded
      shopkeeper = nil
      
      throw error
    }
  }
  
  func fetchPermissionsIfNeeded() {
    guard !hasPermissions else { return }
    
    fetchPermissions()
  }
  
  func fetchPermissions() {
    // If there's no connection, use the persisted permissions
    // The re-fetch/re-store will be done the next time they open the app
    guard sessionState == .online else { return }
    
    // Don't repeatedly make the same request
    if case .loading = permissionState {
      return
    }
    
    // No point in requesting permissions when there's no user
    guard isLoggedIn else { return }
    
    permissionState = .loading
    
    Task {
      do {
        let prmissionsResponse = try await permissionsService.allPermissions()
        
        // Check that we have a logged in user. Otherwise this is pointless
        guard let shopkeeper = self.shopkeeper else { return }
        
        // Update the user
        self.shopkeeper = shopkeeper
        // Ensure loginRepository is aware, and hence the keychain is updated
        try self.loginRepository.updateShopkeeper(shopkeeper: self.shopkeeper)
        
        shouldUpdateApp = Int(Bundle.main.appBuild)! < prmissionsResponse.iosAppVersion
        shouldUpdatePrivacy = prmissionsResponse.shouldUpdatePrivacy
        shouldUpdateTerms = prmissionsResponse.shouldUpdateTerms
        maximumQueueNumberLength = prmissionsResponse.maximumQueueNumberLength

        shopLimitCount = prmissionsResponse.shopLimitCount
         
        didFetchPermissions = true
      } catch {
        enum Permissions { }
        Failure
          .fetch(from: Permissions.self, reason: error.localizedDescription)
          .log()
        
        self.permissionState = .error
      }
    }
  }
  
  func updateShopkeeper(shopkeeper: Shopkeeper?) throws {
    try loginRepository.updateShopkeeper(shopkeeper: shopkeeper)
    self.shopkeeper = shopkeeper
  }
  
  func updateConfirmedPrivacyVersion() async throws {
    do {
      try await meService.updateConfirmedPrivacyVersion()
    } catch {
      Failure
        .update(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
  
  func updateConfirmedTermsVersion() async throws {
    do {
      try await meService.updateConfirmedTermsVersion()
    } catch {
      Failure
        .update(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
  
  private func prepareConnectionMonitor() {
    connectionMonitor.pathUpdateHandler = { [weak self] path in
      Task { @MainActor in
        guard let self = self else { return }
        
        let newState: SessionState = path.status == .satisfied ? .online : .offline
        
        if newState != self.sessionState {
          self.sessionState = newState
        }
        
        if self.didFetchPermissions {
          self.fetchPermissionsIfNeeded()
        } else {
          self.fetchPermissions()
        }
      }
    }
    connectionMonitor.start(queue: .main)
  }
  
  // https://stackoverflow.com/a/25231068/1160200
  private func setShopkeeper(shopkeeper: Shopkeeper?) {
    self.shopkeeper = shopkeeper
  }
  
  private func setClient() {
    let token = shopkeeper?.token ?? ""
    let tokenClient = shopkeeper?.client ?? ""
    let expiry = shopkeeper?.expiry ?? ""
    let uid = shopkeeper?.uid ?? ""
    let accountId = shopkeeper?.accountId ?? ""
    
    self.client = NativeAppTemplateAPI(authToken: token, client: tokenClient, expiry: expiry, uid: uid, accountId: accountId)
    self.permissionsService = PermissionsService(networkClient: self.client)
    self.meService = MeService(networkClient: self.client)
  }
}
