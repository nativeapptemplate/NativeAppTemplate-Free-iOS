//
//  Service.swift
//  NativeAppTemplate
//

import Foundation
import SwiftyJSON

protocol Service {
    var networkClient: NativeAppTemplateAPI { get }
    var session: URLSession { get }
}

extension Service {
    var session: URLSession {
        .pinned
    }
}

extension Service {
    var isAuthenticated: Bool {
        !networkClient.authToken.isEmpty
    }

    @MainActor func makeRequest<Request: NativeAppTemplate.Request>(
        request: Request
    ) async throws -> Request.Response {
        func prepare(
            request: some NativeAppTemplate.Request
        ) throws -> URLRequest {
            var pathURL = networkClient.environment.baseURL.appendingPathComponent(networkClient.accountId)
            pathURL = pathURL.appendingPathComponent(networkClient.environment.basePath)
            pathURL = pathURL.appendingPathComponent(request.path)

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

            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // body *needs* to be the last property that we set, because of this bug:
            // https://bugs.swift.org/browse/SR-6687
            urlRequest.httpBody = request.body

            let headerAccessToken: HTTPHeader = ("access-token", networkClient.authToken)
            let headerTokenType: HTTPHeader = ("token-type", "Bearer")
            let headerClient: HTTPHeader = ("client", networkClient.client)
            let headerExpiry: HTTPHeader = ("expiry", networkClient.expiry)
            let headerUid: HTTPHeader = ("uid", networkClient.uid)
            let headerSource: HTTPHeader = ("source", "ios")

            let headers =
                [headerAccessToken, headerTokenType, headerClient, headerExpiry, headerUid, headerSource]
                    + [networkClient.additionalHeaders, request.additionalHeaders].joined()
            headers.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }

            return urlRequest
        }

        let (data, response) = try await session.data(
            for: prepare(request: request)
        )

        let statusCode = (response as? HTTPURLResponse)?.statusCode
        guard statusCode.map((200 ..< 300).contains) == true
        else {
            var errorMessage: String?
            var json: JSON?

            do {
                json = try JSON(data: data)
                if let json, let theErrorMessage = json["error_message"].string {
                    errorMessage = theErrorMessage
                }
            } catch {
                throw NativeAppTemplateAPIError.requestFailed(nil, statusCode ?? 0, "")
            }

            throw NativeAppTemplateAPIError.requestFailed(nil, statusCode ?? 0, errorMessage)
        }

        return try request.handle(response: data)
    }
}
