//
//  RootView.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 03.05.2025.
//

import SwiftUI

private enum Constants {
    static let icons: [RootView.Icon] = [
        .init(
            id: .meets,
            normalImage: "meetsTabButton",
            selectedImage: "meetsTabButtonSelected"
        ),
        .init(
            id: .teams,
            normalImage: "teamsTabButton",
            selectedImage: "teamsTabButtonSelected"
        ),
        .init(
            id: .createMeet,
            normalImage: "createMeetTabButton",
            selectedImage: "createMeetTabButtonSelected"
        ),
        .init(
            id: .notifications,
            normalImage: "notificationTabButton",
            selectedImage: "notificationTabButtonSelected"
        ),
        .init(
            id: .profile,
            normalImage: "profileTabButton",
            selectedImage: "profileTabButtonSelected"
        )
    ]

    enum Size {
        static let heightImageTabBar: CGFloat = 40
        static let widthImageTabBar: CGFloat = 40
        static let heightTabBar: CGFloat = 84
    }

    enum Colors {
        static let backgroundTabBar = Color(light: .init(hex: 0xFFFFFF), dark: .init(hex: 0xFFFFFF))
    }
}

struct RootView: View {
    enum Tab: Int {
        case meets, teams, createMeet, notifications, profile
    }

    struct Icon: Identifiable {
        let id: Tab
        let normalImage: String
        let selectedImage: String
    }

    @State var selectedTab: Tab = .profile

    var body: some View {
        VStack(spacing: 0) {
            tabContent(selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            TabBar(
                selected: $selectedTab,
                items: Constants.icons
            ) { item in
                Image(selectedTab != item.id ? item.normalImage : item.selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        maxWidth: Constants.Size.heightImageTabBar,
                        maxHeight: Constants.Size.widthImageTabBar
                    )
            } background: {
                Constants.Colors.backgroundTabBar
            }
            .frame(maxHeight: Constants.Size.heightTabBar)
            .edgesIgnoringSafeArea(.bottom)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }

}

private extension RootView {
    @ViewBuilder func tabContent(_ selectedTab: Tab) -> some View {
        switch selectedTab {
        case .createMeet: Text("Create Meet")
        case .meets: Text("Meets")
        case .notifications: Text("Notifications")
        case .profile: Text("Profile")
        case .teams: Text("Teams")
        }
    }
}
