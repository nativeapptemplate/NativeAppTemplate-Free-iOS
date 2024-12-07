//
//  OnboardingView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import SwiftUI

struct OnboardingView: View {
 let isAppStorePromotion = false

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
        TabView {
          ForEach(1..<4) {
            page(image: "onboarding\($0)", text: onboardingDescription(index: $0))
          }
        }
        .tabViewStyle(.page(indexDisplayMode: (isAppStorePromotion ? .never : .always)))
        .toolbar {
          if !isAppStorePromotion {
            ToolbarItem(placement: .navigationBarLeading) {
              Link(String.supportWebsite, destination: URL(string: String.supportWebsiteUrl)!)
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
  
  private func page(image: String, text: String) -> some View {
    ZStack(alignment: .bottom) {
      Image(image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxHeight: 640, alignment: .top)
        .padding(.top, 24)

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
    default:
      String.onboardingDescription1
    }
  }
}

struct OnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    OnboardingView()
  }
}
