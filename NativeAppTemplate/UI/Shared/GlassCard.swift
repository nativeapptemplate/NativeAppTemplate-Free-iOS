//
//  GlassCard.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat
    var padding: CGFloat
    @ViewBuilder var content: Content

    init(
        cornerRadius: CGFloat = NativeAppTemplateConstants.CornerRadius.lg,
        padding: CGFloat = NativeAppTemplateConstants.Spacing.md,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        Color.glassBorder.opacity(NativeAppTemplateConstants.Glass.borderOpacity),
                        lineWidth: NativeAppTemplateConstants.Layout.borderWidth
                    )
            )
            .shadow(
                color: .glassShadow.opacity(NativeAppTemplateConstants.Glass.shadowOpacity),
                radius: NativeAppTemplateConstants.Layout.shadowRadius
            )
    }
}
