//
//  AccountPasswordRepositoryProtocol.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import Foundation

@MainActor protocol AccountPasswordRepositoryProtocol: AnyObject, Observable, Sendable {
  init(accountPasswordService: AccountPasswordService)
  
  func update(updatePassword: UpdatePassword) async throws
}
