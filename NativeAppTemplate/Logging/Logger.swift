//
//  Logger.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2024/01/04.
//

struct Failure {
  static func signUp<Source>(from source: Source.Type, reason: String) -> Self {
    .init(source: source, action: "signUp", reason: reason)
  }

  static func login<Source>(from source: Source.Type, reason: String) -> Self {
    .init(source: source, action: "login", reason: reason)
  }

  static func logout<Source>(from source: Source.Type, reason: String) -> Self {
    .init(source: source, action: "logout", reason: reason)
  }

  static func fetch<Source>(from source: Source.Type, reason: String) -> Self {
    .init(source: source, action: "fetch", reason: reason)
  }

  static func create<Source>(from source: Source.Type, reason: String) -> Self {
    .init(source: source, action: "create", reason: reason)
  }

  static func update<Source>(from source: Source.Type, reason: String) -> Self {
    .init(source: source, action: "update", reason: reason)
  }

  static func destroy<Source>(from source: Source.Type, reason: String) -> Self {
    .init(source: source, action: "destroy", reason: reason)
  }

  private init<Source>(
    source: Source.Type,
    action: String,
    reason: String
  ) {
    self.init(
      source: "\(Source.self)",
      action: action,
      reason: reason
    )
  }

  private init(
    source: String,
    action: String,
    reason: String
  ) {
    self.source = source
    self.action = "Failed_\(action)"
    self.reason = reason
  }

  private let source: String
  private let action: String
  private let reason: String
  
  func log() {
    print(
      [ "source": source,
        "action": action,
        "reason": reason
      ]
    )
  }
}

struct Event {
  static func login<Source>(from source: Source.Type) -> Self {
    .init(
      source: "\(Source.self)",
      action: "Login"
    )
  }

  static func refresh<Source>(
    from source: Source.Type,
    action: String
  ) -> Self {
    .init(
      source: "\(Source.self)",
      action: "Refresh"
    )
  }

  private let source: String
  private let action: String

  func log() {
    print("EVENT:: \(["source": source, "action": action])")
  }
}
