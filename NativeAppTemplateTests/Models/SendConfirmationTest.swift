//
//  SendConfirmationTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct SendConfirmationTest {
    @Test
    func toJsonIncludesEmailAndRedirectUrl() {
        let send = SendConfirmation(email: "alice@example.com")

        let json = send.toJson()

        #expect(json["email"] as? String == "alice@example.com")
        #expect(json["redirect_url"] as? String == send.redirectUrl)
        #expect(json.keys.sorted() == ["email", "redirect_url"])
    }

    @Test
    func defaultRedirectUrlPointsToConfirmationResult() {
        let send = SendConfirmation(email: "x")
        #expect(send.redirectUrl.hasSuffix("/shopkeeper_auth/confirmation_result"))
    }

    @Test
    func redirectUrlCanBeOverridden() {
        let send = SendConfirmation(email: "x", redirectUrl: "https://custom.example/cb")
        #expect(send.toJson()["redirect_url"] as? String == "https://custom.example/cb")
    }
}
