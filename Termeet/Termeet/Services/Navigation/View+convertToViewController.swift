//
//  View+convertToViewController.swift
//  CameraControl
//
//  Created by Daniil Sukhanov on 29.01.2026.
//

import SwiftUI
import UIKit

extension View {
    func convertToViewController() -> UIViewController {
        let hostingController = UIHostingController(rootView: self)
        hostingController.view.backgroundColor = .clear
        
        return hostingController
    }
}
