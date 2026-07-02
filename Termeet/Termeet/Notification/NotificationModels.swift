//
//  NotificationModels.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 02.07.2026.
//

import Foundation

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let date: Date
    let isRead: Bool
}

enum NotificationFilter: String, CaseIterable {
    case all
    case new
    case unread

    var localizedKey: String {
        switch self {
        case .all: return NotificationsLocalization.filterAll
        case .new: return NotificationsLocalization.filterNew
        case .unread: return NotificationsLocalization.filterUnread
        }
    }
}
