//
//  TabBar.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 01.05.2025.
//
import SwiftUI

// MARK: - Tab Enum
public enum Tab: Int, CaseIterable, Identifiable {
    case meets, teams, createMeet, notifications, profile
    public var id: Self { self }
}

// MARK: - TabBar Component
public struct TabBar: View {
    @Binding public var selected: Tab
    @EnvironmentObject private var toastService: ToastOverlayService

    private var animationSelect: Animation?

    private let iconMap: [Tab: (normal: String, selected: String)] = [
        .meets: ("meetsTabButton", "meetsTabButtonSelected"),
        .teams: ("teamsTabButton", "teamsTabButtonSelected"),
        .createMeet: ("createMeetTabButton", "createMeetTabButtonSelected"),
        .notifications: ("notificationTabButton", "notificationTabButtonSelected"),
        .profile: ("profileTabButton", "profileTabButtonSelected")
    ]

    public init(selected: Binding<Tab>) {
        self._selected = selected
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Основной таб-бар
            HStack(spacing: 0) {
                ForEach(Tab.allCases) { tab in
                    let iconNames = iconMap[tab] ?? (normal: "questionmark", selected: "questionmark")
                    let isSelected = selected == tab

                    Button {
                        withAnimation(animationSelect ?? .spring(response: 0.4, dampingFraction: 0.7)) {
                            selected = tab
                        }
                    } label: {
                        Image(isSelected ? iconNames.selected : iconNames.normal)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 40, maxHeight: 40)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 56)
            .padding(.horizontal, 16)
            .background(
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 4)
            )

            // 2. Плашка тоста (ровно над таб-баром, без копипаста)
            if toastService.isPresented {
                ToastView(
                    message: toastService.message,
                    onUndo: {
                        toastService.onUndo?()
                    },
                    onDismiss: {
                        toastService.dismiss()
                    }
                )
                .padding(.horizontal, 16)
                // Толкаем плашку вверх ровно на высоту таб-бара (56) + небольшой зазор (12)
                .padding(.bottom, 68)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
    }

    public func onAnimationSelect(_ animation: @escaping () -> Animation?) -> Self {
        var copy = self
        copy.animationSelect = animation()
        return copy
    }
}
