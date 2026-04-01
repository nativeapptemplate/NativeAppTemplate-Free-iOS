//
//  JSONAPIErrorSource.swift
//  NativeAppTemplate
//

public class JSONAPIErrorSource {
    // MARK: - Properties

    var pointer: String = ""
    var parameter: String = ""

    // MARK: - Initializers

    convenience init(_ json: Any) {
        self.init()

        guard let dict = json as? [String: Any] else { return }

        pointer = (dict["pointer"] as? String) ?? ""
        parameter = (dict["parameter"] as? String) ?? ""
    }
}
