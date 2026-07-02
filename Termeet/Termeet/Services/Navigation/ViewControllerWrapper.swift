//
//  ViewControllerWrapper.swift
//  CameraControl
//
//  Created by Daniil Sukhanov on 29.11.2025.
//

import UIKit
import SwiftUI

struct ViewControllerWrapper<VC: UIViewController>: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: VC, context: Context) {
    }

    private let makeViewController: () -> VC

    init(_ makeViewController: @escaping () -> VC) {
        self.makeViewController = makeViewController
    }

    func makeUIViewController(context: Context) -> VC {
        let viewController = makeViewController()
        return viewController
    }
}
