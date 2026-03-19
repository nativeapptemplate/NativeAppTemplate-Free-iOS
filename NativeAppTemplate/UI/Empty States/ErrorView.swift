//
//  ErrorView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ErrorView {
    private var titleText = "Something went wrong."
    private var bodyText = "Please try again."
    private var buttonTitle = "Reload"
    private var buttonAction: () -> Void

    init(
        buttonAction: @escaping () -> Void,
        titleText: String = "Something went wrong.",
        bodyText: String = "Please try again.",
        buttonTitle: String = "Reload"
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
        ZStack {
            VStack {
                Spacer()

                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 96)
                    .padding()
                    .foregroundStyle(.titleText)

                Text(titleText)
                    .font(.uiTitle1)
                    .foregroundStyle(.titleText)
                    .padding(.top)

                Text(bodyText)
                    .font(.uiLabel)
                    .foregroundStyle(.contentText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                MainButtonView(
                    title: buttonTitle,
                    type: .primary(withArrow: false),
                    callback: buttonAction
                )
                .padding(32)

                Spacer()
            }
            .background(Color.backgroundColor)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(buttonAction: {}).inAllColorSchemes
    }
}
