//
//  PermissionsService.swift
//  NativeAppTemplate
//

struct PermissionsService: Service {
    var networkClient = NativeAppTemplateAPI()
}

extension PermissionsService {
    func allPermissions() async throws -> PermissionsRequest.Response {
        try await makeRequest(request: PermissionsRequest())
    }
}
