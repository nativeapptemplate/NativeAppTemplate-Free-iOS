//
//  AccountPasswordRepositoryProtocol.swift
//  NativeAppTemplate
//

import Foundation

@MainActor protocol AccountPasswordRepositoryProtocol: AnyObject, Observable, Sendable {
    init(accountPasswordService: AccountPasswordService)

    func update(updatePassword: UpdatePassword) async throws
}
