//
//  NotificationRoute.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 02.07.2026.
//

import SwiftUI
import UIKit

enum NotificationRoute: Routable {
    case notifications
    case notificationDetail(notification: NotificationItem)

    func makeViewController() -> UIViewController {
        switch self {
        case .notifications:
            return NotificationsView().convertToViewController()
        case .notificationDetail(let notification):
            return NotificationDetailView(notification: notification).convertToViewController()
        }
    }
}
