//
//  NotificationsViewModel.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 02.07.2026.
//

import Foundation
import SwiftUI

class NotificationsViewModel: ObservableObject {
    @Published var selectedFilter: NotificationFilter = .all
    @Published var notifications: [NotificationItem] = []

    init(notifications: [NotificationItem] = []) {
        self.notifications = notifications
    }

    var filteredNotifications: [NotificationItem] {
        switch selectedFilter {
        case .all:
            return notifications
        case .new:
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return notifications.filter { $0.date >= sevenDaysAgo }
        case .unread:
            return notifications.filter { !$0.isRead }
        }
    }

    var groupedNotifications: [(date: Date, events: [NotificationItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredNotifications) { item in
            calendar.startOfDay(for: item.date)
        }
        // Исправление: сортируем по убыванию даты, чтобы "Сегодня" была первой
        return grouped.map { (date: $0.key, events: $0.value) }
                      .sorted { $0.date > $1.date }
    }

    func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return NSLocalizedString(NotificationsLocalization.sectionToday, comment: "")
        }
        return NSLocalizedString(NotificationsLocalization.sectionEarlier, comment: "")
    }

    func removeNotification(with id: UUID) {
        notifications.removeAll { $0.id == id }
    }

    // Новая функция для кнопки "Очистить все"
    func clearAllNotifications() {
        notifications.removeAll()
    }
}
