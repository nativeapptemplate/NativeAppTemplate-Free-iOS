//
//  PaginationMetaTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

@Suite
struct PaginationMetaTest {
    @Test
    func initWithValues() {
        let meta = PaginationMeta(currentPage: 2, totalPages: 5, totalCount: 100, limit: 20)
        #expect(meta.currentPage == 2)
        #expect(meta.totalPages == 5)
        #expect(meta.totalCount == 100)
        #expect(meta.limit == 20)
    }

    @Test
    func hasMorePagesWhenNotOnLastPage() {
        let meta = PaginationMeta(currentPage: 1, totalPages: 3, totalCount: 55, limit: 20)
        #expect(meta.hasMorePages == true)
    }

    @Test
    func hasMorePagesIsFalseOnLastPage() {
        let meta = PaginationMeta(currentPage: 3, totalPages: 3, totalCount: 55, limit: 20)
        #expect(meta.hasMorePages == false)
    }

    @Test
    func hasMorePagesIsFalseWhenSinglePage() {
        let meta = PaginationMeta(currentPage: 1, totalPages: 1, totalCount: 5, limit: 20)
        #expect(meta.hasMorePages == false)
    }

    @Test
    func initFromValidDictionary() {
        let dictionary: [String: Any] = [
            "current_page": 2, "total_pages": 5, "total_count": 100, "limit": 20
        ]
        let meta = PaginationMeta(dictionary: dictionary)
        #expect(meta != nil)
        #expect(meta?.currentPage == 2)
        #expect(meta?.totalPages == 5)
        #expect(meta?.totalCount == 100)
        #expect(meta?.limit == 20)
    }

    @Test
    func initFromDictionaryMissingKeysReturnsNil() {
        let dictionary: [String: Any] = ["current_page": 1, "total_pages": 3]
        #expect(PaginationMeta(dictionary: dictionary) == nil)
    }

    @Test
    func initFromEmptyDictionaryReturnsNil() {
        #expect(PaginationMeta(dictionary: [:]) == nil)
    }

    @Test
    func initFromDictionaryWithWrongTypesReturnsNil() {
        let dictionary: [String: Any] = [
            "current_page": "1", "total_pages": "3", "total_count": "55", "limit": "20"
        ]
        #expect(PaginationMeta(dictionary: dictionary) == nil)
    }
}
