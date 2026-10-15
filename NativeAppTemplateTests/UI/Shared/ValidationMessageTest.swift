//
//  ValidationMessageTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import SwiftUI
import Testing
import UIKit

/// A validation message hidden with `.clear` alone was still an accessibility
/// element, so VoiceOver read "Name is required." on a valid form.
/// `validationMessage(isShown:)` must keep it out of the accessibility tree
/// until it is shown.
@MainActor
struct ValidationMessageTest {
    // Both strings are made up for the test; the sibling label proves the walk
    // below reaches SwiftUI's accessibility elements at all.
    private let siblingLabel = "Sibling label"
    private let messageText = "Name is required."

    @Test
    func hiddenMessageIsNotAnAccessibilityElement() throws {
        let labels = try accessibilityLabels(isShown: false)

        #expect(labels.contains(siblingLabel))
        #expect(!labels.contains(messageText))
    }

    @Test
    func shownMessageIsAnAccessibilityElement() throws {
        let labels = try accessibilityLabels(isShown: true)

        #expect(labels.contains(siblingLabel))
        #expect(labels.contains(messageText))
    }

    // MARK: - Helpers

    /// Hosts the message next to a visible text in a window, lays it out and
    /// returns the labels of every accessibility element VoiceOver could reach.
    private func accessibilityLabels(isShown: Bool) throws -> [String] {
        try Self.setAccessibilityEnabled(true)
        defer { try? Self.setAccessibilityEnabled(false) }
        let view = VStack {
            Text(siblingLabel)
            Text(messageText)
                .validationMessage(isShown: isShown)
        }
        let controller = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        defer { window.isHidden = true }
        // Let SwiftUI publish the accessibility tree after the update.
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        var labels: [String] = []
        collectLabels(from: controller.view, into: &labels)
        return labels
    }

    /// SwiftUI builds its accessibility elements only while an assistive
    /// technology is on, so the test turns accessibility on for this process
    /// the way XCUITest and VoiceOver do (libAccessibility, part of iOS).
    private static func setAccessibilityEnabled(_ enabled: Bool) throws {
        let handle = try #require(dlopen("/usr/lib/libAccessibility.dylib", RTLD_NOW))
        let symbol = try #require(dlsym(handle, "_AXSApplicationAccessibilitySetEnabled"))
        typealias SetEnabled = @convention(c) (Bool) -> Void
        unsafeBitCast(symbol, to: SetEnabled.self)(enabled)
    }

    private func collectLabels(from element: NSObject, into labels: inout [String]) {
        if element.isAccessibilityElement, let label = element.accessibilityLabel, !label.isEmpty {
            labels.append(label)
        }
        let children: [NSObject] = if let elements = element.accessibilityElements as? [NSObject] {
            elements
        } else if let view = element as? UIView {
            view.subviews
        } else {
            []
        }
        for child in children {
            collectLabels(from: child, into: &labels)
        }
    }
}
