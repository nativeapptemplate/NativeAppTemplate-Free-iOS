//
//  SignUpRepositoryProtocol.swift
//  NativeAppTemplate
//

import Foundation

@MainActor protocol SignUpRepositoryProtocol: AnyObject, Sendable {
    func signUp(signUp: SignUp) async throws -> Shopkeeper
    func update(id: String, signUp: SignUp, networkClient: NativeAppTemplateAPI) async throws -> Shopkeeper
    func destroy(networkClient: NativeAppTemplateAPI) async throws
    func sendResetPasswordInstruction(sendResetPassword: SendResetPassword) async throws
    func sendConfirmationInstruction(sendConfirmation: SendConfirmation) async throws
}
