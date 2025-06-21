//
//  ShopkeeperEditView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/23.
//

import SwiftUI

struct ShopkeeperEditView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) var openURL
  @Environment(MessageBus.self) private var messageBus
  @Environment(\.sessionController) private var sessionController
  @Environment(TabViewModel.self) private var tabViewModel
  @State private var isUpdating = false
  @State private var isDeleting = false
  @State private var name: String = ""
  @State private var email: String = ""
  @State private var selectedTimeZone: String
  @State private var isShowingDeleteConfirmationDialog = false
  private var signUpRepository: SignUpRepositoryProtocol
  private var shopkeeper: Shopkeeper
  
  init(
    signUpRepository: SignUpRepositoryProtocol,
    shopkeeper: Shopkeeper
  ) {
    self.signUpRepository = signUpRepository
    self.shopkeeper = shopkeeper
    _name = State(initialValue: shopkeeper.name)
    _email = State(initialValue: shopkeeper.email)
    _selectedTimeZone = State(initialValue: shopkeeper.timeZone)
  }
  
  private var hasInvalidData: Bool {
    if Utility.isBlank(name) {
      return true
    }
    
    if hasInvalidDataEmail {
      return true
    }

    if shopkeeper.name == name &&
        shopkeeper.email == email &&
        shopkeeper.timeZone == selectedTimeZone {
      return true
    }
    
    return false
  }
  
  private var hasInvalidDataEmail: Bool {
    if Utility.isBlank(email) {
      return true
    }

    if !Utility.validateEmail(email) {
      return true
    }

    return false
  }
  
  var body: some View {
    contentView
  }
}

// MARK: - private
private extension ShopkeeperEditView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if isUpdating || isDeleting {
        LoadingView()
      } else {
        shopkeeperEditView
      }
    }
    
    return contentView
  }
  
  var shopkeeperEditView: some View {
    Form {
      Section {
        TextField(String.placeholderFullName, text: $name)
      } header: {
        Text(String.fullName)
      } footer: {
        Text(String.fullNameIsRequired)
           .foregroundStyle(Utility.isBlank(name) ? .red : .clear)
      }
      
      Section {
        TextField(String.placeholderEmail, text: $email)
          .textContentType(.emailAddress)
          .autocapitalization(.none)
      } header: {
        Text(String.email)
      } footer: {
        if Utility.isBlank(email) {
          Text(String.emailIsRequired)
            .foregroundStyle(.red)
        } else if hasInvalidDataEmail {
          Text(String.emailIsInvalid)
            .foregroundStyle(.red)
        }
      }
      
      Section {
        Picker(String.timeZone, selection: $selectedTimeZone) {
          ForEach(timeZones.keys, id: \.self) { key in
            Text(timeZones[key]!).tag(key)
          }
        }
      }
      
      Spacer()
        .listRowBackground(Color.clear)
      
      Section {
        MainButtonView(title: String.deleteMyAccount, type: .destructive(withArrow: false)) {
          isShowingDeleteConfirmationDialog = true
        }
        .listRowBackground(Color.clear)
      }
    }
    .confirmationDialog(
      String.deleteMyAccount,
      isPresented: $isShowingDeleteConfirmationDialog
    ) {
      Button(String.deleteMyAccount, role: .destructive) {
        destroyShopkeeper()
      }
      
      Button(String.cancel, role: .cancel) {
        isShowingDeleteConfirmationDialog = false
      }
    } message: {
      Text(String.areYouSure)
    }
    .navigationTitle(String.editProfile)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          updateShopkeeper()
        } label: {
          Text(String.save)
        }
        .disabled(hasInvalidData)
      }
    }
  }
  
  func updateShopkeeper() {
    let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
    let theName = name.trimmingCharacters(in: whitespacesAndNewlines)
    let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)
    let emailUpdated = theEmail != shopkeeper.email
    
    Task { @MainActor in
      do {
        isUpdating = true

        let signUp = SignUp(
          name: theName,
          email: theEmail,
          timeZone: selectedTimeZone
        )
        let shopkeeper = try await signUpRepository.update(id: shopkeeper.id, signUp: signUp, networkClient: sessionController.client)
        
        var newShopkeeper = sessionController.shopkeeper!
        
        newShopkeeper.email = shopkeeper.email
        newShopkeeper.name = shopkeeper.name
        newShopkeeper.timeZone = shopkeeper.timeZone
        newShopkeeper.uid = shopkeeper.uid
        
        try sessionController.updateShopkeeper(shopkeeper: newShopkeeper)

        if emailUpdated {
          messageBus.post(message: Message(level: .success, message: .reconfirmDescription, autoDismiss: false))
          try await sessionController.logout()
        } else {
          messageBus.post(message: Message(level: .success, message: .shopkeeperUpdated))
        }
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
      }
      
      isUpdating = false
      dismiss()
    }
  }
  
  private func destroyShopkeeper() {
    Task { @MainActor in
      isDeleting = true

      do {
        try await signUpRepository.destroy(networkClient: sessionController.client)
        messageBus.post(message: Message(level: .success, message: .shopkeeperDeleted))
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.shopkeeperDeletedError) \(error.localizedDescription)", autoDismiss: false))
      }
      
      do {
        try sessionController.updateShopkeeper(shopkeeper: nil)
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.shopkeeperDeletedError) \(error.localizedDescription)", autoDismiss: false))
      }
      
      isDeleting = false
      // Without this code, error occurs
      tabViewModel.selectedTab = .shops
      dismiss()
    }
  }
}
