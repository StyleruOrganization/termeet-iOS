//
//  EventHomeShortView.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 29.06.2026.
//

import SwiftUI

private enum Constants {
    enum Colors {
        static let background = Color(light: .init(hex: 0xF8F8F8), dark: .init(hex: 0xF8F8F8))
    }
}

struct EventHomeShortModel {
    let title: String
    let startDate: Date
    let endDate: Date
}

struct EventHomeShortView: View {
    let model: EventHomeShortModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(model.title)
                .font(AppFonts.headline.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
            let timeStart = model.startDate.formatted(date: .omitted, time: .shortened)
            let timeEnd = model.endDate.formatted(date: .omitted, time: .shortened)
            Text("\(timeStart) – \(timeEnd)")
                .font(AppFonts.subheadline)
        }
        .padding()
        .background(Constants.Colors.background)
        .cornerRadius(16)

    }
}

#Preview {
    let now = Date()
    let model = EventHomeShortModel(
        title: "Weekly",
        startDate: now,
        endDate: now.addingTimeInterval(3600)
    )
    return EventHomeShortView(model: model)
}
