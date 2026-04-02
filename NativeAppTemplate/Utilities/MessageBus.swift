//
//  MessageBus.swift
//  NativeAppTemplate
//

import Combine
import class Foundation.Timer
import SwiftUI

struct Message {
    enum Level {
        case error, warning, success
    }

    let level: Level
    let message: String
    var autoDismiss = true
}

extension Message {
    init(error: any Error, autoDismiss: Bool = false) {
        self.init(level: .error, message: error.codedDescription, autoDismiss: autoDismiss)
    }

    var snackbarState: SnackbarState {
        .init(status: level.snackbarStatus, message: message)
    }
}

extension Message.Level {
    var snackbarStatus: SnackbarState.Status {
        switch self {
        case .error:
            .error
        case .warning:
            .warning
        case .success:
            .success
        }
    }
}

@Observable class MessageBus {
    private(set) var currentMessage: Message?
    var messageVisible = false

    private var currentTimer: AnyCancellable?

    func post(message: Message) {
        invalidateTimer()

        currentMessage = message
        messageVisible = true

        if message.autoDismiss {
            currentTimer = createAndStartAutoDismissTimer()
        }
    }

    func dismiss() {
        invalidateTimer()
        messageVisible = false
    }

    private func createAndStartAutoDismissTimer() -> AnyCancellable {
        Timer
            .publish(every: .autoDismissTime, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                messageVisible = false
                invalidateTimer()
            }
    }

    private func invalidateTimer() {
        currentTimer?.cancel()
        currentTimer = nil
    }
}
