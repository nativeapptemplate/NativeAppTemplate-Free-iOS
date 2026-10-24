//
//  TabViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
struct TabViewModelTest {
    @Test
    func initialState() {
        let viewModel = TabViewModel()

        #expect(viewModel.selectedTab == .shops)
        for tab in MainTab.allCases {
            #expect(viewModel.showingDetailView[tab] == false)
        }
    }

    /// The app opens on one tab, named once (`MainTab.initial`): the selected tab and
    /// the environment default must not drift apart
    @Test
    func initialTabIsTheEnvironmentDefault() {
        #expect(TabViewModel().selectedTab == MainTab.initial)
        #expect(MainTab.defaultValue == MainTab.initial)
    }

    @Test
    func showingDetailView() {
        let viewModel = TabViewModel()

        viewModel.showingDetailView[.shops] = true
        #expect(viewModel.showingDetailView[.shops] == true)
        #expect(viewModel.showingDetailView[.settings] == false)

        viewModel.showingDetailView[.shops] = false
        #expect(viewModel.showingDetailView[.shops] == false)
    }
}
