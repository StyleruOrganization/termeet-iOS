//
//  ToastOverlayService.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 02.07.2026.
//

import SwiftUI

final class ToastOverlayService: ObservableObject {
    @Published var isPresented = false
    @Published var message = ""
    var onUndo: (() -> Void)?

    func show(message: String, onUndo: @escaping () -> Void) {
        self.message = message
        self.onUndo = onUndo
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isPresented = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            guard let self = self else { return }
            if self.isPresented {
                self.dismiss()
            }
        }
    }

    func dismiss() {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isPresented = false
        }
        self.onUndo = nil
    }
}
