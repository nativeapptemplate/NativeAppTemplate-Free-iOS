//
//  ItemTagListCardView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ItemTagListCardView: View {
    let itemTag: ItemTag

    var body: some View {
        Text(String(itemTag.name))
            .font(.uiTitle4)
    }
}
