//
//  SignUpTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct SignUpTest {
    @Test
    func toJsonForCreateIncludesPasswordAndDefaultsPlatformToIos() {
        let signUp = SignUp(
            name: "Alice",
            email: "alice@example.com",
            timeZone: "Asia/Tokyo",
            password: "secret123"
        )

        let json = signUp.toJsonForCreate()

        #expect(json["name"] as? String == "Alice")
        #expect(json["email"] as? String == "alice@example.com")
        #expect(json["time_zone"] as? String == "Asia/Tokyo")
        #expect(json["current_platform"] as? String == "ios")
        #expect(json["password"] as? String == "secret123")
    }

    @Test
    func toJsonForUpdateExcludesPasswordAndPlatform() {
        let signUp = SignUp(
            name: "Alice",
            email: "alice@example.com",
            timeZone: "Asia/Tokyo",
            password: "secret123"
        )

        let json = signUp.toJsonForUpdate()

        #expect(json["name"] as? String == "Alice")
        #expect(json["email"] as? String == "alice@example.com")
        #expect(json["time_zone"] as? String == "Asia/Tokyo")
        #expect(json["password"] == nil)
        #expect(json["current_platform"] == nil)
        #expect(json.keys.sorted() == ["email", "name", "time_zone"])
    }

    @Test
    func currentPlatformDefaultsToIos() {
        let signUp = SignUp(name: "n", email: "e", timeZone: "tz")
        #expect(signUp.currentPlatform == "ios")
    }
}
