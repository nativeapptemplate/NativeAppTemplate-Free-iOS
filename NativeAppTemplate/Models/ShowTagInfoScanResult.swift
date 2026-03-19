//
//  ShowTagInfoScanResult.swift
//  NativeAppTemplate
//

import Foundation

enum ShowTagInfoScanResultType {
    case idled
    case succeeded
    case failed
}

struct ShowTagInfoScanResult {
    var itemTag: ItemTag?
    var itemTagType: ItemTagType = .server
    var isReadOnly = false
    var type: ShowTagInfoScanResultType = .idled
    var message = ""
    var scannedAt = Date.now
}
