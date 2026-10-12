//
//  APISessionDelegate.swift
//  NativeAppTemplate
//

import CommonCrypto
import Foundation

/// The delegate of `URLSession.pinned`: it pins the API's certificates and keeps the
/// session headers from following a redirect to another host.
final class APISessionDelegate: NSObject, URLSessionTaskDelegate {
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

    /// The host that gets the session headers (`Service.makeRequest`)
    let apiHost: String

    init(apiHost: String = pinnedDomain) {
        self.apiHost = apiHost
    }

    /// The devise_token_auth headers `Service.makeRequest` adds; together they are a session
    static let sessionHeaderNames = ["access-token", "token-type", "client", "expiry", "uid"]

    /// URLSession copies custom headers to every redirect hop, so drop the session
    /// when a redirect leaves the API host.
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        guard request.url?.host?.lowercased() != apiHost.lowercased() else {
            completionHandler(request)
            return
        }

        var request = request
        for name in Self.sessionHeaderNames {
            request.setValue(nil, forHTTPHeaderField: name)
        }
        completionHandler(request)
    }

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

        if Self.isTrusted(serverTrust) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            Failure.certificatePinning(
                from: Self.self,
                reason: "Untrusted chain or pin mismatch for \(challenge.protectionSpace.host)"
            ).log()
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    /// Whether the system trusts `serverTrust` and its chain contains a pinned public key.
    /// The pins only narrow down trust the system has already granted: a pinned CA
    /// certificate is public, so matching its pin on a chain the system rejects would let
    /// anyone pass. Returning `.useCredential` tells URLSession the chain was evaluated,
    /// so the default checks would not run either.
    static func isTrusted(_ serverTrust: SecTrust, pinnedHashes: Set<String> = pinnedHashes) -> Bool {
        guard SecTrustEvaluateWithError(serverTrust, nil) else { return false }

        let chain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] ?? []

        return chain.contains { certificate in
            guard let publicKey = SecCertificateCopyKey(certificate),
                  let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data?
            else { return false }

            return pinnedHashes.contains(sha256WithAsn1Header(for: publicKeyData))
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
    private static let pinningDelegate = APISessionDelegate()

    static let pinned: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(
            configuration: configuration,
            delegate: pinningDelegate,
            delegateQueue: nil
        )
    }()
}
