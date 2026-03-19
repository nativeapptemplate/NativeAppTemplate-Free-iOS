//
//  View+Extensions.swift
//  NativeAppTemplate
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
