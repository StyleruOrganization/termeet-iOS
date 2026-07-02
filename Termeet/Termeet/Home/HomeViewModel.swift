//
//  HomeViewModel.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 30.06.2026.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var selectedRole: EventRole?
    @Published var events: [Event] = []

    var filteredEvents: [Event] {
        if let role = selectedRole {
            return events.filter { $0.role == role }
        } else {
            return events
        }
    }

    var groupedEvents: [(date: Date, events: [Event])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEvents) { event in
            calendar.startOfDay(for: event.startDate)
        }
        return grouped.map { (date: $0.key, events: $0.value) }
                     .sorted { $0.date < $1.date }
    }

    func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return NSLocalizedString("home.section.today", comment: "")
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: date)
    }
}
