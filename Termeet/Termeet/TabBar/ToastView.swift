//
//  ToastView.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 02.07.2026.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let onUndo: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Text(message)
                .font(AppFonts.body)
                .foregroundColor(AppColors.grayMainText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer()

            Button(action: {
                onUndo()
                onDismiss()
            }) {
                Image(systemName: "arrow.uturn.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.grayMainText)
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(uiColor: .systemGray6), Color(uiColor: .systemGray4)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}
