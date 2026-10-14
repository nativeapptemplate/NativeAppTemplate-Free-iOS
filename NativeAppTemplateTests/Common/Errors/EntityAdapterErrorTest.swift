//
//  EntityAdapterErrorTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct EntityAdapterErrorTest {
    @Test
    func errorCodes() {
        #expect(EntityAdapterError.invalidResourceTypeForAdapter.errorCode == "NATIVEAPPTEMPLATE-2006")
        #expect(EntityAdapterError.invalidOrMissingAttributes.errorCode == "NATIVEAPPTEMPLATE-2007")
        #expect(EntityAdapterError.invalidOrMissingRelationships.errorCode == "NATIVEAPPTEMPLATE-2008")
    }

    @Test
    func formattedDescriptions() {
        // The generic text for developer-only errors, worded as decided for iOS and Android (2026-10-14)
        #expect(
            EntityAdapterError.invalidResourceTypeForAdapter.formattedDescription
                == "[NATIVEAPPTEMPLATE-2006] An unexpected error occurred."
        )
        #expect(
            EntityAdapterError.invalidOrMissingAttributes.formattedDescription
                == "[NATIVEAPPTEMPLATE-2007] An unexpected error occurred."
        )
        #expect(
            EntityAdapterError.invalidOrMissingRelationships.formattedDescription
                == "[NATIVEAPPTEMPLATE-2008] An unexpected error occurred."
        )
    }

    @Test
    func codedDescriptionPrependsCode() {
        let error: Error = EntityAdapterError.invalidOrMissingAttributes

        #expect(error.codedDescription == "[NATIVEAPPTEMPLATE-2007] An unexpected error occurred.")
    }

    /// The log still names the case
    @Test
    func debugDescriptionNamesTheCase() {
        #expect(EntityAdapterError.invalidOrMissingAttributes.debugDescription
            == "[NATIVEAPPTEMPLATE-2007] EntityAdapterError::InvalidOrMissingAttributes")
    }
}
