//
//  RootPathService.swift
//  NativeAppTemplate
//

import Foundation

/// A service for devise_token_auth's routes (sign-in, sign-up, passwords), which sit at
/// the API root, without the account and /api/v1 prefix that `Service` adds.
/// Sending and error handling are shared with `Service` (see `URLSession.apiResponse`);
/// it differs in three ways:
/// - Signed out, the client has no token, so only the `source` header is sent.
/// - A request's query items are not sent. No devise_token_auth request has any.
/// - devise_token_auth's 401 is not announced as an expired session (`.apiSessionDidExpire`).
protocol RootPathService {
    var networkClient: NativeAppTemplateAPI { get }
    var session: URLSession { get }
}

extension RootPathService {
    func prepare(request: some NativeAppTemplate.Request) throws -> URLRequest {
        let pathURL = networkClient.environment.baseURL.appendingPathComponent(request.path)

        var urlRequest = try URLRequest(url: pathURL, queryItems: [], for: request)
        if networkClient.authToken.isEmpty {
            // No session to send, only the platform (which sessionHeaders also carry)
            urlRequest.addHeaders([NativeAppTemplateAPI.sourceHeader])
        } else {
            urlRequest.addHeaders(networkClient.sessionHeaders)
        }
        return urlRequest
    }

    @MainActor func makeRequest<Request: NativeAppTemplate.Request>(
        request: Request
    ) async throws -> Request.Response {
        try await session.apiResponse(
            to: request,
            sending: prepare(request: request),
            announcingRejectionOf: nil
        )
    }
}
