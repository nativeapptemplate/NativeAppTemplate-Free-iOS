//
//  MainButtonView.swift
//  NativeAppTemplate
//

import SwiftUI

enum MainButtonType {
    case primary(withArrow: Bool)
    case secondary(withArrow: Bool)
    case destructive(withArrow: Bool)
    case coloredPrimary(withArrow: Bool)
    case coloredSecondary(withArrow: Bool)
    case server(withArrow: Bool)
    case customer(withArrow: Bool)

    var color: Color {
        switch self {
        case .primary:
            .primaryButtonForeground
        case .secondary:
            .secondaryButtonForeground
        case .coloredPrimary:
            .coloredPrimaryButtonForeground
        case .coloredSecondary:
            .coloredSecondaryButtonForeground
        case .destructive:
            .destructiveButtonForeground
        case .server:
            .serverForeground
        case .customer:
            .customerForeground
        }
    }

    var hasArrow: Bool {
        switch self {
        case
            let .primary(hasArrow),
            let .secondary(hasArrow),
            let .coloredPrimary(hasArrow),
            let .coloredSecondary(hasArrow),
            let .destructive(hasArrow),
            let .server(hasArrow),
            let .customer(hasArrow):
            hasArrow
        }
    }
}

struct MainButtonView: View {
    private struct SizeKey: PreferenceKey {
        static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
            value = value ?? nextValue()
        }
    }

    @State private var height: CGFloat?
    var title: String
    var type: MainButtonType
    var callback: () -> Void

    var body: some View {
        Button {
            callback()
        } label: {
            HStack {
                ZStack(alignment: .center) {
                    HStack {
                        Spacer()

                        Text(title)
                            .font(.uiButtonLabelLarge)
                            .foregroundStyle(type.color)
                            .padding(NativeAppTemplateConstants.Spacing.sm)

                        Spacer()
                    }

                    if type.hasArrow {
                        HStack {
                            Spacer()

                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: height, height: height)
                                .foregroundStyle(type.color)
                                .background(
                                    Color.arrowBackground
                                        .cornerRadius(NativeAppTemplateConstants.CornerRadius.sm)
                                        .padding(NativeAppTemplateConstants.Spacing.xs)
                                )
                        }
                    }
                }
                .frame(height: height)
                .background(
                    RoundedRectangle(cornerRadius: NativeAppTemplateConstants.CornerRadius.sm)
                        .stroke(type.color, lineWidth: 2)
                )
                .onPreferenceChange(SizeKey.self) { size in
                    Task { @MainActor in
                        height = size?.height
                    }
                }
            }
        }
    }
}

struct MainButtonImageView: View {
    private struct SizeKey: PreferenceKey {
        static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
            value = value ?? nextValue()
        }
    }

    @State private var height: CGFloat?
    var title: String
    var type: MainButtonType

    var body: some View {
        HStack {
            ZStack(alignment: .center) {
                HStack {
                    Spacer()

                    Text(title)
                        .font(.uiButtonLabelLarge)
                        .foregroundStyle(type.color)
                        .padding(NativeAppTemplateConstants.Spacing.sm)
                        .background(GeometryReader { proxy in
                            Color.clear.preference(key: SizeKey.self, value: proxy.size)
                        })

                    Spacer()
                }

                if type.hasArrow {
                    HStack {
                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: height, height: height)
                            .foregroundStyle(type.color)
                            .background(
                                Color.arrowBackground
                                    .cornerRadius(NativeAppTemplateConstants.CornerRadius.sm)
                                    .padding(NativeAppTemplateConstants.Spacing.xs)
                            )
                    }
                }
            }
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: NativeAppTemplateConstants.CornerRadius.sm)
                    .stroke(type.color, lineWidth: 2)
            )
            .onPreferenceChange(SizeKey.self) { size in
                Task { @MainActor in
                    height = size?.height
                }
            }
        }
    }
}

struct PrimaryButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: NativeAppTemplateConstants.Spacing.md) {
                MainButtonView(title: "Got It!", type: .primary(withArrow: false), callback: {})
                MainButtonView(title: "Got It!", type: .primary(withArrow: true), callback: {})
                MainButtonView(title: "Got It!", type: .secondary(withArrow: false), callback: {})
                MainButtonView(title: "Got It!", type: .secondary(withArrow: true), callback: {})
                MainButtonView(title: "Got It!", type: .destructive(withArrow: false), callback: {})
                MainButtonView(title: "Got It!", type: .destructive(withArrow: true), callback: {})

                Spacer()

                MainButtonImageView(title: "Got It!", type: .primary(withArrow: false))
                MainButtonImageView(title: "Got It!", type: .primary(withArrow: true))
                MainButtonImageView(title: "Got It!", type: .secondary(withArrow: false))
            }
        }
        .padding(NativeAppTemplateConstants.Spacing.md)
        .background(Color.backgroundColor)
        .inAllColorSchemes
    }
}
