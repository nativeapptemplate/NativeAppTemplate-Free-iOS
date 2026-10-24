//
//  Service.swift
//  NativeAppTemplate
//

import Foundation

/// A service for the API's account-scoped routes: every request goes to
/// baseURL/{accountId}/api/v1/{path}, with its query items and the session headers.
/// devise_token_auth's own routes, at the API root, use `RootPathService`.
protocol Service {
    var networkClient: NativeAppTemplateAPI { get }
    var session: URLSession { get }
}

extension Service {
    var session: URLSession {
        .api
    }
}

extension Service {
    func prepare(request: some NativeAppTemplate.Request) throws -> URLRequest {
        let pathURL = networkClient.environment.baseURL
            .appendingPathComponent(networkClient.accountId)
            .appendingPathComponent(networkClient.environment.basePath)
            .appendingPathComponent(request.path)

        var urlRequest = try URLRequest(url: pathURL, queryItems: request.queryItems, for: request)
        urlRequest.addHeaders(networkClient.sessionHeaders)
        return urlRequest
    }

    @MainActor func makeRequest<Request: NativeAppTemplate.Request>(
        request: Request
    ) async throws -> Request.Response {
        // Only these routes announce devise_token_auth's 401 as an expired session
        try await session.apiResponse(
            to: request,
            sending: prepare(request: request),
            announcingRejectionOf: networkClient.authToken
        )
    }
}

// MARK: - Shared by Service and RootPathService

extension URLRequest {
    /// A request to `url` (plus `queryItems`, if any) with `request`'s method and
    /// body, sent as JSON. The caller adds the session headers.
    init(url: URL, queryItems: [URLQueryItem], for request: some NativeAppTemplate.Request) throws {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else { throw URLError(.badURL) }

        self.init(url: url)
        httpMethod = request.method.rawValue
        setValue("application/json", forHTTPHeaderField: "Content-Type")

        // body *needs* to be the last property that we set, because of this bug:
        // https://bugs.swift.org/browse/SR-6687
        httpBody = request.body
    }

    mutating func addHeaders(_ headers: [HTTPHeader]) {
        headers.forEach { addValue($0.value, forHTTPHeaderField: $0.key) }
    }
}

@MainActor
extension URLSession {
    /// Sends `urlRequest` and hands a 2xx body to `request.handle(response:)`. Any
    /// other status throws `requestFailed` with the status and the API's
    /// `error_message`, if the body has one.
    ///
    /// - Parameter authToken: The token `urlRequest` was sent with, to announce as
    ///   rejected (`.apiSessionDidExpire`) when devise_token_auth answers with its 401.
    ///   `nil` never announces anything.
    func apiResponse<Request: NativeAppTemplate.Request>(
        to request: Request,
        sending urlRequest: URLRequest,
        announcingRejectionOf authToken: String?
    ) async throws -> Request.Response {
        let (data, response) = try await data(for: urlRequest)

        let statusCode = (response as? HTTPURLResponse)?.statusCode
        guard statusCode.map((200 ..< 300).contains) == true
        else {
            // Not JSON (e.g. a proxy's HTML error page) or no error_message: no message
            // to show, so the error falls back to its generic description
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let errorMessage = json?["error_message"] as? String

            // devise_token_auth rejects a missing, wrong or expired token with a 401
            // whose body has no error_message. The API's own 401 (a Pundit denial)
            // has one and keeps the session.
            if statusCode == 401, errorMessage == nil, let authToken, !authToken.isEmpty {
                NotificationCenter.default.post(
                    name: .apiSessionDidExpire,
                    object: nil,
                    userInfo: [Notification.authTokenKey: authToken]
                )
            }

            let error = NativeAppTemplateAPIError.requestFailed(nil, statusCode ?? 0, errorMessage)
            // The status is developer detail: the log gets it, the user the message
            Failure.request(from: Request.self, reason: error.debugCodedDescription).log()
            throw error
        }

        do {
            return try request.handle(response: data)
        } catch {
            Failure.request(from: Request.self, reason: error.debugCodedDescription).log()
            throw error
        }
    }
}

extension Notification.Name {
    /// Posted on the main actor when the API rejects a request's access token: a 401
    /// from devise_token_auth, e.g. once the token's lifespan is over. The rejected
    /// token is in `userInfo[Notification.authTokenKey]`, so a session that has
    /// since signed in again can tell the notice is not about it.
    static let apiSessionDidExpire = Notification.Name("NativeAppTemplate.apiSessionDidExpire")
}

extension Notification {
    static let authTokenKey = "authToken"
}
