//
//  NumberTagsWebpageListViewModel.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import SwiftUI
import UniformTypeIdentifiers
import Observation

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
