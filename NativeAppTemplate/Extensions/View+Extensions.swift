//
//  View+Extensions.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2024/01/04.
//

import SwiftUI

extension View {
  var inAllColorSchemes: some View {
    ForEach(
      ColorScheme.allCases,
      id: \.self,
      content: preferredColorScheme
    )
  }
}
