//
//  AccessibilityElements.swift
//  NativeAppTemplate
//

import SwiftUI
import Testing
import UIKit

/// What VoiceOver, XCUITest and WebDriverAgent can reach in a SwiftUI view
@MainActor
enum AccessibilityElements {
    struct Element {
        let label: String
        let traits: UIAccessibilityTraits
        /// In screen coordinates
        let frame: CGRect
    }

    /// Hosts `view` in a window, lays it out and returns every accessibility element
    /// with a label. `until` keeps letting SwiftUI publish, for up to 5 seconds, until the
    /// elements satisfy it: on a slow machine (CI) a TabView's tab bar comes after the first pass.
    static func of(
        _ view: some View,
        until isReady: ([Element]) -> Bool = { _ in true }
    ) throws -> [Element] {
        try beginAccessibility()
        defer { try? endAccessibility() }
        let controller = UIHostingController(rootView: view)
        // Tests run inside the app, so its window scene hosts the test window.
        let scene = try #require(
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        )
        let window = UIWindow(windowScene: scene)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        defer { window.isHidden = true }
        // Let SwiftUI publish the accessibility tree after the update.
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        var elements: [Element] = []
        collect(from: controller.view, into: &elements)
        let deadline = Date().addingTimeInterval(5)
        while !isReady(elements), Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.1))
            elements = []
            collect(from: controller.view, into: &elements)
        }
        return elements
    }

    /// Suites run in parallel, and the run loop below lets another test's call start
    /// and end in the middle of this one; accessibility stays on until the last ends.
    private static var accessibilityUsers = 0

    private static func beginAccessibility() throws {
        if accessibilityUsers == 0 {
            try setAccessibilityEnabled(true)
        }
        accessibilityUsers += 1
    }

    private static func endAccessibility() throws {
        accessibilityUsers -= 1
        if accessibilityUsers == 0 {
            try setAccessibilityEnabled(false)
        }
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

    private static func collect(from element: NSObject, into elements: inout [Element]) {
        if element.isAccessibilityElement, let label = element.accessibilityLabel, !label.isEmpty {
            elements.append(Element(
                label: label,
                traits: element.accessibilityTraits,
                frame: element.accessibilityFrame
            ))
        }
        let children: [NSObject] = if let accessibilityElements = element.accessibilityElements as? [NSObject] {
            accessibilityElements
        } else if let view = element as? UIView {
            view.subviews
        } else {
            []
        }
        for child in children {
            collect(from: child, into: &elements)
        }
    }
}
