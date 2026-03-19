//
//  ScanStateTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct ScanStateTest {
    @Test
    func initFromValidStrings() {
        #expect(ScanState(string: "unscanned") == .unscanned)
        #expect(ScanState(string: "scanned") == .scanned)
    }

    @Test
    func initFromUnknownStringDefaultsToUnscanned() {
        #expect(ScanState(string: "unknown") == .unscanned)
        #expect(ScanState(string: "") == .unscanned)
    }

    @Test
    func toJsonRoundtrip() {
        #expect(ScanState(string: ScanState.unscanned.toJson()) == .unscanned)
        #expect(ScanState(string: ScanState.scanned.toJson()) == .scanned)
    }
}
