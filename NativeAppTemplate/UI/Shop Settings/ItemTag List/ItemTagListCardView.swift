//
//  ItemTagListCardView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ItemTagListCardView: View {
    let itemTag: ItemTag

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: NativeAppTemplateConstants.Spacing.xxs) {
                Text(itemTag.name)
                    .font(.uiTitle4)
                    .foregroundStyle(.titleText)

                if !itemTag.description.isEmpty {
                    Text(itemTag.description)
                        .font(.uiFootnote)
                        .foregroundStyle(.contentText)
                        .lineLimit(2)
                }
            }

            Spacer()

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
