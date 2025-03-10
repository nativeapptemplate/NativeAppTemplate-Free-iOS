//
//  ItemTagListCardView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI

struct ItemTagListCardView: View {
  let itemTag: ItemTag

  var body: some View {
    Text(String(itemTag.queueNumber))
      .font(.uiTitle4)
  }
}
