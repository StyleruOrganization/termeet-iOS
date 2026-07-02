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

    // Храним текущий таймер, чтобы отменять его при новом вызове
    private var dismissWorkItem: DispatchWorkItem?

    func show(message: String, onUndo: @escaping () -> Void) {
        // 1. Отменяем предыдущий таймер, если он еще не сработал
        dismissWorkItem?.cancel()

        self.message = message
        self.onUndo = onUndo

        // 2. Показываем плашку, если она еще не показана
        if !isPresented {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isPresented = true
            }
        }

        // 3. Создаем новый таймер и сохраняем его
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            // Таймер сработал, скрываем плашку, если она до сих пор видна
            if self.isPresented {
                self.dismiss()
            }
        }
        self.dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: workItem)
    }

    func dismiss() {
        dismissWorkItem?.cancel() // Если кто-то вызвал dismiss вручную, таймер тоже отменяем
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isPresented = false
        }
        self.onUndo = nil
    }
}
