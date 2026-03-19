//
//  String+Extensions.swift
//  NativeAppTemplate
//

import UIKit

extension String {
    /// Generates a `UIImage` instance from this string using a specified
    /// attributes and size.
    ///
    /// - Parameters:
    ///     - attributes: to draw this string with. Default is `nil`.
    ///     - size: of the image to return.
    /// - Returns: a `UIImage` instance from this string using a specified
    /// attributes and size, or `nil` if the operation fails.
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil, size: CGSize? = nil) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(
                in: CGRect(origin: .zero, size: size),
                withAttributes: attributes
            )
        }
    }

    func isAlphanumeric() -> Bool {
        rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && !isEmpty
    }

    func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
        if ignoreDiacritics {
            range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && !isEmpty
        } else {
            isAlphanumeric()
        }
    }
}
