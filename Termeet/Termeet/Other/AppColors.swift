//
//  AppColors.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 30.06.2026.
//

import SwiftUI

enum AppColors {
    // Gray Palette
    static let grayMainText = Color(
        light: Color(hex: 0x2F2F2F),
        dark: Color(hex: 0x2F2F2F)
    )

    static let graySecondaryIcons = Color(
        light: Color(hex: 0x959595),
        dark: Color(hex: 0x959595)
    )

    // Accent Palette (Backgrounds, dividers, navigation, and dark accent)
    static let accentSecondaryBackground = Color(
        light: Color(hex: 0xA8A8A8),
        dark: Color(hex: 0xA8A8A8)
    )

    static let accentDividersOutlines = Color(
        light: Color(hex: 0xE4E4E4),
        dark: Color(hex: 0xE4E4E4)
    )

    static let accentInputsNavigation = Color(
        light: Color(hex: 0xF8F8F8),
        dark: Color(hex: 0xF8F8F8)
    )

    static let accentDark = Color(
        light: Color(hex: 0x191925),
        dark: Color(hex: 0x191925)
    )

    // Brand Palette
    static let brandMain = Color(
        light: Color(hex: 0x102F55),
        dark: Color(hex: 0x102F55)
    )

    static let brandSecondary = Color(
        light: Color(hex: 0xDAE2EE),
        dark: Color(hex: 0xDAE2EE)
    )

    // Semantic Palette (Success, Alert, Warning)
    // Hex codes are transcribed exactly as they appear in the provided image
    static let success = Color(
        light: Color(hex: 0x191925),
        dark: Color(hex: 0x191925)
    )

    static let alert = Color(
        light: Color(hex: 0x102F55),
        dark: Color(hex: 0x102F55)
    )

    static let warning = Color(
        light: Color(hex: 0xDAE2EE),
        dark: Color(hex: 0xDAE2EE)
    )
}
