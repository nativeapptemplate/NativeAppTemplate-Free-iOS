//
//  MessageBarView.swift
//  NativeAppTemplate
//

import SwiftUI

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        AnyTransition.move(edge: .bottom)
            .combined(with: .opacity)
    }
}

struct MessageBarView: View {
    @Bindable var messageBus: MessageBus

    var body: some View {
        VStack {
            if messageBus.messageVisible {
                SnackbarView(
                    state: messageBus.currentMessage!.snackbarState,
                    visible: $messageBus.messageVisible
                )
            }
        }
        .transition(.moveAndFade)
        .animation(.default, value: messageBus.messageVisible)
    }
}

struct MessageBarView_Previews: PreviewProvider {
    static var previews: some View {
        let messageBus = MessageBus()
        messageBus.post(message: Message(level: .warning, message: "This is a warning"))

        return VStack {
            Button(
                action: {
                    messageBus.messageVisible.toggle()
                },
                label: {
                    Text(verbatim: "Show/Hide")
                }
            )

            Button(
                action: {
                    messageBus.post(message: Message(level: .success, message: "Button clicked!"))
                },
                label: {
                    Text(verbatim: "Post new message")
                }
            )

            MessageBarView(messageBus: messageBus)
        }
    }
}
