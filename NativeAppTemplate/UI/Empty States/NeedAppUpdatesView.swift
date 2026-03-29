//
//  NeedAppUpdatesView.swift
//  NativeAppTemplate
//

import SwiftUI

struct NeedAppUpdatesView: View {
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.arrow.circlepath")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: NativeAppTemplateConstants.Spacing.xxxl)
                .foregroundStyle(.titleText)
                .padding()
            Text(String.updateApp)
                .font(.uiTitle1)
                .foregroundStyle(.titleText)
                .padding(.top)
            Text(String.installNewVersionApp)
                .foregroundStyle(.contentText)
                .padding(.top, NativeAppTemplateConstants.Spacing.xxxs)
            Button {
                openURL(URL(string: String.appStoreUrl)!)
            } label: {
                Text(String.updateApp)
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    NeedAppUpdatesView()
}
