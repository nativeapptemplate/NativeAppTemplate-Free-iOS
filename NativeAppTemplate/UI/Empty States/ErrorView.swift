//
//  ErrorView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ErrorView {
    private var titleText: String
    private var bodyText: String
    private var buttonTitle: String
    private var buttonAction: () -> Void

    init(
        buttonAction: @escaping () -> Void,
        titleText: String = String(localized: "Something went wrong."),
        bodyText: String = String(localized: "Please try again."),
        buttonTitle: String = String(localized: "Reload")
    ) {
        self.titleText = titleText
        self.bodyText = bodyText
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
}

// MARK: - View {

extension ErrorView: View {
    var body: some View {
        VStack {
            Spacer()

            GlassCard {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: NativeAppTemplateConstants.Spacing.xxxl)
                        .padding()
                        .foregroundStyle(.titleText)
                        .accessibilityHidden(true)

                    Text(titleText)
                        .font(.uiTitle1)
                        .foregroundStyle(.titleText)
                        .padding(.top)

                    Text(bodyText)
                        .font(.uiLabel)
                        .foregroundStyle(.contentText)
                        .multilineTextAlignment(.center)
                        .padding(.top, NativeAppTemplateConstants.Spacing.xxxs)

                    MainButtonView(
                        title: buttonTitle,
                        type: .primary(withArrow: false),
                        callback: buttonAction
                    )
                    .padding(.top, NativeAppTemplateConstants.Spacing.lg)
                }
            }
            .padding(.horizontal, NativeAppTemplateConstants.Spacing.lg)

            Spacer()
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(buttonAction: {}).inAllColorSchemes
    }
}
