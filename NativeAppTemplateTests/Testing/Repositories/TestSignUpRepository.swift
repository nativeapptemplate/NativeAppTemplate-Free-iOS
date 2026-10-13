//
//  TestSignUpRepository.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate

@MainActor
final class TestSignUpRepository: SignUpRepositoryProtocol {
    // A test-only
    var error: NativeAppTemplateAPIError?
    /// A test-only: when set, the save and delete calls wait here until the test opens it
    var gate: TestGate?
    var signUpCalled = false
    var updateCalled = false
    var destroyCalled = false
    var sendResetPasswordCalled = false
    var sendConfirmationCalled = false
    var lastSignUp: SignUp?
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
            "locale": signUp.locale,
            "uid": signUp.email,
            "token": "test_token",
            "client": "test_client",
            "expiry": "123456789"
        ])!
    }

    func update(signUp: SignUp, networkClient: NativeAppTemplateAPI) async throws -> Shopkeeper {
        await gate?.wait()
        updateCalled = true
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
            "locale": signUp.locale,
            "uid": signUp.email,
            "token": "test_token",
            "client": "test_client",
            "expiry": "123456789"
        ])!
    }

    func destroy(networkClient: NativeAppTemplateAPI) async throws {
        await gate?.wait()
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
