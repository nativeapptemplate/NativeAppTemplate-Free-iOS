//
//  LoginRepository.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2021/01/11.
//

import Foundation

@Observable public class LoginRepository {
  // MARK: - Properties
  private var _currentShopkeeper: Shopkeeper?
  
  public var currentShopkeeper: Shopkeeper? {
    if _currentShopkeeper == nil {
      let keychainStore = LoggedInShopkeeperKeychainStore()
      
      do {
        let loggedInShopkeeper = try keychainStore.retrieve()
        _currentShopkeeper = Shopkeeper(from: loggedInShopkeeper)
      } catch {
        print(error)
      }
    }
    return _currentShopkeeper
  }

  @MainActor func login(email: String, password: String) async throws -> Shopkeeper {
    do {
      let sessionsService = SessionsService(networkClient: NativeAppTemplateAPI(authToken: "", client: "", expiry: "", uid: "", accountId: ""))
      let shopkeeper = try await sessionsService.makeSession(email: email, password: password)
      try saveShopkeeper(shopkeeper: shopkeeper)
      _currentShopkeeper = shopkeeper
    } catch {
      Failure
        .fetch(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
    return currentShopkeeper!
  }
  
  @MainActor func logout(networkClient: NativeAppTemplateAPI) async throws {
    do {
      let sessionsService = SessionsService(networkClient: networkClient)
      try await sessionsService.destroySession()
      removeShopkeeper()
      _currentShopkeeper = .none
    } catch {
      Failure
        .fetch(from: Self.self, reason: error.localizedDescription)
        .log()
      removeShopkeeper()
      _currentShopkeeper = .none
      throw error
    }
  }
  
  public func updateShopkeeper(shopkeeper: Shopkeeper?) throws {
    _currentShopkeeper = shopkeeper
    if let shopkeeper = shopkeeper {
      try saveShopkeeper(shopkeeper: shopkeeper)
    } else {
      removeShopkeeper()
    }
  }

  private func saveShopkeeper(shopkeeper: Shopkeeper) throws {
    let keychainStore = LoggedInShopkeeperKeychainStore()
    let loggedInShopkeeper = LoggedInShopkeeper(from: shopkeeper)
    do {
      try keychainStore.store(loggedInShopkeeper)
    } catch {
      throw error
    }
  }
  
  private func removeShopkeeper() {
    let keychainStore = LoggedInShopkeeperKeychainStore()
    
    do {
      try keychainStore.remove()
    } catch {
      print(error)
    }
  }
}
