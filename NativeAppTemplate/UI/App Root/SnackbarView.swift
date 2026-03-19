//
//  SnackbarView.swift
//  NativeAppTemplate
//

import SwiftUI

struct SnackbarState {
    enum Status: String {
        case success, warning, error

        var color: Color {
            switch self {
            case .success:
                .snackSuccess
            case .warning:
                .snackWarning
            case .error:
                .snackError
            }
        }

        var tagText: String {
            rawValue.uppercased()
        }
    }

    let status: Status
    let message: String
}

struct SnackbarView: View {
    var state: SnackbarState
    @Binding var visible: Bool

    var body: some View {
        HStack {
            Text(state.message)
                .font(.uiBodyCustom)
                .foregroundStyle(.snackText)
                .animation(.none)

            Spacer()

            Button {
                withAnimation {
                    visible.toggle()
                }
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 16, height: 16)
            }
            .foregroundStyle(.snackText)
        }
        .padding(.vertical, 16.0)
        .padding(.horizontal, 24.0)
        .background(state.status.color)
        .overlay(
            Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(.lightestAccent),
            alignment: .top
        )
        .overlay(
            Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(.lightestAccent),
            alignment: .bottom
        )
    }
}

struct SnackbarView_Previews: PreviewProvider {
    @State static var visible = true
    static var previews: some View {
        VStack {
            SnackbarView(state: SnackbarState(status: .error, message: "There was a problem."), visible: $visible)
            SnackbarView(state: SnackbarState(status: .warning, message: "We're going orange."), visible: $visible)
            SnackbarView(state: SnackbarState(status: .success, message: "Everything looks peachy."), visible: $visible)
        }
    }
}
