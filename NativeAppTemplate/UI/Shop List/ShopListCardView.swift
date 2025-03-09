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
      
      let statImageSize = 12.0
      
      Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 12, verticalSpacing: 4) {
        GridRow {
          Image(systemName: "person.2")
            .frame(width: statImageSize, height: statImageSize)
            .foregroundStyle(.secondaryText)
          Text(String(shop.scannedItemTagsCount))
            .font(.uiLabelBold)
            .gridColumnAlignment(.trailing)
          Text(verbatim: "tags scanned by customers")
            .font(.uiFootnote)
            .foregroundStyle(.contentText)
        }
        
        GridRow {
          Image(systemName: "flag.checkered")
            .frame(width: statImageSize, height: statImageSize)
            .foregroundStyle(.secondaryText)
          Text(String(shop.completedItemTagsCount))
            .font(.uiLabelBold)
          Text(verbatim: "completed tags")
            .font(.uiFootnote)
            .foregroundStyle(.contentText)
        }
        
        GridRow {
          Image(systemName: "rectangle.stack")
            .frame(width: statImageSize, height: statImageSize)
            .foregroundStyle(.secondaryText)
          Text(String(shop.itemTagsCount))
            .font(.uiLabelBold)
          Text(verbatim: "all tags")
            .font(.uiFootnote)
            .foregroundStyle(.contentText)
        }
      }
      .padding(.top)
      
      Text(shop.description)
        .font(.uiCaption)
        .foregroundStyle(.contentText)
        .padding(.top)
    }
    .padding()
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
  }
}
