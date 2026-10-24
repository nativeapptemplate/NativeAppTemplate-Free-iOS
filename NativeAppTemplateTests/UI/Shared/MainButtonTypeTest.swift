//
//  MainButtonTypeTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import SwiftUI
import Testing

/// Primary buttons are white text on a fill. Outlined only, as in the dark-only template, the
/// white text and outline vanished on the light screen ("Sign Up for an Account" on the
/// first screen)
struct MainButtonTypeTest {
    @Test(arguments: [MainButtonType.primary(withArrow: false), .primary(withArrow: true),
                      .coloredPrimary(withArrow: false)])
    func primaryButtonsAreFilled(type: MainButtonType) {
        #expect(type.fill == Color.primaryButtonBackground)
    }

    @Test(arguments: [MainButtonType.secondary(withArrow: false), .coloredSecondary(withArrow: false),
                      .destructive(withArrow: false)])
    func otherButtonsAreOutlinedOnly(type: MainButtonType) {
        #expect(type.fill == nil)
    }
}
