//
//  ShopDetailCardView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI

struct ShopDetailCardView: View {
  let itemTag: ItemTag
  
  init(
    itemTag: ItemTag
  ) {
    self.itemTag = itemTag
  }
  
  var body: some View {
    content
  }
  
  var content: some View {
    HStack {
      Text(String(itemTag.queueNumber))
        .font(.uiTitle4)
      
      Spacer()
      
      VStack(alignment: .trailing) {
        if itemTag.scanState == ScanState.scanned {
          CustomerScannedTag()
          
          if let customerReadAt = itemTag.customerReadAt {
            Text(customerReadAt.cardTimeString)
              .font(.uiFootnote)
              .foregroundStyle(.contentText)
          }
        }
      }
      
      Spacer()
      
      VStack(alignment: .trailing) {
        if itemTag.state == .completed {
          CompletedTag()
          
          if let completedAt = itemTag.completedAt {
            Text(completedAt.cardTimeString)
              .font(.uiFootnote)
              .foregroundStyle(.contentText)
          }
        } else {
          IdlingTag()
        }
      }
      .frame(minWidth: 82, alignment: .trailing)
    }
    .frame(minHeight: 48)
  }
}
