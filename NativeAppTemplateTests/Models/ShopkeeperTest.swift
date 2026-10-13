//
//  ShopkeeperTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct ShopkeeperTest {
    let shopkeeperDictionary = [
        "id": "5712F2DF-DFC7-A3AA-66BC-191203654A1A",
        "account_id": "5712F2DF-DFC7-A3AA-66BC-191203654A1Z",
        "personal_account_id": "5712F2DF-DFC7-A3AA-66BC-191203654A1Z",
        "account_owner_id": "5712F2DF-DFC7-A3AA-66BC-191203654A1C",
        "account_name": "Account1",
        "email": "email@example.com",
        "name": "Jhon Smith",
        "time_zone": "Tokyo",
        "uid": "email@example.com",
        "token": "Sample.Token",
        "client": "Sample.Client",
        "expiry": "123456789"
    ]

    @Test func shopkeeperCorrectlyPopulatesWithDictionary() {
        guard let shopkeeper = Shopkeeper(dictionary: shopkeeperDictionary) else {
            Issue.record("Shopkeeper should be correctly populated")
            return
        }

        #expect(shopkeeperDictionary["id"] == shopkeeper.id)
        #expect(shopkeeperDictionary["account_id"] == shopkeeper.accountId)
        #expect(shopkeeperDictionary["personal_account_id"] == shopkeeper.personalAccountId)
        #expect(shopkeeperDictionary["account_owner_id"] == shopkeeper.accountOwnerId)
        #expect(shopkeeperDictionary["account_name"] == shopkeeper.accountName)
        #expect(shopkeeperDictionary["email"] == shopkeeper.email)
        #expect(shopkeeperDictionary["name"] == shopkeeper.name)
        #expect(shopkeeperDictionary["time_zone"] == shopkeeper.timeZone)
        #expect(shopkeeperDictionary["uid"] == shopkeeper.uid)
        #expect(shopkeeperDictionary["token"] == shopkeeper.token)
        #expect(shopkeeperDictionary["client"] == shopkeeper.client)
        #expect(shopkeeperDictionary["expiry"] == shopkeeper.expiry)
    }

    @Test func shopkeeperDictionaryHasRequiredFields() {
        var invalidDictionary = shopkeeperDictionary
        invalidDictionary.removeValue(forKey: "id")
        let shopkeeper = Shopkeeper(dictionary: invalidDictionary)

        #expect(shopkeeper == nil)
    }

    @Test func additionalEntriesInTheDictionaryAreIgnored() {
        var overSpecifiedDictionary = shopkeeperDictionary
        overSpecifiedDictionary["extra_field"] = "some-guff"
        let shopkeeper = Shopkeeper(dictionary: overSpecifiedDictionary)

        #expect(shopkeeper != nil)
    }

    @Test func localeIsReadFromTheDictionary() {
        var dictionary = shopkeeperDictionary
        dictionary["locale"] = "ja"

        #expect(Shopkeeper(dictionary: dictionary)?.locale == "ja")
    }

    /// The API's column default for shopkeepers.locale
    @Test func missingLocaleDefaultsToEnglish() {
        #expect(Shopkeeper(dictionary: shopkeeperDictionary)?.locale == "en")
    }

    /// The app's language is the localization iOS picked for the UI; the API
    /// offers only en and ja, and the app shows English for anything else
    @Test(arguments: [
        (["ja"], "ja"),
        (["ja-JP"], "ja"),
        (["en"], "en"),
        (["en-GB"], "en"),
        (["fr"], "en"),
        ([], "en"),
    ])
    func appLocaleIsTheUILanguageTheAPIOffers(preferredLocalizations: [String], expected: String) {
        #expect(Shopkeeper.appLocale(preferredLocalizations: preferredLocalizations) == expected)
    }

    /// Tests run in English (see LocalizationTest.testsRunInEnglish)
    @Test func appLocaleDefaultsToTheBundlesLanguage() {
        #expect(Shopkeeper.appLocale() == "en")
        #expect(Shopkeeper.appLocaleName() == "English")
    }

    @Test func appLocaleNameNamesTheLanguageInItself() {
        #expect(Shopkeeper.appLocaleName(preferredLocalizations: ["ja"]) == "日本語")
        #expect(Shopkeeper.appLocaleName(preferredLocalizations: ["fr"]) == "English")
    }

    /// shopkeepers.locale follows the app's language, so only a mismatch is sent
    @Test func localeToSyncIsTheAppLocaleOnlyWhenTheyDiffer() throws {
        var dictionary = shopkeeperDictionary
        dictionary["locale"] = "en"
        let shopkeeper = try #require(Shopkeeper(dictionary: dictionary))

        #expect(shopkeeper.localeToSync(appLocale: "ja") == "ja")
        #expect(shopkeeper.localeToSync(appLocale: "en") == nil)
    }
}
