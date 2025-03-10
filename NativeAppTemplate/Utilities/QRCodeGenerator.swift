//
//  QRCodeGenerator.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI

struct QRCodeGenerator {
  func generate(inputText: String, scale: CGFloat = 2, centerImage: UIImage?) -> UIImage? {
    guard let qrFilter = CIFilter(name: "CIQRCodeGenerator")
    else { return nil }
    
    let inputData = inputText.data(using: .utf8)
    qrFilter.setValue(inputData, forKey: "inputMessage")
    qrFilter.setValue("H", forKey: "inputCorrectionLevel")
    
    guard let ciImage = qrFilter.outputImage
    else { return nil }
    
    let sizeTransform = CGAffineTransform(scaleX: scale, y: scale)
    let scaledCiImage = ciImage.transformed(by: sizeTransform)
    
    let context = CIContext()
    guard let cgImage = context.createCGImage(scaledCiImage, from: scaledCiImage.extent)
    else { return nil }
    
    if let centerImage = centerImage {
      return UIImage(cgImage: cgImage).composited(withSmallCenterImage: centerImage)
    } else {
      return UIImage(cgImage: cgImage)
    }
  }
  
  func generateWithCenterText(inputText: String, scale: CGFloat = 2, centerText: String) -> UIImage? {
    if let centerImage = centerText.image(
      withAttributes: [
        .font: UIFont.systemFont(ofSize: 40.0),
        .backgroundColor: UIColor.white
      ]
    ) {
      return generate(inputText: inputText, scale: scale, centerImage: centerImage)
    } else {
      return generate(inputText: inputText, scale: scale, centerImage: nil)
    }
  }
}
