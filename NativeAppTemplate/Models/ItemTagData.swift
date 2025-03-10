//
//  ItemTagData.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import Foundation

struct ItemTagData: Identifiable {
  var id: String {
    itemTagId
  }
  var itemTagId: String
  var itemTagType: ItemTagType
  var isReadOnly: Bool
  var scannedAt: Date
}

// MARK: - Equatable
extension ItemTagData: Equatable {
  static func == (lhs: ItemTagData, rhs: ItemTagData) -> Bool {
    lhs.itemTagId == rhs.itemTagId &&
    lhs.itemTagType == rhs.itemTagType &&
    lhs.isReadOnly == rhs.isReadOnly &&
    lhs.scannedAt == rhs.scannedAt
  }
}
