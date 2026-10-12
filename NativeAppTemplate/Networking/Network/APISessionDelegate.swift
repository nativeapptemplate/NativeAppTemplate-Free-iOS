//
//  APISessionDelegate.swift
//  NativeAppTemplate
//

import Foundation

/// The delegate of `URLSession.api`: it keeps the session headers from following a redirect
/// to another host. TLS trust is left to the system's default evaluation.
final class APISessionDelegate: NSObject, URLSessionTaskDelegate {
    /// The host that gets the session headers (`Service.makeRequest`)
    let apiHost: String

    init(apiHost: String = Strings.domain) {
        self.apiHost = apiHost
    }

    /// The devise_token_auth headers `Service.makeRequest` adds; together they are a session
    static let sessionHeaderNames = ["access-token", "token-type", "client", "expiry", "uid"]

    /// URLSession copies custom headers to every redirect hop, so drop the session
    /// when a redirect leaves the API host.
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        guard request.url?.host?.lowercased() != apiHost.lowercased() else {
            completionHandler(request)
            return
        }

        var request = request
        for name in Self.sessionHeaderNames {
            request.setValue(nil, forHTTPHeaderField: name)
        }
        completionHandler(request)
    }
}

extension URLSession {
    private static let apiSessionDelegate = APISessionDelegate()

    /// API responses carry the shopkeeper's data, and Rails sends them with
    /// `Cache-Control: max-age=0, private, must-revalidate`, which the default
    /// configuration's `URLCache` keeps on disk (Library/Caches) past sign-out.
    /// The API authenticates with headers, not cookies, so the session keeps
    /// neither a URL cache nor a cookie store.
    static let api: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        return URLSession(
            configuration: configuration,
            delegate: apiSessionDelegate,
            delegateQueue: nil
        )
    }()
}
