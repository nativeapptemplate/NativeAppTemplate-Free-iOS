//
//  ShopkeeperTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/01/31.
//

import Testing
import SwiftyJSON
@testable import NativeAppTemplate

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

  func shopkeeperDictionaryHasRequiredFields() {
    var invalidDictionary = shopkeeperDictionary
    invalidDictionary.removeValue(forKey: "id")
    let shopkeeper = Shopkeeper(dictionary: invalidDictionary)

    #expect(shopkeeper == nil)
  }

  func additionalEntriesInTheDictionaryAreIgnored() {
    var overSpecifiedDictionary = shopkeeperDictionary
    overSpecifiedDictionary["extra_field"] = "some-guff"
    let shopkeeper = Shopkeeper(dictionary: overSpecifiedDictionary)

    #expect(shopkeeper != nil)
  }
}
