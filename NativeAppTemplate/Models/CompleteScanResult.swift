//
//  CompleteScanResult.swift
//  NativeAppTemplate
//

import Foundation

enum CompleteScanResultType {
    case idled
    case completed
    case reset
    case failed

    var displayString: String {
        switch self {
        case .idled:
            "Idling"
        case .completed:
            "Completed!"
        case .reset:
            "Reset!"
        case .failed:
            "Failed"
        }
    }
}

struct CompleteScanResult {
    var itemTag: ItemTag?
    var type: CompleteScanResultType = .idled
    var message = ""
    var scannedAt = Date.now
}
