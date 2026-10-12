//
//  CertificatePinningDelegateTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Security
import Testing

/// The pin check must only run on a chain the system already trusts. Otherwise anyone
/// can attach a public pinned CA certificate (such as Google Trust Services WE1) to a
/// chain of their own and the pin matches.
///
/// The certificates below are a throwaway test PKI made with OpenSSL 3.6 (P-256 keys):
/// a root, an intermediate it signed, and a leaf for api.nativeapptemplate.com that the
/// intermediate signed. The root is set as the only anchor, so the tests decide which
/// chains the system trusts.
struct CertificatePinningDelegateTest {
    /// CN=NativeAppTemplate Test Root, self-signed, valid 2026-01-01 to 2036-01-01
    private static let root = certificate(
        "MIIBfjCCASOgAwIBAgIBATAKBggqhkjOPQQDAjAmMSQwIgYDVQQDDBtOYXRpdmVBcHBUZW1wbGF0ZSBUZXN0IFJvb3QwHhcNMjYwMTAxMDAwMDAwWhcNMzYwMTAxMDAwMDAwWjAmMSQwIgYDVQQDDBtOYXRpdmVBcHBUZW1wbGF0ZSBUZXN0IFJvb3QwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAR9C4ceNBnJW1NH8stpjJiScZNoGqf5W3l9jI9rva25owZnYxVEnYEl1ar7nZfqzCBPrbcvGyssywH8OHM9b4zmo0IwQDAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUwaAu0uVI8clmzGrtUHfDRLwKiy0wCgYIKoZIzj0EAwIDSQAwRgIhAOMWDc2bsxwv/p51MkCYazNyXI2s+12hekB5mMT3SWG5AiEAnIZoEyoNQwqgf6zrxtREl2qLOileoXafHje2z7qydyo="
    )

    /// CN=NativeAppTemplate Test Intermediate, issued by the root, valid 2026-01-01 to 2034-01-01
    private static let intermediate = certificate(
        "MIIBvzCCAWSgAwIBAgIBAjAKBggqhkjOPQQDAjAmMSQwIgYDVQQDDBtOYXRpdmVBcHBUZW1wbGF0ZSBUZXN0IFJvb3QwHhcNMjYwMTAxMDAwMDAwWhcNMzQwMTAxMDAwMDAwWjAuMSwwKgYDVQQDDCNOYXRpdmVBcHBUZW1wbGF0ZSBUZXN0IEludGVybWVkaWF0ZTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABKln4AFs7M1nYjQak4dIfhjh7+4PEj+9YVdF7Eepp7ZqthAf5vXELffSr0mblhCQLyBwGVNQLtcFVzklFwoQQu2jezB5MBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgEGMBMGA1UdJQQMMAoGCCsGAQUFBwMBMB0GA1UdDgQWBBStNfavkz3/NLX/e9SzUb4tES1a1jAfBgNVHSMEGDAWgBTBoC7S5UjxyWbMau1Qd8NEvAqLLTAKBggqhkjOPQQDAgNJADBGAiEAvWTJEKakRW+IjKelNESob0AYaCr+pKZaFMYOpBw6J1sCIQDC25HtQCLXrzPu1EnuonLU8cj7wkxkkV++16WJmjyvkQ=="
    )

    /// CN=api.nativeapptemplate.com, SAN api.nativeapptemplate.com, issued by the
    /// intermediate, valid 2026-01-01 to 2026-12-01
    private static let leaf = certificate(
        "MIIB3jCCAYSgAwIBAgIBAzAKBggqhkjOPQQDAjAuMSwwKgYDVQQDDCNOYXRpdmVBcHBUZW1wbGF0ZSBUZXN0IEludGVybWVkaWF0ZTAeFw0yNjAxMDEwMDAwMDBaFw0yNjEyMDEwMDAwMDBaMCQxIjAgBgNVBAMMGWFwaS5uYXRpdmVhcHB0ZW1wbGF0ZS5jb20wWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQ3RpCKRw1545nU0PTu+57kgllpHk5npoBwjf0nKL438GYaPaK4BazvElpYniOVgOTxnQLGNjmuN3L0TNqDcuIVo4GcMIGZMAwGA1UdEwEB/wQCMAAwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMBMCQGA1UdEQQdMBuCGWFwaS5uYXRpdmVhcHB0ZW1wbGF0ZS5jb20wHQYDVR0OBBYEFIrOjVORoG9DwzorcBddJ2mxvZXOMB8GA1UdIwQYMBaAFK019q+TPf80tf971LNRvi0RLVrWMAoGCCqGSM49BAMCA0gAMEUCICX2cJckCOTmdRFRj6sF9kFASGvwJZKNTUVKxlA32HkiAiEAwfL6dI2EcqShknjeY2161wzVWphFjClGgcXKeAbKS5A="
    )

