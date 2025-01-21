import Foundation

public class LoggedInShopkeeper: NSObject, NSCoding, NSSecureCoding {
  enum CodingKeys: String, CodingKey {
    case id,
         accountId,
         personalAccountId,
         accountOwnerId,
         accountName,
         email,
         name,
         timeZone,
         token,
         client,
         uid,
         expiry
  }

  let id: String
  let accountId: String
  let personalAccountId: String
  let accountOwnerId: String
  let accountName: String
  let email: String
  let name: String
  let timeZone: String
  let token: String
  let client: String
  let uid: String
  let expiry: String

  init(
    id: String,
    accountId: String,
    personalAccountId: String,
    accountOwnerId: String,
    accountName: String,
    email: String,
    name: String,
    timeZone: String,
    token: String,
    client: String,
    uid: String,
    expiry: String
  ) {
    self.id = id
    self.accountId = accountId
    self.personalAccountId = personalAccountId
    self.accountOwnerId = accountOwnerId
    self.accountName = accountName
    self.email = email
    self.name = name
    self.timeZone = timeZone
    self.token = token
    self.client = client
    self.uid = uid
    self.expiry = expiry
  }

  public init(from shopkeeper: Shopkeeper) {
    id = shopkeeper.id
    accountId = shopkeeper.accountId
    personalAccountId = shopkeeper.personalAccountId
    accountOwnerId = shopkeeper.accountOwnerId
    accountName = shopkeeper.accountName
    email = shopkeeper.email
    name = shopkeeper.name
    timeZone = shopkeeper.timeZone

    token = shopkeeper.token!
    client = shopkeeper.client!
    uid = shopkeeper.uid
    expiry = shopkeeper.expiry!
  }

  public func encode(with coder: NSCoder) {
//    For NSCoding
    coder.encode(id, forKey: CodingKeys.id.rawValue)
    coder.encode(accountId, forKey: CodingKeys.accountId.rawValue)
    coder.encode(personalAccountId, forKey: CodingKeys.personalAccountId.rawValue)
    coder.encode(accountOwnerId, forKey: CodingKeys.accountOwnerId.rawValue)
    coder.encode(accountName, forKey: CodingKeys.accountName.rawValue)
    coder.encode(email, forKey: CodingKeys.email.rawValue)
    coder.encode(name, forKey: CodingKeys.name.rawValue)
    coder.encode(timeZone, forKey: CodingKeys.timeZone.rawValue)
    coder.encode(token, forKey: CodingKeys.token.rawValue)
    coder.encode(client, forKey: CodingKeys.client.rawValue)
    coder.encode(uid, forKey: CodingKeys.uid.rawValue)
    coder.encode(expiry, forKey: CodingKeys.expiry.rawValue)
  }

  public required convenience init?(coder decoder: NSCoder) {
    let id = decoder.decodeObject(of: NSString.self, forKey: CodingKeys.id.rawValue)! as String
    let accountId = decoder.decodeObject(of: NSString.self, forKey: CodingKeys.accountId.rawValue)! as String
    let personalAccountId = decoder.decodeObject(of: NSString.self, forKey: CodingKeys.personalAccountId.rawValue)! as String
    let accountOwnerId = decoder.decodeObject(of: NSString.self, forKey: CodingKeys.accountOwnerId.rawValue)! as String
    let accountName = decoder.decodeObject(of: NSString.self, forKey: CodingKeys.accountName.rawValue)! as String
    let email = decoder.decodeObject(of: NSString.self, forKey: CodingKeys.email.rawValue)! as String
    let name = decoder.decodeObject(of: NSString.self, forKey: CodingKeys.name.rawValue)! as String
    let timeZone = decoder.decodeObject(of: NSString.self, forKey: CodingKeys.timeZone.rawValue)! as String
    let token = decoder.decodeObject(of: NSString.self, forKey: CodingKeys.token.rawValue)! as String
    let client = decoder.decodeObject(of: NSString.self, forKey: CodingKeys.client.rawValue)! as String
    let uid = decoder.decodeObject(of: NSString.self, forKey: CodingKeys.uid.rawValue)! as String
    let expiry = decoder.decodeObject(of: NSString.self, forKey: CodingKeys.expiry.rawValue)! as String

    self.init(
      id: id,
      accountId: accountId,
      personalAccountId: personalAccountId,
      accountOwnerId: accountOwnerId,
      accountName: accountName,
      email: email,
      name: name,
      timeZone: timeZone,
      token: token,
      client: client,
      uid: uid,
      expiry: expiry
    )
  }
  
  public static let supportsSecureCoding = true
}
