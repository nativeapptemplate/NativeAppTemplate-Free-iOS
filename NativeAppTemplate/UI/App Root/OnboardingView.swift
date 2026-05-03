//
//  OnboardingView.swift
//  NativeAppTemplate
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    init(onboardingRepository: OnboardingRepositoryProtocol) {
        _viewModel = State(initialValue: OnboardingViewModel(onboardingRepository: onboardingRepository))
    }

    var body: some View {
        NavigationStack {
            contentView
        }
    }
}

// MARK: - private

private extension OnboardingView {
    var contentView: some View {
        @ViewBuilder var contentView: some View {
            VStack {
                SwiftUI.TabView {
                    welcomePage
                    ForEach(viewModel.onboardings) { onboarding in
                        let id = onboarding.id
                        page(
                            image: "onboarding\(id)",
                            text: viewModel.onboardingDescription(index: id),
                            imageOrientation: onboarding.imageOrientation
                        )
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
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
        }

        return contentView
    }

    private var logo: some View {
        Image("logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 256, height: 24)
    }

    private var welcomePage: some View {
        ZStack(alignment: .bottom) {
            Image("hero")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, NativeAppTemplateConstants.Spacing.md)
                .padding(.bottom, 192)

            ZStack(alignment: .top) {
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
            .background(Color.backgroundColor)
        }
    }

    private func page(image: String, text: String, imageOrientation: ImageOrientation) -> some View {
        ZStack(alignment: .bottom) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, NativeAppTemplateConstants.Spacing.md)
                .padding(.bottom, imageOrientation == .portrait ? 0 : 192)

            ZStack(alignment: .top) {
                VStack {
                    Text(.init(text))
                        .dynamicTypeSize(DynamicTypeSize.accessibility1)
                        .padding([.top, .horizontal])
                        .accessibilityIdentifier("OnboardingView_descriptoion_staticText")
                }
                .background(Color.backgroundColor)
                .frame(maxWidth: .infinity, maxHeight: 192, alignment: .top)
            }
            .background(Color.backgroundColor)
        }
    }

    struct OnboardingView_Previews: PreviewProvider {
        static var previews: some View {
            OnboardingView(onboardingRepository: OnboardingRepository())
        }
    }
}
