//
//  ShopListCardView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ShopListCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let shop: Shop

    /// How the counts are laid out at a text size
    enum StatsLayout: Equatable {
        /// The icons, numbers and labels in aligned columns
        case grid
        /// Each label under its icon and number, the card's full width. At the
        /// accessibility sizes the label column of the grid is too narrow and its
        /// text is cut off ("completed ite…")
        case stacked
    }

    static func statsLayout(for dynamicTypeSize: DynamicTypeSize) -> StatsLayout {
        dynamicTypeSize.isAccessibilitySize ? .stacked : .grid
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(shop.name)
                .font(.uiTitle4)
                .foregroundStyle(.accent)

            Group {
                switch Self.statsLayout(for: dynamicTypeSize) {
                case .grid:
                    Grid(
                        alignment: .leadingFirstTextBaseline,
                        horizontalSpacing: NativeAppTemplateConstants.Spacing.xs,
                        verticalSpacing: NativeAppTemplateConstants.Spacing.xxxs
                    ) {
                        GridRow {
                            statImage("flag.checkered")
                            statCount(shop.completedItemTagsCount)
                            statLabel("completed item tags")
                        }

                        GridRow {
                            statImage("rectangle.stack")
                            statCount(shop.itemTagsCount)
                            statLabel("all item tags")
                        }
                    }
                case .stacked:
                    VStack(alignment: .leading, spacing: NativeAppTemplateConstants.Spacing.xs) {
                        stackedStat(
                            image: "flag.checkered",
                            count: shop.completedItemTagsCount,
                            label: "completed item tags"
                        )
                        stackedStat(image: "rectangle.stack", count: shop.itemTagsCount, label: "all item tags")
                    }
                }
            }
            .padding(.top)

            Text(shop.description)
                .font(.uiCaption)
                .foregroundStyle(.contentText)
                .padding(.top)
        }
        .padding()
    }
}

private extension ShopListCardView {
    func statImage(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .frame(width: 12, height: 12)
            .foregroundStyle(.secondaryText)
            .accessibilityHidden(true)
    }

    func statCount(_ count: Int) -> some View {
        Text(String(count))
            .font(.uiLabelBold)
    }

    func statLabel(_ label: LocalizedStringKey) -> some View {
        Text(label)
            .font(.uiFootnote)
            .foregroundStyle(.contentText)
            .fixedSize(horizontal: false, vertical: true)
    }

    func stackedStat(image: String, count: Int, label: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: NativeAppTemplateConstants.Spacing.xxxs) {
            HStack(alignment: .firstTextBaseline, spacing: NativeAppTemplateConstants.Spacing.xs) {
                statImage(image)
                statCount(count)
            }
            statLabel(label)
        }
    }
}
