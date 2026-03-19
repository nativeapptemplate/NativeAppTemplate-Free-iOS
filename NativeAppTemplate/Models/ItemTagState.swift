//
//  ItemTagState.swift
//  NativeAppTemplate
//

enum ItemTagState: String, CaseIterable, Identifiable, Codable {
    case idled,
         completed

    var id: Self {
        self
    }

    init(string: String) {
        switch string {
        case "idled":
            self = .idled
        case "completed":
            self = .completed
        default:
            self = .idled
        }
    }

    var displayString: String {
        switch self {
        case .idled:
            "Idling"
        case .completed:
            "Completed"
        }
    }
}
