//
//  TagView.swift
//  NativeAppTemplate
//

import SwiftUI

struct TagView: View {
    private static let defaultIconHeight: CGFloat = 12.0

    let text: String
    let textColor: Color
    let backgroundColor: Color
    var image: Image?

    var body: some View {
        HStack(spacing: NativeAppTemplateConstants.Spacing.xxxs) {
            image?
                .resizable()
                .scaledToFit()
                .foregroundStyle(textColor)
                .frame(height: Self.defaultIconHeight)

            Text(text.uppercased())
                .foregroundStyle(textColor)
                // 13 pt: 10 pt was under the 11 pt Apple suggests, and hard to read in Japanese
                .font(.uiFootnote)
                .kerning(0.5)
        }
        .padding([.vertical], NativeAppTemplateConstants.Spacing.xxxs)
        .padding([.horizontal], NativeAppTemplateConstants.Spacing.xxs)
        .background(backgroundColor)
        .cornerRadius(NativeAppTemplateConstants.CornerRadius.xs) // This is a bit hacky.
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 18) {
            TagView(
                text: "this is a tag",
                textColor: .coolGrey10,
                backgroundColor: .red5
            )

            TagView(
                text: "with an image",
                textColor: .coolGrey10,
                backgroundColor: .red5,
                image: Image(systemName: "checkmark")
            )
        }
    }
}
