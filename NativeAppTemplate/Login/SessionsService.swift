//
//  SessionsService.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2020/04/05.
//  Copyright © 2024 Daisuke Adachi All rights reserved.
//

import Foundation
import SwiftyJSON

struct SessionsService {
  var networkClient: NativeAppTemplateAPI
  var session = URLSession(configuration: .default)
}

extension SessionsService {
  func makeSession(email: String, password: String) async throws -> Shopkeeper {
    try await makeRequest(request: MakeSessionRequest(email: email, password: password))
  }

  func destroySession() async throws -> DestroySessionRequest.Response {
    try await makeRequest(request: DestroySessionRequest())
  }

  @MainActor func makeRequest<Request: NativeAppTemplate.Request>(
    request: Request,
    parameters: [Parameter]? = nil
  ) async throws -> Request.Response {
    func prepare<RequestType: NativeAppTemplate.Request>(
      request: RequestType,
      parameters: [Parameter]? = nil
    ) throws -> URLRequest {
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

      // body *needs* to be the last property that we set, because of this bug: https://bugs.swift.org/browse/SR-6687
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

      if !headerAccessToken.value.isEmpty {
        headers.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
      }

      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.setValue("ios", forHTTPHeaderField: "source")
      
      return urlRequest
    }

    let (data, response) = try await session.data(
      for: try prepare(request: request)
    )

    let statusCode = (response as? HTTPURLResponse)?.statusCode
    guard statusCode.map((200..<300).contains) == true
    else {
      var errorMessage: String?
      var json: JSON?

      do {
        json = try JSON(data: data)
        if let json = json, let theErrorMessage = json["error_message"].string {
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
