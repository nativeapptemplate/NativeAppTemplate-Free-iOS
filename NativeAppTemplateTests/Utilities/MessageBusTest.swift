//
//  MessageBusTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

@MainActor
@Suite
struct MessageBusTest {
    @Test
    func initialState() {
        let bus = MessageBus()

        #expect(bus.currentMessage == nil)
        #expect(bus.messageVisible == false)
    }

    @Test
    func postMessageSetsCurrentMessage() {
        let bus = MessageBus()

        bus.post(message: Message(level: .success, message: "Done"))

        #expect(bus.currentMessage != nil)
        #expect(bus.currentMessage?.message == "Done")
        #expect(bus.currentMessage?.level == .success)
        #expect(bus.messageVisible == true)
    }

    @Test
    func postErrorMessage() {
        let bus = MessageBus()

        bus.post(message: Message(level: .error, message: "Failed", autoDismiss: false))

        #expect(bus.currentMessage?.level == .error)
        #expect(bus.currentMessage?.message == "Failed")
        #expect(bus.currentMessage?.autoDismiss == false)
        #expect(bus.messageVisible == true)
    }

    @Test
    func dismiss() {
        let bus = MessageBus()

        bus.post(message: Message(level: .success, message: "Done"))
        #expect(bus.messageVisible == true)

        bus.dismiss()
        #expect(bus.messageVisible == false)
    }

    @Test
    func postReplacesExistingMessage() {
        let bus = MessageBus()

        bus.post(message: Message(level: .success, message: "First"))
        bus.post(message: Message(level: .error, message: "Second"))

        #expect(bus.currentMessage?.message == "Second")
        #expect(bus.currentMessage?.level == .error)
    }

    @Test
    func snackbarState() {
        let message = Message(level: .error, message: "Error occurred")
        let snackbarState = message.snackbarState

        #expect(snackbarState.status == .error)
        #expect(snackbarState.message == "Error occurred")
    }

    @Test
    func messageLevelSnackbarStatus() {
        #expect(Message.Level.error.snackbarStatus == .error)
        #expect(Message.Level.warning.snackbarStatus == .warning)
        #expect(Message.Level.success.snackbarStatus == .success)
    }
}
