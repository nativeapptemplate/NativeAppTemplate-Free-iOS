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
        VStack {
            Image(systemName: "sparkles")
                .resizable()
                .scaledToFit()
                .padding(.top, NativeAppTemplateConstants.Spacing.md)
                .accessibilityHidden(true)

            // The title takes the room it needs at any text size and the art shrinks; at
            // the accessibility sizes a fixed-height title was cut off
            Text(Strings.welcomeToApp)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.top, .horizontal])
                .frame(maxWidth: .infinity, minHeight: 192, alignment: .top)
                .accessibilityIdentifier("OnboardingView_welcome_staticText")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // The whole screen, as SignUpOrSignInView: only behind the title, it was a
        // block of backgroundColor on the system background
        .background(Color.backgroundColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Link(Strings.supportWebsite, destination: URL(string: Strings.supportWebsiteUrl)!)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SignUpOrSignInView()) {
                    Text("Start")
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
