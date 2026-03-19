//
//  ItemTagType.swift
//  NativeAppTemplate
//

import Foundation

enum ItemTagType: String, CaseIterable, Identifiable, Codable {
    case server
    case customer

    var id: Self {
        self
    }

    init(string: String) {
        switch string {
        case "server":
            self = .server
        case "customer":
            self = .customer
        default:
            self = .server
        }
    }

    func toJson() -> String {
        switch self {
        case .server:
            "server"
        case .customer:
            "customer"
        }
    }

    var displayString: String {
        switch self {
        case .server:
            "Server"
        case .customer:
            "Customer"
        }
    }
}
