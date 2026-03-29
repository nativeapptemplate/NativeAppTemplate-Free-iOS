//
//  CompletedTag.swift
//  NativeAppTemplate
//

import SwiftUI

struct CompletedTag: View {
    var body: some View {
        TagView(
            text: "completed",
            textColor: .completedTagForeground,
            backgroundColor: .completedTagBackground,
            borderColor: .completedTagBorder
        )
    }
}

struct CompletedTag_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: NativeAppTemplateConstants.Spacing.xs) {
            completedTag.colorScheme(.light)
            completedTag.colorScheme(.dark)
        }
    }

    static var completedTag: some View {
        CompletedTag()
            .padding()
            .background(Color.backgroundColor)
    }
}
