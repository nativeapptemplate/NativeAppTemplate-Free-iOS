//
//  UIImage+Extentions.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import UIKit

extension UIImage {
  func composited(withSmallCenterImage centerImage: UIImage) -> UIImage {
    UIGraphicsImageRenderer(size: self.size).image { context in
      let imageWidth = context.format.bounds.width
      let imageHeight = context.format.bounds.height
      let centerImageLength = imageWidth < imageHeight ? imageWidth / 5 : imageHeight / 5
      let centerImageRadius = centerImageLength * 0.2
      
      draw(in: CGRect(origin: CGPoint(x: 0, y: 0),
                      size: context.format.bounds.size))
      
      let centerImageRect = CGRect(x: (imageWidth - centerImageLength) / 2,
                                   y: (imageHeight - centerImageLength) / 2,
                                   width: centerImageLength,
                                   height: centerImageLength)
      
      let roundedRectPath = UIBezierPath(roundedRect: centerImageRect,
                                         cornerRadius: centerImageRadius)
      roundedRectPath.addClip()
      
      centerImage.draw(in: centerImageRect)
    }
  }
}
