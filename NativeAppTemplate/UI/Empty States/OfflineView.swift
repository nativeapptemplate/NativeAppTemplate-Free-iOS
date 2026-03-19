//
//  OfflineView.swift
//  NativeAppTemplate
//

import SwiftUI

struct OfflineView: View {
    var body: some View {
        VStack {
            Image(systemName: "wifi.slash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 96)
                .padding()
                .foregroundStyle(.titleText)

            Text(String.noConnection)
                .font(.uiTitle1)
                .foregroundStyle(.titleText)
                .multilineTextAlignment(.center)
                .padding(.top)

            Text(String.checkInternetConnection)
                .font(.uiLabel)
                .lineSpacing(8)
                .foregroundStyle(.contentText)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
}

struct OfflineView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineView()
    }
}
