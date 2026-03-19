//
//  MeService.swift
//  NativeAppTemplate
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
