//
//  TestSignUpRepository.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Foundation
@testable import NativeAppTemplate

@MainActor
final class TestSignUpRepository: SignUpRepositoryProtocol {
  // A test-only
  var error: NativeAppTemplateAPIError?
  var signUpCalled = false
  var updateCalled = false
  var destroyCalled = false
  var sendResetPasswordCalled = false
  var sendConfirmationCalled = false
  var lastSignUp: SignUp?
  var lastUpdateId: String?
  var lastSendResetPassword: SendResetPassword?
  var lastSendConfirmation: SendConfirmation?
  var shopkeeperToReturn: Shopkeeper?

  func signUp(signUp: SignUp) async throws -> Shopkeeper {
    signUpCalled = true
    lastSignUp = signUp

    guard error == nil else {
      throw error!
    }

    return shopkeeperToReturn ?? Shopkeeper(dictionary: [
      "id": "1",
      "account_id": "account_1",
      "personal_account_id": "personal_1",
      "account_owner_id": "owner_1",
      "account_name": "Test Account",
      "email": signUp.email,
      "name": signUp.name,
      "time_zone": signUp.timeZone,
      "uid": signUp.email,
      "token": "test_token",
      "client": "test_client",
      "expiry": "123456789"
    ])!
  }

  func update(id: String, signUp: SignUp, networkClient: NativeAppTemplateAPI) async throws -> Shopkeeper {
    updateCalled = true
    lastUpdateId = id
    lastSignUp = signUp

    guard error == nil else {
      throw error!
    }

    return shopkeeperToReturn ?? Shopkeeper(dictionary: [
      "id": id,
      "account_id": "account_1",
      "personal_account_id": "personal_1",
      "account_owner_id": "owner_1",
      "account_name": "Test Account",
      "email": signUp.email,
      "name": signUp.name,
      "time_zone": signUp.timeZone,
      "uid": signUp.email,
      "token": "test_token",
      "client": "test_client",
      "expiry": "123456789"
    ])!
  }

  func destroy(networkClient: NativeAppTemplateAPI) async throws {
    destroyCalled = true

    guard error == nil else {
      throw error!
    }
  }

  func sendResetPasswordInstruction(sendResetPassword: SendResetPassword) async throws {
    sendResetPasswordCalled = true
    lastSendResetPassword = sendResetPassword

    guard error == nil else {
      throw error!
    }
  }

  func sendConfirmationInstruction(sendConfirmation: SendConfirmation) async throws {
    sendConfirmationCalled = true
    lastSendConfirmation = sendConfirmation

    guard error == nil else {
      throw error!
    }
  }
}
