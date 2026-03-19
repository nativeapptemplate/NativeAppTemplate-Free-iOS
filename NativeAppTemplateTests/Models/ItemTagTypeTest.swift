//
//  ItemTagTypeTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct ItemTagTypeTest {
    @Test
    func initFromValidStrings() {
        #expect(ItemTagType(string: "server") == .server)
        #expect(ItemTagType(string: "customer") == .customer)
    }

    @Test
    func initFromUnknownStringDefaultsToServer() {
        #expect(ItemTagType(string: "unknown") == .server)
        #expect(ItemTagType(string: "") == .server)
    }

    @Test
    func toJsonRoundtrip() {
        #expect(ItemTagType(string: ItemTagType.server.toJson()) == .server)
        #expect(ItemTagType(string: ItemTagType.customer.toJson()) == .customer)
    }
}
