//
//  DataState.swift
//  NativeAppTemplate
//

enum DataState {
    case initial
    case loading
    case hasData
    case failed
}

/// What a list screen shows for its `DataState`.
enum ListContent {
    case loading
    case list
    case failed
}

extension DataState {
    /// A reload keeps the list already on screen instead of blinking a full-screen
    /// LoadingView over it. It is the same `.list` case as `.hasData` on purpose: a
    /// separate `switch` branch is a different view to SwiftUI, so the list would be
    /// rebuilt on every reload, re-registering its `navigationDestination` and re-running
    /// its `.task`. In MyTurnTagCreator that turned a reload after each tag change into a
    /// loop that hit the API's rate limit.
    func listContent(isEmpty: Bool) -> ListContent {
        switch self {
        case .initial:
            .loading
        case .loading:
            isEmpty ? .loading : .list
        case .hasData:
            .list
        case .failed:
            .failed
        }
    }
}
