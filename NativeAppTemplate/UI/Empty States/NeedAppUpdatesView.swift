//
//  NeedAppUpdatesView.swift
//  NativeAppTemplate
//

import SwiftUI

struct NeedAppUpdatesView: View {
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack {
            Spacer()

            GlassCard {
                VStack {
                    Image(systemName: "exclamationmark.arrow.circlepath")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: NativeAppTemplateConstants.Spacing.xxxl)
                        .foregroundStyle(.titleText)
                        .padding()
                    Text(Strings.updateApp)
                        .font(.uiTitle1)
                        .foregroundStyle(.titleText)
                        .padding(.top)
                    Text(Strings.installNewVersionApp)
                        .foregroundStyle(.contentText)
                        .padding(.top, NativeAppTemplateConstants.Spacing.xxxs)
                    Button {
                        openURL(URL(string: Strings.appStoreUrl)!)
                    } label: {
                        Text(Strings.updateApp)
                    }
                    .padding(.top)
                }
            }
            .padding(.horizontal, NativeAppTemplateConstants.Spacing.lg)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NeedAppUpdatesView()
}
