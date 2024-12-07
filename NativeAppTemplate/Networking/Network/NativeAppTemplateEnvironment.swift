//
//  NativeAppTemplate.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2022/07/03.
//

import struct Foundation.URL

struct NativeAppTemplateEnvironment: Equatable {

  // MARK: - Properties
  var baseURL: URL
  let basePath = "/api/v1"
}

extension NativeAppTemplateEnvironment {
  static let urlString = if String.port.isEmpty {
    "\(String.scheme)://\(String.domain)"
  } else {
    "\(String.scheme)://\(String.domain):\(String.port)"
  }
  
  static let prod = NativeAppTemplateEnvironment(baseURL: URL(string: urlString)!)
}
