//
//  NeedAppUpdatesView.swift
//  NativeAppTemplate
//

import SwiftUI

struct NeedAppUpdatesView: View {
    @Environment(\.openURL) var openURL

    /// The app's App Store page (APP_STORE_ID in AppStore.xcconfig). nil, as committed, hides
    /// the Update App button; the text still asks users to install the new version.
    private let appStoreUrl: URL?

    init(appStoreUrl: URL? = Strings.appStoreUrl) {
        self.appStoreUrl = appStoreUrl
    }

    var body: some View {
        VStack {
            Spacer()

            GlassCard {
                VStack {
                    Image(systemName: "exclamationmark.arrow.circlepath")
                        .resizable()
                        .scaledToFit()
                        .frame(width: NativeAppTemplateConstants.Spacing.xxxl)
                        .foregroundStyle(.titleText)
                        .padding()
                        .accessibilityHidden(true)
                    Text(Strings.updateApp)
                        .font(.uiTitle1)
                        .foregroundStyle(.titleText)
                        .padding(.top)
                    Text(Strings.installNewVersionApp)
                        .foregroundStyle(.contentText)
                        .padding(.top, NativeAppTemplateConstants.Spacing.xxxs)
                    if let appStoreUrl {
                        Button {
                            openURL(appStoreUrl)
                        } label: {
                            Text(Strings.updateApp)
                        }
                        .padding(.top)
                    }
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
