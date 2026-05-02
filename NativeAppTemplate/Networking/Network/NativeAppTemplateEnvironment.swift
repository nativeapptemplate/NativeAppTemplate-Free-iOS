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
