//
//  GlassButtonStyle.swift
//  NativeAppTemplate
//

import SwiftUI

struct PrimaryGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.uiButtonLabelLarge)
            .foregroundStyle(.glassForeground)
            .padding(.vertical, NativeAppTemplateConstants.Spacing.sm)
            .padding(.horizontal, NativeAppTemplateConstants.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.accent, Color.accent.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: NativeAppTemplateConstants.CornerRadius.sm))
            .shadow(
                color: Color.accent.opacity(NativeAppTemplateConstants.Glass.shadowOpacity),
                radius: NativeAppTemplateConstants.Layout.shadowRadius
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: NativeAppTemplateConstants.Animation.fast), value: configuration.isPressed)
    }
}

struct SecondaryGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.uiButtonLabelLarge)
            .foregroundStyle(.accent)
            .padding(.vertical, NativeAppTemplateConstants.Spacing.sm)
            .padding(.horizontal, NativeAppTemplateConstants.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: NativeAppTemplateConstants.CornerRadius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: NativeAppTemplateConstants.CornerRadius.sm)
                    .stroke(Color.accent, lineWidth: NativeAppTemplateConstants.Layout.borderWidth)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: NativeAppTemplateConstants.Animation.fast), value: configuration.isPressed)
    }
}
