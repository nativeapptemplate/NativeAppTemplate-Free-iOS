//
//  CompletedTag.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI

struct CompletedTag: View {
  var body: some View {
    TagView(
      text: "completed",
      textColor: .completedTagForeground,
      backgroundColor: .completedTagBackground,
      borderColor: .completedTagBorder
    )
  }
}

struct CompletedTag_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 12) {
      completedTag.colorScheme(.light)
      completedTag.colorScheme(.dark)
    }
  }
  
  static var completedTag: some View {
    CompletedTag()
      .padding()
      .background(Color.backgroundColor)
  }
}
