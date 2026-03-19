//
//  UIApplication+DismissKeyboard.swift
//  NativeAppTemplate
//

import UIKit

extension UIApplication {
    static func dismissKeyboard() {
        shared.dismissKeyboard()
    }

    private func dismissKeyboard() {
        sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
