//
//  TermeetApp.swift
//  Termeet
//
//  Created by Владимир Мацнев on 30.04.2025.
//

import SwiftUI

@main
struct TermeetApp: App {
    var body: some Scene {
        WindowGroup {
            // Теперь RootView сам управляет и Router, и ToastManager'ом
            RootView()
        }
    }
}
