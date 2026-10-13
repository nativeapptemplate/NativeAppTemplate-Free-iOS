//
//  SignUpService.swift
//  NativeAppTemplate
//

import Foundation

struct SignUpsService: RootPathService {
    var networkClient = NativeAppTemplateAPI()
    var session: URLSession = .api
}

extension SignUpsService {
    func makeShopkeeper(signUp: SignUp) async throws -> Shopkeeper {
        try await makeRequest(request: MakeShopkeeperRequest(signUp: signUp))
    }

    func updateShopkeeper(signUp: SignUp) async throws -> UpdateShopkeeperRequest.Response {
        let request = UpdateShopkeeperRequest(signUp: signUp)
        return try await makeRequest(request: request)
    }

    func updateLocale(_ locale: String) async throws -> UpdateLocaleRequest.Response {
        try await makeRequest(request: UpdateLocaleRequest(locale: locale))
    }

    func destroyShopkeeper() async throws -> DestroyShopkeeperRequest.Response {
        try await makeRequest(request: DestroyShopkeeperRequest())
    }

    func sendResetPasswordInstruction(sendResetPassword: SendResetPassword) async throws
        -> SendResetPasswordInstructionRequest.Response {
        try await makeRequest(request: SendResetPasswordInstructionRequest(sendResetPassword: sendResetPassword))
    }

    func sendConfirmationInstruction(sendConfirmation: SendConfirmation) async throws
        -> SendConfirmationInstructionRequest.Response {
        try await makeRequest(request: SendConfirmationInstructionRequest(sendConfirmation: sendConfirmation))
    }
}
