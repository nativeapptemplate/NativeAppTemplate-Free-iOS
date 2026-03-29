//
//  IdlingTagView.swift
//  NativeAppTemplate
//

import SwiftUI

struct IdlingTag: View {
    var body: some View {
        TagView(
            text: "idling",
            textColor: .idlingTagForeground,
            backgroundColor: .idlingTagBackground,
            borderColor: .idlingTagBorder
        )
    }
}

struct IdlingTag_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: NativeAppTemplateConstants.Spacing.xs) {
            idlingTag.colorScheme(.light)
            idlingTag.colorScheme(.dark)
        }
    }

    static var idlingTag: some View {
        IdlingTag()
            .padding()
            .background(Color.backgroundColor)
    }
}
