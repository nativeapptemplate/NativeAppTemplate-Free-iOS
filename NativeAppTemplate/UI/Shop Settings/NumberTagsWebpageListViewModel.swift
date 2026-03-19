//
//  NumberTagsWebpageListViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI
import UniformTypeIdentifiers

@Observable
@MainActor
final class NumberTagsWebpageListViewModel {
    let shop: Shop

    private let messageBus: MessageBus

    init(
        shop: Shop,
        messageBus: MessageBus
    ) {
        self.shop = shop
        self.messageBus = messageBus
    }

    func copyWebpageUrl(_ url: String) {
        UIPasteboard.general.setValue(url, forPasteboardType: UTType.plainText.identifier)
        messageBus.post(message: Message(level: .success, message: .webpageUrlCopied))
    }
}
