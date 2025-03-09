//
//  ImageSaver.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import UIKit

class ImageSaver: NSObject {
  private var completion: (_ error: Error?) -> Void = { _ in }
  
  func save(image: UIImage, completion: @escaping (_ error: Error?) -> Void) {
    self.completion = completion
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }
  
  @objc
  private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    completion(error)
  }
}
