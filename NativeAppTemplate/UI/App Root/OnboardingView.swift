//
//  OnboardingView.swift
//  NativeAppTemplate
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        NavigationStack {
            contentView
        }
    }
}

// MARK: - private

private extension OnboardingView {
    var contentView: some View {
        ZStack(alignment: .bottom) {
            Image(systemName: "sparkles")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, NativeAppTemplateConstants.Spacing.md)
                .padding(.bottom, 192)

            VStack {
                Text(Strings.welcomeToApp)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .dynamicTypeSize(DynamicTypeSize.accessibility1)
                    .padding([.top, .horizontal])
                    .accessibilityIdentifier("OnboardingView_welcome_staticText")
            }
            .background(Color.backgroundColor)
            .frame(maxWidth: .infinity, maxHeight: 192, alignment: .top)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Link(Strings.supportWebsite, destination: URL(string: Strings.supportWebsiteUrl)!)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SignUpOrSignInView()) {
                    Text(verbatim: "Start")
                        .font(.title)
                }
            }
        }
    }

    struct OnboardingView_Previews: PreviewProvider {
        static var previews: some View {
            OnboardingView()
        }
    }
}
