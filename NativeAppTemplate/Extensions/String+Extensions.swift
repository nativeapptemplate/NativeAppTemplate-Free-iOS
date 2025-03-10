//
//  String+Extensions.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2024/01/04.
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
      (self as NSString).draw(in: CGRect(origin: .zero, size: size),
                              withAttributes: attributes)
    }
  }

  func isAlphanumeric() -> Bool {
    self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && !self.isEmpty
  }
  
  func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
    if ignoreDiacritics {
      return self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && !self.isEmpty
    } else {
      return self.isAlphanumeric()
    }
  }
}
