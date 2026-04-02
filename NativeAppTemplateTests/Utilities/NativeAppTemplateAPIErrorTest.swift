//
//  NativeAppTemplateAPIErrorTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

@Suite
struct NativeAppTemplateAPIErrorTest {
    @Test
    func requestFailedErrorCode() {
        let error = NativeAppTemplateAPIError.requestFailed(nil, 500, "Server error")
        #expect(error.errorCode == "NATI-2001")
    }

    @Test
    func processingErrorErrorCode() {
        let error = NativeAppTemplateAPIError.processingError(nil)
        #expect(error.errorCode == "NATI-2002")
    }

    @Test
    func responseMissingRequiredMetaErrorCode() {
        let error = NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "total")
        #expect(error.errorCode == "NATI-2003")
    }

    @Test
    func responseHasIncorrectNumberOfElementsErrorCode() {
        let error = NativeAppTemplateAPIError.responseHasIncorrectNumberOfElements
        #expect(error.errorCode == "NATI-2004")
    }

    @Test
    func noDataErrorCode() {
        let error = NativeAppTemplateAPIError.noData
        #expect(error.errorCode == "NATI-2005")
    }

    @Test
    func requestFailedWithMessage() {
        let error = NativeAppTemplateAPIError.requestFailed(nil, 422, "Validation failed")
        #expect(error.errorDescription == "Validation failed [Status: 422]")
        #expect(error.formattedDescription == "[NATI-2001] Validation failed [Status: 422]")
    }

    @Test
    func requestFailedWithoutMessage() {
        let error = NativeAppTemplateAPIError.requestFailed(nil, 500, nil)
        let description = error.errorDescription!
        #expect(description.contains("RequestFailed"))
        #expect(description.contains("500"))
        #expect(description.contains("UNKNOWN"))
    }

    @Test
    func processingErrorDescription() {
        let error = NativeAppTemplateAPIError.processingError(nil)
        #expect(error.errorDescription!.contains("ProcessingError"))
        #expect(error.errorDescription!.contains("UNKNOWN"))
    }

    @Test
    func responseMissingRequiredMetaDescription() {
        let error = NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "count")
        #expect(error.errorDescription!.contains("ResponseMissingRequiredMeta"))
        #expect(error.errorDescription!.contains("count"))
    }

    @Test
    func responseMissingRequiredMetaDescriptionNilField() {
        let error = NativeAppTemplateAPIError.responseMissingRequiredMeta(field: nil)
        #expect(error.errorDescription!.contains("UNKNOWN"))
    }

    @Test
    func responseHasIncorrectNumberOfElementsDescription() {
        let error = NativeAppTemplateAPIError.responseHasIncorrectNumberOfElements
        #expect(error.errorDescription!.contains("ResponseHasIncorrectNumberOfElements"))
    }

    @Test
    func noDataDescription() {
        let error = NativeAppTemplateAPIError.noData
        #expect(error.errorDescription == "NativeAppTemplateAPIError::NoData")
        #expect(error.formattedDescription == "[NATI-2005] NativeAppTemplateAPIError::NoData")
    }

    @Test
    func codedDescriptionViaErrorExtension() {
        let error: Error = NativeAppTemplateAPIError.requestFailed(nil, 404, "Not found")
        #expect(error.codedDescription == "[NATI-2001] Not found [Status: 404]")
    }
}
