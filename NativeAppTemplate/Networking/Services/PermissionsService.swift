//
//  PermissionsService.swift
//  NativeAppTemplate
//

import class Foundation.URLSession

struct PermissionsService: Service {
    var networkClient = NativeAppTemplateAPI()
    let session = URLSession(configuration: .default)
}

extension PermissionsService {
    func allPermissions() async throws -> PermissionsRequest.Response {
        try await makeRequest(request: PermissionsRequest())
    }
}
