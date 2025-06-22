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

import Observation
import Foundation

typealias HTTPHeaders = [String: String]
typealias HTTPHeader = HTTPHeaders.Element

enum NativeAppTemplateAPIError: Error {
  case requestFailed(Error?, Int, String?)
  case processingError(Error?)
  case responseMissingRequiredMeta(field: String?)
  case responseHasIncorrectNumberOfElements
  case noData
}

extension NativeAppTemplateAPIError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .requestFailed(let error, let statusCode, let message):
      if let message = message {
        return "\(message) [Status: \(statusCode)]"
      } else {
        return "NativeAppTemplateAPIError::RequestFailed[Status: \(statusCode) | Error: \(error?.localizedDescription ?? "UNKNOWN")]"
      }
    case .processingError(let error):
      return "NativeAppTemplateAPIError::ProcessingError[Error: \(error?.localizedDescription ?? "UNKNOWN")]"
    case .responseMissingRequiredMeta(field: let field):
      return "NativeAppTemplateAPIError::ResponseMissingRequiredMeta[Field: \(field ?? "UNKNOWN")]"
    case .responseHasIncorrectNumberOfElements:
      return "NativeAppTemplateAPIError::ResponseHasIncorrectNumberOfElements"
    case .noData:
      return "NativeAppTemplateAPIError::NoData"
    }
  }
}

@MainActor
public struct NativeAppTemplateAPI: Equatable {
  nonisolated public static func == (lhs: NativeAppTemplateAPI, rhs: NativeAppTemplateAPI) -> Bool {
    lhs.environment == rhs.environment &&
    lhs.session == rhs.session &&
    lhs.authToken == rhs.authToken &&
    lhs.client == rhs.client &&
    lhs.expiry == rhs.expiry &&
    lhs.uid == rhs.uid &&
    lhs.accountId == rhs.accountId
  }

  // MARK: - Properties
  let environment: NativeAppTemplateEnvironment
  let session: URLSession
  let authToken: String
  let client: String
  let expiry: String
  let uid: String
  let accountId: String

  // MARK: - HTTP Headers
  let contentTypeHeader: HTTPHeader = ("Content-Type", "application/vnd.api+json; charset=utf-8")
  var additionalHeaders: HTTPHeaders = [:]

  nonisolated init() {
    self.init(authToken: "", client: "", expiry: "", uid: "", accountId: "")
  }

  // MARK: - Initializers
  nonisolated init(
    session: URLSession = .init(configuration: .default),
    environment: NativeAppTemplateEnvironment = .prod,
    authToken: String,
    client: String,
    expiry: String,
    uid: String,
    accountId: String
  ) {
    self.session = session
    self.environment = environment
    self.authToken = authToken
    self.client = client
    self.expiry = expiry
    self.uid = uid
    self.accountId = accountId
  }
}
