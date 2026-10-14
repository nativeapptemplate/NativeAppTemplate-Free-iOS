//
//  NativeAppTemplateAPIErrorTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct NativeAppTemplateAPIErrorTest {
    @Test
    func requestFailedErrorCode() {
        let error = NativeAppTemplateAPIError.requestFailed(nil, 500, "Server error")
        #expect(error.errorCode == "NATIVEAPPTEMPLATE-2001")
    }

    @Test
    func processingErrorErrorCode() {
        let error = NativeAppTemplateAPIError.processingError(nil)
        #expect(error.errorCode == "NATIVEAPPTEMPLATE-2002")
    }

    @Test
    func responseMissingRequiredMetaErrorCode() {
        let error = NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "total")
        #expect(error.errorCode == "NATIVEAPPTEMPLATE-2003")
    }

    @Test
    func responseHasIncorrectNumberOfElementsErrorCode() {
        let error = NativeAppTemplateAPIError.responseHasIncorrectNumberOfElements
        #expect(error.errorCode == "NATIVEAPPTEMPLATE-2004")
    }

    @Test
    func noDataErrorCode() {
        let error = NativeAppTemplateAPIError.noData
        #expect(error.errorCode == "NATIVEAPPTEMPLATE-2005")
    }

    @Test
    func requestFailedWithMessage() {
        let error = NativeAppTemplateAPIError.requestFailed(nil, 422, "Validation failed")
        // The API's error_message, already localized, as is: the status is for the log only
        #expect(error.errorDescription == "Validation failed")
        #expect(error.formattedDescription == "[NATIVEAPPTEMPLATE-2001] Validation failed")
        #expect(error.debugDescription == "[NATIVEAPPTEMPLATE-2001] NativeAppTemplateAPIError::RequestFailed"
            + "[Status: 422 | Message: Validation failed | Error: UNKNOWN]")
    }

    @Test
    func requestFailedWithoutMessage() {
        let error = NativeAppTemplateAPIError.requestFailed(nil, 500, nil)
        // The generic communication error, worded as decided for iOS and Android (2026-10-14)
        #expect(error.errorDescription == "Something went wrong while communicating with the server." + " Please try again later.")
        #expect(error.debugDescription.contains("RequestFailed"))
        #expect(error.debugDescription.contains("Status: 500"))
        #expect(error.debugDescription.contains("UNKNOWN"))
    }

    @Test
    func processingErrorDescription() {
        let error = NativeAppTemplateAPIError.processingError(nil)
        // The generic text for developer-only errors, worded as decided for iOS and Android (2026-10-14)
        #expect(error.errorDescription == "An unexpected error occurred.")
        #expect(error.debugDescription.contains("ProcessingError"))
        #expect(error.debugDescription.contains("UNKNOWN"))
    }

    @Test
    func responseMissingRequiredMetaDescription() {
        let error = NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "count")
        #expect(error.formattedDescription == "[NATIVEAPPTEMPLATE-2003] An unexpected error occurred.")
        #expect(error.debugDescription.contains("ResponseMissingRequiredMeta"))
        #expect(error.debugDescription.contains("count"))
    }

    @Test
    func responseMissingRequiredMetaDescriptionNilField() {
        let error = NativeAppTemplateAPIError.responseMissingRequiredMeta(field: nil)
        #expect(error.debugDescription.contains("UNKNOWN"))
    }

    @Test
    func responseHasIncorrectNumberOfElementsDescription() {
        let error = NativeAppTemplateAPIError.responseHasIncorrectNumberOfElements
        #expect(error.formattedDescription == "[NATIVEAPPTEMPLATE-2004] An unexpected error occurred.")
        #expect(error.debugDescription.contains("ResponseHasIncorrectNumberOfElements"))
    }

    @Test
    func noDataDescription() {
        let error = NativeAppTemplateAPIError.noData
        #expect(error.errorDescription == "An unexpected error occurred.")
        #expect(error.formattedDescription == "[NATIVEAPPTEMPLATE-2005] An unexpected error occurred.")
        #expect(error.debugDescription == "[NATIVEAPPTEMPLATE-2005] NativeAppTemplateAPIError::NoData")
    }

    @Test
    func codedDescriptionViaErrorExtension() {
        let error: Error = NativeAppTemplateAPIError.requestFailed(nil, 404, "Not found")
        #expect(error.codedDescription == "[NATIVEAPPTEMPLATE-2001] Not found")
    }
}
