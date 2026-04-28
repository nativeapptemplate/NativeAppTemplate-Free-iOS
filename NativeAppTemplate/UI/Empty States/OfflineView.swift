//
//  OfflineView.swift
//  NativeAppTemplate
//

import SwiftUI

struct OfflineView: View {
    var body: some View {
        VStack {
            Spacer()

            GlassCard {
                VStack {
                    Image(systemName: "wifi.slash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: NativeAppTemplateConstants.Spacing.xxxl)
                        .padding()
                        .foregroundStyle(.titleText)

                    Text(Strings.noConnection)
                        .font(.uiTitle1)
                        .foregroundStyle(.titleText)
                        .multilineTextAlignment(.center)
                        .padding(.top)

                    Text(Strings.checkInternetConnection)
                        .font(.uiLabel)
                        .lineSpacing(NativeAppTemplateConstants.Spacing.xxs)
                        .foregroundStyle(.contentText)
                        .multilineTextAlignment(.center)
                        .padding(.top, NativeAppTemplateConstants.Spacing.xxxs)
                }
            }
            .padding(.horizontal, NativeAppTemplateConstants.Spacing.lg)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OfflineView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineView()
    }
}
