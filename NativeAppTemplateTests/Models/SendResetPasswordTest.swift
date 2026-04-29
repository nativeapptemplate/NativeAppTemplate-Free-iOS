//
//  SendResetPasswordTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct SendResetPasswordTest {
    @Test
    func toJsonIncludesEmailAndRedirectUrl() {
        let send = SendResetPassword(email: "alice@example.com")

        let json = send.toJson()

        #expect(json["email"] as? String == "alice@example.com")
        #expect(json["redirect_url"] as? String == send.redirectUrl)
        #expect(json.keys.sorted() == ["email", "redirect_url"])
    }

    @Test
    func defaultRedirectUrlPointsToResetPasswordEdit() {
        let send = SendResetPassword(email: "x")
        #expect(send.redirectUrl.hasSuffix("/shopkeeper_auth/reset_password/edit"))
    }

    @Test
    func redirectUrlCanBeOverridden() {
        let send = SendResetPassword(email: "x", redirectUrl: "https://custom.example/cb")
        #expect(send.toJson()["redirect_url"] as? String == "https://custom.example/cb")
    }
}
