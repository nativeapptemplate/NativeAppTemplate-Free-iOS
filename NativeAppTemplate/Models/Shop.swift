//
//  Shop.swift
//  NativeAppTemplate
//

import Foundation

struct Shop: Codable, Identifiable, Sendable {
    var id: String
    var name: String
    var description: String
    var timeZone: String
    var itemTagsCount: Int = 0
    var scannedItemTagsCount: Int = 0
    var completedItemTagsCount: Int = 0
    var displayShopServerPath: String = ""
}

extension Shop {
    var displayShopServerUrl: URL {
        URL(string: "\(NativeAppTemplateEnvironment.prod.baseURL.absoluteString)\(displayShopServerPath)")!
    }

    func toJsonForCreate() -> [String: Any] {
        [
            "shop": [
                "name": name,
                "description": description,
                "time_zone": timeZone
            ] as [String: Any]
        ]
    }

    func toJsonForUpdate() -> [String: Any] {
        [
            "shop": [
                "name": name,
                "description": description,
                "time_zone": timeZone
            ] as [String: Any]
        ]
    }
}

extension Shop: Hashable {}
