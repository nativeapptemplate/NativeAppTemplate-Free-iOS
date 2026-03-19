//
//  ItemTagStateTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct ItemTagStateTest {
    @Test
    func initFromValidStrings() {
        #expect(ItemTagState(string: "idled") == .idled)
        #expect(ItemTagState(string: "completed") == .completed)
    }

    @Test
    func initFromUnknownStringDefaultsToIdled() {
        #expect(ItemTagState(string: "unknown") == .idled)
        #expect(ItemTagState(string: "") == .idled)
    }
}
