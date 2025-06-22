//
//  LoginRepositoryProtocol.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2021/01/11.
//

import Foundation

@MainActor public protocol LoginRepositoryProtocol: AnyObject, Observable, Sendable {
  var currentShopkeeper: Shopkeeper? { get }
  
  func login(email: String, password: String) async throws -> Shopkeeper
  func logout(networkClient: NativeAppTemplateAPI) async throws
  func updateShopkeeper(shopkeeper: Shopkeeper?) throws
}
