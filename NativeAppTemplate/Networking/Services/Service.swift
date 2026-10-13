//
//  Service.swift
//  NativeAppTemplate
//

import Foundation

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
    @MainActor func makeRequest<Request: NativeAppTemplate.Request>(
        request: Request
    ) async throws -> Request.Response {
        func prepare(
            request: some NativeAppTemplate.Request
        ) throws -> URLRequest {
            var pathURL = networkClient.environment.baseURL.appendingPathComponent(networkClient.accountId)
            pathURL = pathURL.appendingPathComponent(networkClient.environment.basePath)
            pathURL = pathURL.appendingPathComponent(request.path)

            guard var components = URLComponents(
                url: pathURL,
                resolvingAgainstBaseURL: false
            ) else {
                throw URLError(.badURL)
            }

            if !request.queryItems.isEmpty {
                components.queryItems = request.queryItems
            }

            guard let url = components.url
            else { throw URLError(.badURL) }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.method.rawValue

            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // body *needs* to be the last property that we set, because of this bug:
            // https://bugs.swift.org/browse/SR-6687
            urlRequest.httpBody = request.body

            networkClient.sessionHeaders.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }

            return urlRequest
        }

        let (data, response) = try await session.data(
            for: prepare(request: request)
        )

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
            if statusCode == 401, errorMessage == nil, !networkClient.authToken.isEmpty {
                NotificationCenter.default.post(
                    name: .apiSessionDidExpire,
                    object: nil,
                    userInfo: [Notification.authTokenKey: networkClient.authToken]
                )
            }

            throw NativeAppTemplateAPIError.requestFailed(nil, statusCode ?? 0, errorMessage)
        }

        return try request.handle(response: data)
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
