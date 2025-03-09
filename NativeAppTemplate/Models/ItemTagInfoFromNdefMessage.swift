//
//  ItemTagInfoFromNdefMessage.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import Foundation

struct ItemTagInfoFromNdefMessage {
  var id: String
  var type: String
  var success: Bool
  var message: String
  
  init() {
    self.id = ""
    self.type = ""
    self.success = false
    self.message = .messageWrittenOnTagIsWrong
  }
}
