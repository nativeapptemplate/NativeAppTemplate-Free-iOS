//
//  QRCodeGenerator.swift
//  NativeAppTemplate
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

        if let centerImage {
            return UIImage(cgImage: cgImage).composited(withSmallCenterImage: centerImage)
        } else {
            return UIImage(cgImage: cgImage)
        }
    }

    func generateWithCenterText(inputText: String, scale: CGFloat = 2, centerText: String) -> UIImage? {
        if let centerImage = centerText.image(
            withAttributes: [
                .font: UIFont.systemFont(ofSize: 40.0),
                .backgroundColor: UIColor(Color.arrowBackground)
            ]
        ) {
            generate(inputText: inputText, scale: scale, centerImage: centerImage)
        } else {
            generate(inputText: inputText, scale: scale, centerImage: nil)
        }
    }
}
