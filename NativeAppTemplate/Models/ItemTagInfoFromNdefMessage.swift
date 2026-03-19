//
//  ItemTagInfoFromNdefMessage.swift
//  NativeAppTemplate
//

import Foundation

struct ItemTagInfoFromNdefMessage {
    var id: String
    var type: String
    var success: Bool
    var message: String

    init() {
        id = ""
        type = ""
        success = false
        message = .messageWrittenOnTagIsWrong
    }
}
