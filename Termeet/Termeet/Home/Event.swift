//
//  Event.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 30.06.2026.
//

import Foundation

enum EventRole: String, CaseIterable {
    case participant = "home.role.participant"
    case creator = "home.role.creator"

    var localizedKey: String {
        self.rawValue
    }
}

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let startDate: Date
    let endDate: Date
    let role: EventRole
}
