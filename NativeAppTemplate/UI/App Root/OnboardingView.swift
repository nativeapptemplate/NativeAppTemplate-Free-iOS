//
//  OnboardingView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import SwiftUI

struct OnboardingView: View {
  let isAppStorePromotion = false
  @State private var viewModel: OnboardingViewModel

  init(onboardingRepository: OnboardingRepositoryProtocol) {
    self._viewModel = State(initialValue: OnboardingViewModel(onboardingRepository: onboardingRepository))
  }

  var body: some View {
    NavigationStack {
      contentView
        .task {
          viewModel.reload()
        }
    }
  }
}

// MARK: - private
private extension OnboardingView {
  var contentView: some View {
    @ViewBuilder var contentView: some View {
      VStack {
        SwiftUI.TabView {
          ForEach(viewModel.onboardings) { onboarding in
            let id = onboarding.id
            page(
              image: "onboarding\(id)",
              text: viewModel.onboardingDescription(index: id),
              isPortraitImage: onboarding.isPortraitImage
            )
          }
        }
        .tabViewStyle(.page(indexDisplayMode: (isAppStorePromotion ? .never : .always)))
        .toolbar {
          if !isAppStorePromotion {
            ToolbarItem(placement: .navigationBarLeading) {
              Link(String.howToUse, destination: URL(string: String.howToUseUrl)!)
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
    }

    return contentView
  }

  private var logo: some View {
    Image("logo")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 256, height: 24)
  }

  private func page(image: String, text: String, isPortraitImage: Bool) -> some View {
    ZStack(alignment: .bottom) {
      Image(image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.top, 24)
        .padding(.bottom, (isPortraitImage ? 0 : 192))

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
