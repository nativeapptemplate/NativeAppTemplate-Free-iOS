//
//  PaginationMeta.swift
//  NativeAppTemplate
//

import Foundation

struct PaginationMeta: Sendable {
    let currentPage: Int
    let totalPages: Int
    let totalCount: Int
    let limit: Int

    var hasMorePages: Bool {
        currentPage < totalPages
    }

    init(currentPage: Int, totalPages: Int, totalCount: Int, limit: Int) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalCount = totalCount
        self.limit = limit
    }

    init?(dictionary: [String: Any]) {
        guard let currentPage = dictionary["current_page"] as? Int,
              let totalPages = dictionary["total_pages"] as? Int,
              let totalCount = dictionary["total_count"] as? Int,
              let limit = dictionary["limit"] as? Int else {
            return nil
        }

        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalCount = totalCount
        self.limit = limit
    }
}
