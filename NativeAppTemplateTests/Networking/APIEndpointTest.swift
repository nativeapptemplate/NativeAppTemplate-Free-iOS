//
//  APIEndpointTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

struct APIEndpointTest {
    let info: [String: Any] = [
        "NativeAppTemplateAPIScheme": "http",
        "NativeAppTemplateAPIDomain": "192.168.1.21",
        "NativeAppTemplateAPIPort": "3000",
    ]

    /// Launched from the Home Screen (or relaunched by iOS after the app's
    /// language changes), the app gets no scheme environment variables, so the
    /// endpoint built into Info.plist (API.xcconfig) must be used
    @Test
    func infoPlistIsUsedWithoutEnvironmentVariables() {
        let endpoint = APIEndpoint.resolve(environment: [:], info: info)

        #expect(endpoint == APIEndpoint(scheme: "http", domain: "192.168.1.21", port: "3000"))
    }

    /// The agent passes the endpoint through `simctl launch`
    /// (SIMCTL_CHILD_*), which must keep working
    @Test
    func environmentVariablesWinOverInfoPlist() {
        let environment = [
            "NATIVEAPPTEMPLATE_API_SCHEME": "https",
            "NATIVEAPPTEMPLATE_API_DOMAIN": "10.0.0.5",
            "NATIVEAPPTEMPLATE_API_PORT": "8080",
        ]

        let endpoint = APIEndpoint.resolve(environment: environment, info: info)

        #expect(endpoint == APIEndpoint(scheme: "https", domain: "10.0.0.5", port: "8080"))
    }

    /// An unset build setting expands to "" in Info.plist
    @Test
    func emptyValuesFallBackToTheProductionAPI() {
        let empty: [String: Any] = [
            "NativeAppTemplateAPIScheme": "",
            "NativeAppTemplateAPIDomain": "",
            "NativeAppTemplateAPIPort": "",
        ]

        #expect(APIEndpoint.resolve(environment: [:], info: empty) == .production)
        #expect(APIEndpoint.resolve(environment: [:], info: [:]) == .production)
    }

    /// Guards the wiring: API.xcconfig → build settings → Info.plist
    @Test
    func theAppBundleCarriesTheEndpointFromAPIXcconfig() throws {
        let info = try #require(Bundle.main.infoDictionary)
        let domain = try #require(info["NativeAppTemplateAPIDomain"] as? String)

        #expect(!domain.isEmpty)
        #expect(!domain.contains("$("))
    }
}
