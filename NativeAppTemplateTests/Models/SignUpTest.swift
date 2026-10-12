//
//  SignUpTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

struct SignUpTest {
    @Test
    func toJsonForCreateIncludesPasswordAndDefaultsPlatformToIos() {
        let signUp = SignUp(
            name: "Alice",
            email: "alice@example.com",
            timeZone: "Asia/Tokyo",
            locale: "ja-JP",
            password: "secret123"
        )

        let json = signUp.toJsonForCreate()

        #expect(json["name"] as? String == "Alice")
        #expect(json["email"] as? String == "alice@example.com")
        #expect(json["time_zone"] as? String == "Asia/Tokyo")
        #expect(json["current_platform"] as? String == "ios")
        #expect(json["password"] as? String == "secret123")
        #expect(json["locale"] as? String == "ja-JP")
    }

    @Test
    func toJsonForUpdateExcludesPasswordAndPlatform() {
        let signUp = SignUp(
            name: "Alice",
            email: "alice@example.com",
            timeZone: "Asia/Tokyo",
            locale: "ja",
            password: "secret123"
        )

        let json = signUp.toJsonForUpdate()

        #expect(json["name"] as? String == "Alice")
        #expect(json["email"] as? String == "alice@example.com")
        #expect(json["time_zone"] as? String == "Asia/Tokyo")
        #expect(json["password"] == nil)
        #expect(json["current_platform"] == nil)
        #expect(json["locale"] as? String == "ja")
        #expect(json.keys.sorted() == ["email", "locale", "name", "time_zone"])
    }

    @Test
    func currentPlatformDefaultsToIos() {
        let signUp = SignUp(name: "n", email: "e", timeZone: "tz")
        #expect(signUp.currentPlatform == "ios")
    }

    /// shopkeepers.locale follows the language the app is shown in, so emails
    /// match the app even when the device prefers a language the app lacks
    @Test
    func localeDefaultsToTheAppsLanguage() {
        let signUp = SignUp(name: "n", email: "e", timeZone: "tz")
        #expect(signUp.locale == Shopkeeper.appLocale())
    }
}
