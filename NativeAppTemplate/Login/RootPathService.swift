//
//  RootPathService.swift
//  NativeAppTemplate
//

import Foundation

/// A service for devise_token_auth's routes (sign-in, sign-up, passwords), which sit at
/// the API root, without the account and /api/v1 prefix that `Service` adds.
/// Signed out, the client has no token, so no session headers are sent.
protocol RootPathService {
    var networkClient: NativeAppTemplateAPI { get }
    var session: URLSession { get }
}

extension RootPathService {
    func prepare(request: some NativeAppTemplate.Request) throws -> URLRequest {
        let pathURL = networkClient.environment.baseURL.appendingPathComponent(request.path)

        guard let components = URLComponents(
            url: pathURL,
            resolvingAgainstBaseURL: false
        ) else {
            throw URLError(.badURL)
        }

        guard let url = components.url
        else { throw URLError(.badURL) }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        // body *needs* to be the last property that we set, because of this bug:
        // https://bugs.swift.org/browse/SR-6687
        urlRequest.httpBody = request.body

        if !networkClient.authToken.isEmpty {
            networkClient.sessionHeaders.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        }

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("ios", forHTTPHeaderField: "source")

        return urlRequest
    }

    @MainActor func makeRequest<Request: NativeAppTemplate.Request>(
        request: Request
    ) async throws -> Request.Response {
        let (data, response) = try await session.data(
            for: prepare(request: request)
        )

        let statusCode = (response as? HTTPURLResponse)?.statusCode
        guard statusCode.map((200 ..< 300).contains) == true
        else {
            var errorMessage: String?

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let theErrorMessage = json["error_message"] as? String {
                    errorMessage = theErrorMessage
                }
            } catch {
                // Not JSON (e.g. a proxy's HTML error page): no message to show,
                // so the error falls back to its generic description
                throw NativeAppTemplateAPIError.requestFailed(nil, statusCode ?? 0, nil)
            }

            throw NativeAppTemplateAPIError.requestFailed(nil, statusCode ?? 0, errorMessage)
        }

        return try request.handle(response: data)
    }
}
