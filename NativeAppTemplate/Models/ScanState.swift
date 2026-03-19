//
//  ScanState.swift
//  NativeAppTemplate
//

enum ScanState: String, Identifiable, CaseIterable, Codable {
    case unscanned,
         scanned

    var id: Self {
        self
    }

    init(string: String) {
        switch string {
        case "unscanned":
            self = .unscanned
        case "scanned":
            self = .scanned
        default:
            self = .unscanned
        }
    }

    func toJson() -> String {
        switch self {
        case .unscanned:
            "unscanned"
        case .scanned:
            "scanned"
        }
    }

    var displayString: String {
        switch self {
        case .unscanned:
            "Unscanned"
        case .scanned:
            "Scanned"
        }
    }
}
