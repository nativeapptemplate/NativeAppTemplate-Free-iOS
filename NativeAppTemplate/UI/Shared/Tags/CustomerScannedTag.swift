//
//  CustomerScannedTag.swift
//  NativeAppTemplate
//

import SwiftUI

struct CustomerScannedTag: View {
    var body: some View {
        TagView(
            text: "customer scanned",
            textColor: .customerScannedTagForeground,
            backgroundColor: .customerScannedTagBackground,
            borderColor: .customerScannedTagBorder
        )
    }
}

struct CustomerScannedTag_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            customerScannedTag.colorScheme(.light)
            customerScannedTag.colorScheme(.dark)
        }
    }

    static var customerScannedTag: some View {
        CustomerScannedTag()
            .padding()
            .background(Color.backgroundColor)
    }
}
