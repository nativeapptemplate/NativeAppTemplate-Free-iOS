//
//  Bundle+Extensions.swift
//  NativeAppTemplate
//

import Foundation

public extension Bundle {
    var appBuild: String {
        getInfo("CFBundleVersion")
    }

    var appVersionLong: String {
        getInfo("CFBundleShortVersionString")
    }

    private func getInfo(_ str: String) -> String {
        infoDictionary?[str] as? String ?? "⚠️"
    }
}
