//
//  ItemTag.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/01.
//

import Foundation

struct ItemTag: Codable, Hashable, Identifiable, Sendable {
  var id: String = ""
  var shopId: String = ""
  var queueNumber: String = ""
  var state = ItemTagState.idled
  var scanState = ScanState.unscanned
  var createdAt = Date.now
  var customerReadAt: Date?
  var completedAt: Date?
  var shopName: String = ""
  var alreadyCompleted: Bool?
}

extension ItemTag {
  func scanUrl(itemTagType: ItemTagType) -> URL {
    Utility.scanUrl(itemTagId: id, itemTagType: itemTagType.toJson())
  }

  func toJson() -> [String: Any] {
    ["item_tag":
      [
        "queue_number": queueNumber
      ]
    ]
  }
}
