//
//  ItemTagData.swift
//  NativeAppTemplate
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

extension ItemTagData: Equatable {}
