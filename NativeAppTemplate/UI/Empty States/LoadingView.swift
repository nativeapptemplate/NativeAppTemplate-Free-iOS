//
//  LoadingView.swift
//  NativeAppTemplate
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView().scaleEffect(1.0, anchor: .center)
                .padding([.bottom], NativeAppTemplateConstants.Spacing.xs)
            Text(String.loading)
                .font(.uiHeadline)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView().inAllColorSchemes
    }
}
