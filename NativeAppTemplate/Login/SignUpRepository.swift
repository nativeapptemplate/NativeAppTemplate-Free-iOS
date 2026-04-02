//
//  SignUpRepository.swift
//  NativeAppTemplate
//

import Foundation
import os

@MainActor class SignUpRepository: SignUpRepositoryProtocol {
    func signUp(signUp: SignUp) async throws -> Shopkeeper {
        var shopkeeper: Shopkeeper

        do {
            let signUpsService = SignUpsService(networkClient: NativeAppTemplateAPI(
                authToken: "",
                client: "",
                expiry: "",
                uid: "",
                accountId: ""
            ))
            shopkeeper = try await signUpsService.makeShopkeeper(signUp: signUp)
        } catch {
            Failure
                .fetch(from: Self.self, reason: error.codedDescription)
                .log()
            throw error
        }
        return shopkeeper
    }

    func update(id: String, signUp: SignUp, networkClient: NativeAppTemplateAPI) async throws -> Shopkeeper {
        var shopkeeper: Shopkeeper

        do {
            let signUpsService = SignUpsService(networkClient: networkClient)
            shopkeeper = try await signUpsService.updateShopkeeper(id: id, signUp: signUp)
        } catch {
            Failure
                .update(from: Self.self, reason: error.codedDescription)
                .log()
            throw error
        }
        return shopkeeper
    }

    func destroy(networkClient: NativeAppTemplateAPI) async throws {
        do {
            let signUpsService = SignUpsService(networkClient: networkClient)
            try await signUpsService.destroyShopkeeper()
            removeShopkeeper()
        } catch {
            Failure
                .fetch(from: Self.self, reason: error.codedDescription)
                .log()
            removeShopkeeper()

            throw error
        }
    }

    func sendResetPasswordInstruction(sendResetPassword: SendResetPassword) async throws {
        do {
            let signUpsService = SignUpsService(networkClient: NativeAppTemplateAPI(
                authToken: "",
                client: "",
                expiry: "",
                uid: "",
                accountId: ""
            ))
            try await signUpsService.sendResetPasswordInstruction(sendResetPassword: sendResetPassword)
        } catch {
            Failure
                .fetch(from: Self.self, reason: error.codedDescription)
                .log()

            throw error
        }
    }

    func sendConfirmationInstruction(sendConfirmation: SendConfirmation) async throws {
        do {
            let signUpsService = SignUpsService(networkClient: NativeAppTemplateAPI(
                authToken: "",
                client: "",
                expiry: "",
                uid: "",
                accountId: ""
            ))
            try await signUpsService.sendConfirmationInstruction(sendConfirmation: sendConfirmation)
        } catch {
            Failure
                .fetch(from: Self.self, reason: error.codedDescription)
                .log()
            throw error
        }
    }

    private func removeShopkeeper() {
        let keychainStore = LoggedInShopkeeperKeychainStore()

        do {
            try keychainStore.remove()
        } catch {
            appLogger.debug("SignUpRepository remove error: \(error, privacy: .private)")
        }
    }
}
