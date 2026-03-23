//
//  MeService.swift
//  NativeAppTemplate
//

struct MeService: Service {
    var networkClient = NativeAppTemplateAPI()
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
