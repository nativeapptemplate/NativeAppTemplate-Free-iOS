//
//  MeService.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/12/23.
//

import class Foundation.URLSession

struct MeService: Service {
  var networkClient = NativeAppTemplateAPI()
  let session = URLSession(configuration: .default)
}

// MARK: - Internal
extension MeService {
  func updateConfirmedPrivacyVersion() async throws -> UpdateConfirmedPrivacyVersionRequest.Response {
    try await makeRequest(request: UpdateConfirmedPrivacyVersionRequest())
  }
  
  func updateConfirmedTermsVersion() async throws -> UpdateConfirmedTermsVersionRequest.Response {
    try await makeRequest(request: UpdateConfirmedTermsVersionRequest())
  }
}
