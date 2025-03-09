import Foundation

@MainActor
struct AppSingletons {
  var nfcManager: NFCManager
  
  init(nfcManager: NFCManager? = nil) {
    self.nfcManager = nfcManager ?? NFCManager.shared
  }
}

@MainActor var appSingletons = AppSingletons()
