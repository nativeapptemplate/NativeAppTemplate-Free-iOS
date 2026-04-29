//
//  Onboarding.swift
//  NativeAppTemplate
//

enum ImageOrientation: String, Hashable, Codable {
    case portrait
    case landscape
}

struct Onboarding: Hashable, Codable, Identifiable {
    var id: Int
    var imageOrientation: ImageOrientation = .landscape
}
