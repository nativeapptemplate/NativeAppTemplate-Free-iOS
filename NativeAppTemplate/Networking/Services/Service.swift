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
