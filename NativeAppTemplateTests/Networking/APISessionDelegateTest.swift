//
//  APISessionDelegateTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// The app does not pin certificates: the API session leaves server trust to the
/// system's default evaluation. URLSession uses that default only when the delegate
/// does not implement an authentication challenge method.
struct APISessionDelegateTest {
    @Test
    func leavesSessionChallengesToTheSystem() {
        let selector = #selector(URLSessionDelegate.urlSession(_:didReceive:completionHandler:))

        #expect(!APISessionDelegate().responds(to: selector))
    }

    @Test
    func leavesTaskChallengesToTheSystem() {
        let selector = #selector(URLSessionTaskDelegate.urlSession(_:task:didReceive:completionHandler:))

        #expect(!APISessionDelegate().responds(to: selector))
    }

    @Test
    func apiSessionUsesTheDelegate() {
        #expect(URLSession.api.delegate is APISessionDelegate)
    }
}
