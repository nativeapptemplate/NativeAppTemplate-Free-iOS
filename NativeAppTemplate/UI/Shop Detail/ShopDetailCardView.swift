//
//  ShopDetailCardView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ShopDetailCardView: View {
    let itemTag: ItemTag

    var body: some View {
        content
    }

    var content: some View {
        HStack {
            Text(String(itemTag.name))
                .font(.uiTitle4)

            Spacer()

            // TODO: removed in Phase 2A-2 — scanState/customerReadAt column dropped with ItemTag schema v2

            VStack(alignment: .trailing) {
                if itemTag.state == .completed {
                    CompletedTag()

                    if let completedAt = itemTag.completedAt {
                        Text(completedAt.cardTimeString)
                            .font(.uiFootnote)
                            .foregroundStyle(.contentText)
                    }
                } else {
                    IdlingTag()
                }
            }
            .frame(minWidth: 82, alignment: .trailing)
        }
        .frame(minHeight: NativeAppTemplateConstants.Spacing.xl)
    }
}
