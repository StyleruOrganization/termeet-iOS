//
//  RootView.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 03.05.2025.
//

import SwiftUI

struct RootView: View {
    @State var selectedTab: Tab = .profile
    @StateObject private var toastService = ToastOverlayService()

    var body: some View {
        VStack(spacing: 0) {
            tabContent(selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBar(selected: $selectedTab)
                .padding(.leading, 32)
                .padding(.trailing, 32)
                .padding(.bottom, 50)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .environmentObject(toastService)
    }
}

// MARK: - Tab Content
private extension RootView {
    @ViewBuilder func tabContent(_ selectedTab: Tab) -> some View {
        switch selectedTab {
        case .createMeet: Text("Create Meet")
        case .meets: Text("Meets")
        case .notifications: NotificationsView() // Чистый вызов без параметров
        case .profile: Text("Profile")
        case .teams: Text("Teams")
        }
    }
}
