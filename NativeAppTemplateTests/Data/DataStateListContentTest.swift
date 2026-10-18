//
//  DataStateListContentTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

/// List screens switch on `listContent(isEmpty:)`. A reload of a list already on screen
/// must stay `.list`, the same case as `.hasData`: as a branch of its own, SwiftUI rebuilds
/// the list on every reload and re-runs its `.task`. In MyTurnTagCreator 2.1.0 that made the
/// Shops tab reload about twice a second while shop detail was open.
@Suite
struct DataStateListContentTest {
    @Test
    func reloadingWithDataKeepsTheList() {
        // A reload with shops on screen (.loading), then .hasData: both the one `.list` case.
        #expect(DataState.loading.listContent(isEmpty: false) == .list)
        #expect(DataState.hasData.listContent(isEmpty: false) == .list)
    }

    @Test
    func firstLoadShowsLoading() {
        #expect(DataState.initial.listContent(isEmpty: true) == .loading)
        #expect(DataState.loading.listContent(isEmpty: true) == .loading)
    }

    @Test
    func loadedEmptyListIsStillTheList() {
        // An empty result is shown by the list view itself (e.g. "no shops yet")
        #expect(DataState.hasData.listContent(isEmpty: true) == .list)
    }

    @Test
    func failureShowsTheErrorView() {
        #expect(DataState.failed.listContent(isEmpty: true) == .failed)
        #expect(DataState.failed.listContent(isEmpty: false) == .failed)
    }
}
