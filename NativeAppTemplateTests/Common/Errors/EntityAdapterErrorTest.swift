//
//  EntityAdapterErrorTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

@Suite
struct EntityAdapterErrorTest {
    @Test
    func errorCodes() {
        #expect(EntityAdapterError.invalidResourceTypeForAdapter.errorCode == "NATIVEAPPTEMPLATE-2006")
        #expect(EntityAdapterError.invalidOrMissingAttributes.errorCode == "NATIVEAPPTEMPLATE-2007")
        #expect(EntityAdapterError.invalidOrMissingRelationships.errorCode == "NATIVEAPPTEMPLATE-2008")
    }

    @Test
    func formattedDescriptions() {
        #expect(
            EntityAdapterError.invalidResourceTypeForAdapter.formattedDescription
                == "[NATIVEAPPTEMPLATE-2006] EntityAdapterError::InvalidResourceTypeForAdapter"
        )
        #expect(
            EntityAdapterError.invalidOrMissingAttributes.formattedDescription
                == "[NATIVEAPPTEMPLATE-2007] EntityAdapterError::InvalidOrMissingAttributes"
        )
        #expect(
            EntityAdapterError.invalidOrMissingRelationships.formattedDescription
                == "[NATIVEAPPTEMPLATE-2008] EntityAdapterError::InvalidOrMissingRelationships"
        )
    }

    @Test
    func codedDescriptionPrependsCode() {
        let error: Error = EntityAdapterError.invalidOrMissingAttributes

        #expect(error.codedDescription == "[NATIVEAPPTEMPLATE-2007] EntityAdapterError::InvalidOrMissingAttributes")
    }
}
