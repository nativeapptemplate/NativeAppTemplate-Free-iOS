//
//  IdledTagView.swift
//  NativeAppTemplate
//

import SwiftUI

struct IdledTag: View {
    var body: some View {
        TagView(
            text: "idled",
            textColor: .idledTagForeground,
            backgroundColor: .idledTagBackground,
            borderColor: .idledTagBorder
        )
    }
}

struct IdledTag_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: NativeAppTemplateConstants.Spacing.xs) {
            idledTag.colorScheme(.light)
            idledTag.colorScheme(.dark)
        }
    }

    static var idledTag: some View {
        IdledTag()
            .padding()
            .background(Color.backgroundColor)
    }
}
