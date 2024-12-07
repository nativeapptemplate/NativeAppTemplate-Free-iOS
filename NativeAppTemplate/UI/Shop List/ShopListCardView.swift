//
//  ShopListCardView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/05.
//

import SwiftUI
struct ShopListCardView: View {
  let shop: Shop
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(shop.name)
        .font(.uiTitle4)
        .foregroundStyle(.accent)
      
      Text(shop.description)
        .font(.uiCaption)
        .foregroundStyle(.contentText)
        .padding(.top)
    }
    .padding()
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
  }
}
