//
//  TagView.swift
//  NativeAppTemplate
//

import SwiftUI

struct TagView: View {
    private static let defaultIconHeight: CGFloat = 12.0

    private struct SizeKey: PreferenceKey {
        static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
            value = value ?? nextValue()
        }
    }

    @State private var height: CGFloat?

    let text: String
    let textColor: Color
    let backgroundColor: Color
    let borderColor: Color
    var image: Image?

    var body: some View {
        HStack(spacing: NativeAppTemplateConstants.Spacing.xxxs) {
            image?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(textColor)
                .frame(height: Self.defaultIconHeight)

            Text(text.uppercased())
                .foregroundStyle(textColor)
                .font(.uiUppercaseTag)
                .kerning(0.5)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: SizeKey.self, value: proxy.size)
                    }
                )
        }
        .padding([.vertical], NativeAppTemplateConstants.Spacing.xxxs)
        .padding([.horizontal], NativeAppTemplateConstants.Spacing.xxs)
        .background(backgroundColor)
        .cornerRadius(NativeAppTemplateConstants.CornerRadius.xs) // This is a bit hacky.
        .onPreferenceChange(SizeKey.self) { size in
            Task { @MainActor in
                height = size?.height
            }
        }
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 18) {
            TagView(
                text: "this is a tag",
                textColor: .white,
                backgroundColor: .red,
                borderColor: .yellow
            )

            TagView(
                text: "with an image",
                textColor: .white,
                backgroundColor: .red,
                borderColor: .yellow,
                image: Image(systemName: "checkmark")
            )
        }
    }
}
