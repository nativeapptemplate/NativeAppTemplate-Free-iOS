//
//  NumberTagsWebpageListViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct NumberTagsWebpageListViewModelTest {
  let messageBus = MessageBus()

  var shop: Shop { mockShop(id: "test-shop-id", name: "Shop 1") }

  @Test
  func initializesCorrectly() {
    let viewModel = NumberTagsWebpageListViewModel(
      shop: shop,
      messageBus: messageBus
    )

    #expect(viewModel.shop.id == shop.id)
    #expect(viewModel.shop.name == shop.name)
    #expect(viewModel.shop.displayShopServerPath == shop.displayShopServerPath)
  }

  @Test
  func shopPropertyIsAccessible() {
    let viewModel = NumberTagsWebpageListViewModel(
      shop: shop,
      messageBus: messageBus
    )

    #expect(viewModel.shop == shop)
    #expect(viewModel.shop.displayShopServerUrl.absoluteString.contains("test-shop-id"))
  }

  @Test
  func copyWebpageUrlPostsSuccessMessage() {
    let viewModel = NumberTagsWebpageListViewModel(
      shop: shop,
      messageBus: messageBus
    )

    let testUrl = "https://example.com/test-url"

    viewModel.copyWebpageUrl(testUrl)

    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .success)
    #expect(messageBus.currentMessage!.message == .webpageUrlCopied)
  }

  @Test("Copy webpage URL with different URLs", arguments: [
    "https://api.nativeapptemplate.com/display/shops/123?type=server",
    "https://example.com/test",
    "http://localhost:3000/path",
    "https://shop.example.com/page?param=value"
  ])
  func copyWebpageUrlWithDifferentUrls(url: String) {
    let localMessageBus = MessageBus()
    let viewModel = NumberTagsWebpageListViewModel(
      shop: shop,
      messageBus: localMessageBus
    )

    viewModel.copyWebpageUrl(url)

    #expect(localMessageBus.currentMessage != nil)
    #expect(localMessageBus.currentMessage!.level == .success)
    #expect(localMessageBus.currentMessage!.message == .webpageUrlCopied)
  }

  @Test
  func copyWebpageUrlWithEmptyString() {
    let viewModel = NumberTagsWebpageListViewModel(
      shop: shop,
      messageBus: messageBus
    )

    viewModel.copyWebpageUrl("")

    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .success)
    #expect(messageBus.currentMessage!.message == .webpageUrlCopied)
  }

  @Test
  func multipleMessagesClearPrevious() {
    let viewModel = NumberTagsWebpageListViewModel(
      shop: shop,
      messageBus: messageBus
    )

    // First copy
    viewModel.copyWebpageUrl("https://first.com")
    let firstMessage = messageBus.currentMessage

    // Second copy
    viewModel.copyWebpageUrl("https://second.com")
    let secondMessage = messageBus.currentMessage

    #expect(firstMessage != nil)
    #expect(secondMessage != nil)
    #expect(firstMessage!.message == .webpageUrlCopied)
    #expect(secondMessage!.message == .webpageUrlCopied)
    #expect(firstMessage!.level == .success)
    #expect(secondMessage!.level == .success)
  }

  private func mockShop(id: String = UUID().uuidString, name: String = "Mock Shop") -> Shop {
    Shop(
      id: id,
      name: name,
      description: "This is a mock shop for testing",
      timeZone: "Tokyo",
      itemTagsCount: 10,
      scannedItemTagsCount: 5,
      completedItemTagsCount: 3,
      displayShopServerPath: "https://api.nativeapptemplate.com/display/shops/\(id)?type=server"
    )
  }
}
