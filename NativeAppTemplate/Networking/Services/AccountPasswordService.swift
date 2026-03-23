//
//  AccountPasswordService.swift
//  NativeAppTemplate
//

struct AccountPasswordService: Service {
    var networkClient = NativeAppTemplateAPI()
}

extension AccountPasswordService {
    func updatePassword(updatePassword: UpdatePassword) async throws -> UpdateAccountPasswordRequest.Response {
        let request = UpdateAccountPasswordRequest(updatePassword: updatePassword)
        return try await makeRequest(request: request)
    }
}
