//
//  JSONAPIErrorSource.swift
//  NativeAppTemplate
//

import SwiftyJSON

public class JSONAPIErrorSource {
    // MARK: - Properties

    var pointer: String = ""
    var parameter: String = ""

    // MARK: - Initializers

    convenience init(_ json: JSON) {
        self.init()

        pointer = json["pointer"].stringValue
        parameter = json["parameter"].stringValue
    }
}
