//
//  AppLauncherTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct AppLauncherTest {
    /// If detection breaks, tests still pass but run inside the full app
    /// (keychain, network monitoring), which slows every run.
    @Test
    func detectsUnitTestHost() {
        #expect(AppLauncher.isHostingUnitTests)
    }
}