    /// The intermediate's SPKI SHA-256, from
    /// `openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64`
    private static let intermediatePin: Set<String> = ["mZIYLxYOtwKliMsZPMg+JXPhE2vUo17R5Obl/nwk2nY="]

    private static let host = "api.nativeapptemplate.com"
    /// Inside every certificate's validity period above
    private static let validDate = ISO8601DateFormatter().date(from: "2026-06-01T00:00:00Z")!
    /// After the leaf's notAfter (2026-12-01), before the intermediate's (2034-01-01)
    private static let afterLeafExpiry = ISO8601DateFormatter().date(from: "2027-01-01T00:00:00Z")!

    private static func certificate(_ base64: String) -> SecCertificate {
        SecCertificateCreateWithData(nil, Data(base64Encoded: base64)! as CFData)!
    }

    /// `anchored` makes the test root the only trusted root, as a public root is for a real chain
    private static func trust(
        _ certificates: [SecCertificate],
        host: String = host,
        date: Date = validDate,
        anchored: Bool = true
    ) -> SecTrust {
        var trust: SecTrust?
        SecTrustCreateWithCertificates(certificates as CFArray, SecPolicyCreateSSL(true, host as CFString), &trust)
        if anchored {
            SecTrustSetAnchorCertificates(trust!, [root] as CFArray)
            SecTrustSetAnchorCertificatesOnly(trust!, true)
        }
        SecTrustSetVerifyDate(trust!, date as CFDate)
        return trust!
    }

    @Test
    func trustsValidChainWithPinnedIntermediate() {
        let trust = Self.trust([Self.leaf, Self.intermediate])

        #expect(CertificatePinningDelegate.isTrusted(trust, pinnedHashes: Self.intermediatePin))
    }

    /// No trusted root: anyone can build this chain around a public pinned certificate
    @Test
    func rejectsChainTheSystemDoesNotTrustEvenThoughIntermediateIsPinned() {
        let trust = Self.trust([Self.leaf, Self.intermediate], anchored: false)

        #expect(!CertificatePinningDelegate.isTrusted(trust, pinnedHashes: Self.intermediatePin))
    }

    @Test
    func rejectsExpiredChainEvenThoughIntermediateIsPinned() {
        let trust = Self.trust([Self.leaf, Self.intermediate], date: Self.afterLeafExpiry)

        #expect(!CertificatePinningDelegate.isTrusted(trust, pinnedHashes: Self.intermediatePin))
    }

    /// The leaf's only SAN is api.nativeapptemplate.com
    @Test
    func rejectsChainIssuedForAnotherHostEvenThoughIntermediateIsPinned() {
        let trust = Self.trust([Self.leaf, Self.intermediate], host: "api.example.com")

        #expect(!CertificatePinningDelegate.isTrusted(trust, pinnedHashes: Self.intermediatePin))
    }

    /// The intermediate is a CA certificate, not one issued for the API host
    @Test
    func rejectsPinnedIntermediatePresentedAlone() {
        let trust = Self.trust([Self.intermediate])

        #expect(!CertificatePinningDelegate.isTrusted(trust, pinnedHashes: Self.intermediatePin))
    }

    @Test
    func rejectsValidChainWithoutPinnedKey() {
        let trust = Self.trust([Self.leaf, Self.intermediate])

        #expect(!CertificatePinningDelegate.isTrusted(
            trust,
            pinnedHashes: ["AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="]
        ))
    }
}
