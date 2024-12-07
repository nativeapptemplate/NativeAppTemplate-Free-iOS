//
//  MailView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/11/12.
//

import AVFoundation
import Foundation
import MessageUI
import SwiftUI
import UIKit

struct MailView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentation
  @Binding var result: Result<MFMailComposeResult, Error>?
  var recipients = [String]()
  var subject = ""
  var messageBody = ""
  var isHTML = false
  
  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    @Binding var presentation: PresentationMode
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    init(presentation: Binding<PresentationMode>,
         result: Binding<Result<MFMailComposeResult, Error>?>) {
      _presentation = presentation
      _result = result
    }
    
    func mailComposeController(_: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
      defer {
        $presentation.wrappedValue.dismiss()
      }
      guard error == nil else {
        self.result = .failure(error!)
        return
      }
      self.result = .success(result)
      
      if result == .sent {
        AudioServicesPlayAlertSound(SystemSoundID(1001))
      }
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(presentation: presentation,
                result: $result)
  }
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
    let mfMailComposeViewController = MFMailComposeViewController()
    mfMailComposeViewController.setToRecipients(recipients)
    mfMailComposeViewController.setSubject(subject)
    mfMailComposeViewController.setMessageBody(messageBody, isHTML: isHTML)
    mfMailComposeViewController.mailComposeDelegate = context.coordinator
    return mfMailComposeViewController
  }
  
  func updateUIViewController(_: MFMailComposeViewController,
                              context _: UIViewControllerRepresentableContext<MailView>) {}
}
