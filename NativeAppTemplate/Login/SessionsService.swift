//
//  SessionsService.swift
//  NativeAppTemplate
//

import Foundation

struct SessionsService: RootPathService {
    var networkClient: NativeAppTemplateAPI
    var session: URLSession = .api
}

extension SessionsService {
    func makeSession(email: String, password: String) async throws -> Shopkeeper {
        try await makeRequest(request: MakeSessionRequest(email: email, password: password))
    }

    func destroySession() async throws -> DestroySessionRequest.Response {
        try await makeRequest(request: DestroySessionRequest())
    }
}
