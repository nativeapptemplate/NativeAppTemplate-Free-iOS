//
//  PermissionsLoadingView.swift
//  NativeAppTemplate
//

import SwiftUI

struct PermissionsLoadingView: View {
    @Environment(\.sessionController) private var sessionController
    @State private var isShowingLogoutAlert = false

    var body: some View {
        LoadingView()
            .onTapGesture(count: 5) {
                isShowingLogoutAlert.toggle()
            }
            .alert(
                Strings.forceSignOut,
                isPresented: $isShowingLogoutAlert
            ) {
                Button(role: .destructive) {
                    logout()
                } label: {
                    Text(Strings.signOut)
                }
            }
    }

    func logout() {
        Task {
            try await sessionController.logout()
        }
    }
}

struct PermissionsLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsLoadingView()
    }
}
