//
//  InfoPlistTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing
import UIKit

/// Checks the built app's Info.plist (Bundle.main is the app the tests are hosted in)
struct InfoPlistTest {
    /// Without NSLocalNetworkUsageDescription, iOS denied the app local network
    /// access to a development API server on the LAN (NSURLErrorNotConnectedToInternet,
    /// "Local network prohibited") without ever showing the permission prompt.
    @Test
    func declaresTheLocalNetworkUsageDescription() throws {
        let info = try #require(Bundle.main.infoDictionary)
        let description = try #require(info["NSLocalNetworkUsageDescription"] as? String)

        #expect(!description.isEmpty)
    }

    /// UILaunchScreen's UIColorName must name a color set in the asset catalog
    /// (Apple's UILaunchScreen reference); a name that is not there is ignored
    /// silently and the launch screen falls back to the system background.
    /// The app defines its colors in Color+Extensions.swift, not in the asset catalog.
    @Test
    func everyLaunchScreenColorNameResolves() throws {
        let info = try #require(Bundle.main.infoDictionary)
        let launchScreen = try #require(info["UILaunchScreen"] as? [String: Any])

        if let colorName = launchScreen["UIColorName"] as? String {
            #expect(UIColor(named: colorName, in: .main, compatibleWith: nil) != nil, "\(colorName) is not in the asset catalog")
        }
    }

    /// The app is dark mode only (App.swift applies .preferredColorScheme(.dark)), but
    /// that only takes effect once SwiftUI is on screen. UIUserInterfaceStyle = Dark
    /// keeps the launch screen's system background dark in light mode too.
    @Test
    func launchesInDarkMode() throws {
        let info = try #require(Bundle.main.infoDictionary)

        #expect(info["UIUserInterfaceStyle"] as? String == "Dark")
    }

    /// iOS local network privacy identifies an app by its main executable's
    /// LC_UUID (Apple TN3179). With ENABLE_DEBUG_DYLIB the Debug main executable
    /// is a tiny stub that depends only on the product name, so this app and the
    /// paid NativeAppTemplate app (same product name) had the same UUID: the Free
    /// app was silently denied local network access and never prompted because
    /// the paid app already held the entry. Debug builds must link the code into
    /// the main executable, so no <product>.debug.dylib may be in the bundle.
    @Test
    func mainExecutableIsNotADebugDylibStub() throws {
        let executableName = try #require(Bundle.main.executableURL?.lastPathComponent)
        let debugDylib = Bundle.main.bundleURL.appendingPathComponent("\(executableName).debug.dylib")

        #expect(!FileManager.default.fileExists(atPath: debugDylib.path), "\(debugDylib.lastPathComponent) is in the app bundle")
    }
}
