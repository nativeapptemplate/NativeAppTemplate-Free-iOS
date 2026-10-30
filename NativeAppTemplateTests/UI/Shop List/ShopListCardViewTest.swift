//
//  ShopListCardViewTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import SwiftUI
import Testing

/// At the accessibility text sizes the card's labels were cut off ("completed ite…")
/// in the grid's narrow label column; there each label goes under its number instead
struct ShopListCardViewTest {
    @Test(arguments: [DynamicTypeSize.xSmall, .large, .xxxLarge])
    func standardSizesKeepTheGrid(size: DynamicTypeSize) {
        #expect(ShopListCardView.statsLayout(for: size) == .grid)
    }

    @Test(arguments: [DynamicTypeSize.accessibility1, .accessibility3, .accessibility5])
    func accessibilitySizesStackTheLabels(size: DynamicTypeSize) {
        #expect(ShopListCardView.statsLayout(for: size) == .stacked)
    }
}
