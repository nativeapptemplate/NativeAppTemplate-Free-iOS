//
//  OnboardingView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import SwiftUI

struct OnboardingView: View {
  let isAppStorePromotion = false
  @State private var onboardingRepository: OnboardingRepositoryProtocol = OnboardingRepository()
  
  var body: some View {
    NavigationStack {
      contentView
        .task {
          reload()
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
          ForEach(onboardingRepository.onboardings) { onboarding in
            let id = onboarding.id
            page(
              image: "onboarding\(id)",
              text: onboardingDescription(index: id),
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
  
  func reload() {
    onboardingRepository.reload()
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
        }
        .background(Color.backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: 192, alignment: .top)
      }
      .background(Color.backgroundColor)
    }
  }
  
  private func onboardingDescription(index: Int) -> String {
    switch index {
    case 1:
      String.onboardingDescription1
    case 2:
      String.onboardingDescription2
    case 3:
      String.onboardingDescription3
    case 4:
      String.onboardingDescription4
    case 5:
      String.onboardingDescription5
    case 6:
      String.onboardingDescription6
    case 7:
      String.onboardingDescription7
    case 8:
      String.onboardingDescription8
    case 9:
      String.onboardingDescription9
    case 10:
      String.onboardingDescription10
    case 11:
      String.onboardingDescription11
    case 12:
      String.onboardingDescription12
    case 13:
      String.onboardingDescription13
    default:
      String.onboardingDescription1
    }
  }
  
  struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
      OnboardingView()
    }
  }
}
