//
//  Logger.swift
//  NativeAppTemplate
//

import os

private let appLogger = os.Logger(subsystem: "com.nativeapptemplate", category: "app")

struct Failure {
    static func signUp(from source: (some Any).Type, reason: String) -> Self {
        .init(source: source, action: "signUp", reason: reason)
    }

    static func login(from source: (some Any).Type, reason: String) -> Self {
        .init(source: source, action: "login", reason: reason)
    }

    static func logout(from source: (some Any).Type, reason: String) -> Self {
        .init(source: source, action: "logout", reason: reason)
    }

    static func fetch(from source: (some Any).Type, reason: String) -> Self {
        .init(source: source, action: "fetch", reason: reason)
    }

    static func create(from source: (some Any).Type, reason: String) -> Self {
        .init(source: source, action: "create", reason: reason)
    }

    static func update(from source: (some Any).Type, reason: String) -> Self {
        .init(source: source, action: "update", reason: reason)
    }

    static func destroy(from source: (some Any).Type, reason: String) -> Self {
        .init(source: source, action: "destroy", reason: reason)
    }

    static func certificatePinning(from source: (some Any).Type, reason: String) -> Self {
        .init(source: source, action: "certificatePinning", reason: reason)
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
        appLogger.error(
            """
            \(self.action, privacy: .public) \
            source=\(self.source, privacy: .public) \
            reason=\(self.reason, privacy: .private)
            """
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
        appLogger.info("EVENT:: source: \(self.source, privacy: .public), action: \(self.action, privacy: .public)")
    }
}
