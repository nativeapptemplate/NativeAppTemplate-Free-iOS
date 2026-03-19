//
//  Shopkeeper+Backdoor.swift
//  NativeAppTemplate
//

import class Foundation.UserDefaults

extension Shopkeeper {
    static var backdoor: Shopkeeper? {
        guard let backdoorToken = UserDefaults.standard.string(forKey: "shopkeeperBackdoorToken") else { return nil }

        let shopkeeperDict = [
            "id": "BACKDOOR_SHOPKEEPER",
            "email": "shopkeeper@nativeapptemplate.com",
            "name": "BACKDOORSHOPKEEPER",
            "uid": "uid",
            "token": backdoorToken,
            "client": "client",
            "expiry": "123456789"
        ]

        return Shopkeeper(dictionary: shopkeeperDict)
    }
}
