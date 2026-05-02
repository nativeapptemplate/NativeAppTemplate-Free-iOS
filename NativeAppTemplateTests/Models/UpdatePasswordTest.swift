//
//  UpdatePasswordTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct UpdatePasswordTest {
    @Test
    func toJsonWrapsFieldsUnderShopkeeperKey() throws {
        let update = UpdatePassword(
            currentPassword: "old-pw",
            password: "new-pw",
            passwordConfirmation: "new-pw"
        )

        let json = update.toJson()
        let inner = try #require(json["shopkeeper"] as? [String: Any])

        #expect(inner["current_password"] as? String == "old-pw")
        #expect(inner["password"] as? String == "new-pw")
        #expect(inner["password_confirmation"] as? String == "new-pw")
    }

    @Test
    func toJsonOnlyIncludesPasswordFields() throws {
        let update = UpdatePassword(
            currentPassword: "a",
            password: "b",
            passwordConfirmation: "c"
        )
        let inner = try #require(update.toJson()["shopkeeper"] as? [String: Any])

        #expect(inner.keys.sorted() == ["current_password", "password", "password_confirmation"])
    }
}
