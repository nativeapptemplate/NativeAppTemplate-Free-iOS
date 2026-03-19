//
//  TabViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
@Suite
struct TabViewModelTest {
    @Test
    func initialState() {
        let viewModel = TabViewModel()

        #expect(viewModel.selectedTab == .shops)
        for tab in MainTab.allCases {
            #expect(viewModel.showingDetailView[tab] == false)
        }
    }

    @Test
    func showingDetailView() {
        let viewModel = TabViewModel()

        viewModel.showingDetailView[.shops] = true
        #expect(viewModel.showingDetailView[.shops] == true)
        #expect(viewModel.showingDetailView[.scan] == false)
        #expect(viewModel.showingDetailView[.settings] == false)

        viewModel.showingDetailView[.shops] = false
        #expect(viewModel.showingDetailView[.shops] == false)
    }
}
