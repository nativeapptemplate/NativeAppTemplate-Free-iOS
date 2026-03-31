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
                    .frame(width: NativeAppTemplateConstants.Spacing.sm, height: NativeAppTemplateConstants.Spacing.sm)
            }
            .foregroundStyle(.snackText)
        }
        .padding(.vertical, NativeAppTemplateConstants.Spacing.sm)
        .padding(.horizontal, NativeAppTemplateConstants.Spacing.md)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: NativeAppTemplateConstants.CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: NativeAppTemplateConstants.CornerRadius.md)
                .stroke(
                    Color.glassBorder.opacity(NativeAppTemplateConstants.Glass.borderOpacity),
                    lineWidth: NativeAppTemplateConstants.Layout.borderWidth
                )
        )
        .shadow(
            color: .glassShadow.opacity(NativeAppTemplateConstants.Glass.shadowOpacity),
            radius: NativeAppTemplateConstants.Layout.shadowRadius
        )
        .padding(.horizontal, NativeAppTemplateConstants.Spacing.xxs)
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
