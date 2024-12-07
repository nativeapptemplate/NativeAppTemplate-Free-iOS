//
//  Bundle+Extensions.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/11/13.
//

import Foundation

extension Bundle {
  public var appName: String { getInfo("CFBundleName") }
  public var displayName: String { getInfo("CFBundleDisplayName") }
  public var language: String { getInfo("CFBundleDevelopmentRegion") }
  public var identifier: String { getInfo("CFBundleIdentifier") }
  public var copyright: String { getInfo("NSHumanReadableCopyright").replacingOccurrences(of: "\\\\n", with: "\n") }
  
  public var appBuild: String { getInfo("CFBundleVersion") }
  public var appVersionLong: String { getInfo("CFBundleShortVersionString") }
  
  private func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "⚠️" }
}
