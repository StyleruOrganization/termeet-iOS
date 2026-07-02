//
//  View+convertToAnyView.swift
//  CameraControl
//
//  Created by Daniil Sukhanov on 29.01.2026.
//

import SwiftUI

extension View {
    func convertToAnyView() -> AnyView {
        AnyView(self)
    }
}
