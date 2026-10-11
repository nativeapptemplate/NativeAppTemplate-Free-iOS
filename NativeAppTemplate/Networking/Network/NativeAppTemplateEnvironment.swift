//
//  NativeAppTemplateEnvironment.swift
//  NativeAppTemplate
//

import struct Foundation.URL

struct NativeAppTemplateEnvironment: Equatable {
    // MARK: - Properties

    var baseURL: URL
    let basePath = "/api/v1"
}

extension NativeAppTemplateEnvironment {
    static let urlString = if Strings.port.isEmpty {
        "\(Strings.scheme)://\(Strings.domain)"
    } else {
        "\(Strings.scheme)://\(Strings.domain):\(Strings.port)"
    }

    static let prod = NativeAppTemplateEnvironment(baseURL: URL(string: urlString)!)
}

struct APIEndpoint: Equatable {
    let scheme: String
    let domain: String
    let port: String

    static let production = APIEndpoint(scheme: "https", domain: "api.nativeapptemplate.com", port: "")

    /// Scheme environment variables reach the app only when Xcode or
    /// `simctl launch` starts it, so the value built into Info.plist (from
    /// API.xcconfig) covers Home Screen launches and iOS's relaunch after the
    /// app's language changes.
    static func resolve(environment: [String: String], info: [String: Any]) -> APIEndpoint {
        func value(_ environmentKey: String, _ infoKey: String, _ fallback: String) -> String {
            if let value = environment[environmentKey], !value.isEmpty {
                return value
            }
            if let value = info[infoKey] as? String, !value.isEmpty {
                return value
            }
            return fallback
        }

        return APIEndpoint(
            scheme: value("NATIVEAPPTEMPLATE_API_SCHEME", "NativeAppTemplateAPIScheme", production.scheme),
            domain: value("NATIVEAPPTEMPLATE_API_DOMAIN", "NativeAppTemplateAPIDomain", production.domain),
            port: value("NATIVEAPPTEMPLATE_API_PORT", "NativeAppTemplateAPIPort", production.port)
        )
    }
}
