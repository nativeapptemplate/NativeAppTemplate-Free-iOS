//
//  CertificatePinningDelegate.swift
//  NativeAppTemplate
//

import CommonCrypto
import Foundation

final class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    /// SPKI SHA-256 hashes (base64-encoded) for api.nativeapptemplate.com
    /// The server uses Google Trust Services certificates (Render hosting).
    /// Pin the leaf public key and Google Trust Services intermediate CAs as backup.
    static let pinnedHashes: Set<String> = [
        // Leaf certificate public key (api.nativeapptemplate.com)
        "54Il7gpV4QvX8fAyEKV+6fp8VGjgHqIAAqF5bLCfYNQ=",
        // Google Trust Services WE1 intermediate CA
        "kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4="
    ]

    static let pinnedDomain = Strings.domain

    /// ASN.1 header for EC 256-bit public key (SPKI prefix)
    private static let ecDsaSecp256r1Asn1Header: [UInt8] = [
        0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86,
        0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a,
        0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03,
        0x42, 0x00
    ]

    /// ASN.1 header for RSA 2048-bit public key (SPKI prefix)
    private static let rsa2048Asn1Header: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09,
        0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              challenge.protectionSpace.host == Self.pinnedDomain,
              let serverTrust = challenge.protectionSpace.serverTrust
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        var pinMatched = false

        for index in 0 ..< certificateCount {
            guard let certificate = SecTrustCopyCertificateChain(serverTrust)
                .map({ unsafeBitCast(CFArrayGetValueAtIndex($0, index), to: SecCertificate.self) })
            else { continue }

            guard let publicKey = SecCertificateCopyKey(certificate) else { continue }

            var error: Unmanaged<CFError>?
            guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else { continue }

            let spkiHash = Self.sha256WithAsn1Header(for: publicKeyData)

            if Self.pinnedHashes.contains(spkiHash) {
                pinMatched = true
                break
            }
        }

        if pinMatched {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            Failure.certificatePinning(
                from: Self.self,
                reason: "Pin mismatch for \(challenge.protectionSpace.host)"
            ).log()
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private static func sha256WithAsn1Header(for publicKeyData: Data) -> String {
        let header: [UInt8] = if publicKeyData.count == 65 {
            ecDsaSecp256r1Asn1Header
        } else {
            rsa2048Asn1Header
        }

        var spkiData = Data(header)
        spkiData.append(publicKeyData)

        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        spkiData.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(spkiData.count), &hash)
        }

        return Data(hash).base64EncodedString()
    }
}

extension URLSession {
    private static let pinningDelegate = CertificatePinningDelegate()

    static let pinned: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(
            configuration: configuration,
            delegate: pinningDelegate,
            delegateQueue: nil
        )
    }()
}
