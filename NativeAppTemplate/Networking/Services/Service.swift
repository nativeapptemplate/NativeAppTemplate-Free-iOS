// Copyright (c) 2019 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import SwiftyJSON

protocol Service {
  var networkClient: NativeAppTemplateAPI { get }
  var session: URLSession { get }
}

extension Service {
  var isAuthenticated: Bool { !networkClient.authToken.isEmpty }

  @MainActor func makeRequest<Request: NativeAppTemplate.Request>(
    request: Request
  ) async throws -> Request.Response {
    func prepare<RequestType: NativeAppTemplate.Request>(
      request: RequestType
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
      headers.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
      
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
