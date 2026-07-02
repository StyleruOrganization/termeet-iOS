//
//  HomeView.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 29.06.2026.
//

import SwiftUI

// MARK: - Constants
private enum Constants {
    enum Colors {
        static let background = Color.white
    }
    // Filter chips
    static let chipSpacing: CGFloat = 8
    static let chipHorizontalPadding: CGFloat = 16
    static let chipVerticalPadding: CGFloat = 8
    static let chipBorderWidth: CGFloat = 1
    // Layout
    static let topPadding: CGFloat = 8
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 16
    static let sectionTopPadding: CGFloat = 8
    // Empty state
    static let emptySpacing: CGFloat = 12
    static let emptyImageMaxWidth: CGFloat = 319
    static let emptyImageMaxHeight: CGFloat = 299
    static let emptyTextHorizontalPadding: CGFloat = 40
}

// MARK: - HomeView
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.filteredEvents.isEmpty {
                EmptyStateView()
            } else {
                FilterChipsView(selectedRole: $viewModel.selectedRole)
                    .padding(.horizontal, Constants.horizontalPadding)
                    .padding(.top, Constants.topPadding)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: Constants.verticalPadding) {
                        ForEach(viewModel.groupedEvents, id: \.date) { section in
                            Section(header: sectionHeader(for: section.date)) {
                                ForEach(section.events) { event in
                                    EventHomeShortView(
                                        model: EventHomeShortModel(
                                            title: event.title,
                                            startDate: event.startDate,
                                            endDate: event.endDate
                                        )
                                    )
                                    .padding(.horizontal, Constants.horizontalPadding)
                                }
                            }
                        }
                    }
                    .padding(.vertical, Constants.verticalPadding)
                }
            }
        }
        .background(Constants.Colors.background)
        .navigationTitle(HomeLocalization.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func sectionHeader(for date: Date) -> some View {
        Text(viewModel.sectionTitle(for: date))
            .font(AppFonts.headline.bold())
            .foregroundColor(AppColors.grayMainText)
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.sectionTopPadding)
    }
}

// MARK: - Filter Chips
struct FilterChipsView: View {
    @Binding var selectedRole: EventRole?

    private let allRoles: [EventRole?] = [nil] + EventRole.allCases

    var body: some View {
        HStack(spacing: Constants.chipSpacing) {
            ForEach(allRoles, id: \.self) { role in
                let keyString = role?.localizedKey ?? HomeLocalization.filterAll
                let titleKey = LocalizedStringKey(keyString)
                let isSelected = (role == nil && selectedRole == nil) || role == selectedRole

                Button(action: { selectedRole = role }) {
                    Text(titleKey)
                        .font(AppFonts.subheadline)
                        .padding(.horizontal, Constants.chipHorizontalPadding)
                        .padding(.vertical, Constants.chipVerticalPadding)
                        .background(
                            Capsule()
                                .fill(Color.clear)
                        )
                        .foregroundColor(AppColors.grayMainText)
                        .overlay(
                            Capsule()
                                .stroke(
                                    isSelected ? AppColors.grayMainText : AppColors.accentDividersOutlines,
                                    lineWidth: Constants.chipBorderWidth
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: Constants.emptySpacing) {
            Image("noEvents")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: Constants.emptyImageMaxWidth, maxHeight: Constants.emptyImageMaxHeight)
            Text(HomeLocalization.emptyTitle)
                .font(AppFonts.title2.bold())
                .foregroundColor(AppColors.grayMainText)

            Text(HomeLocalization.emptyMessage)
                .font(AppFonts.body)
                .foregroundColor(AppColors.graySecondaryIcons)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.emptyTextHorizontalPadding)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Mock Data
struct MockData {
    static let now = Date()
    static let calendar = Calendar.current

    static var events: [Event] {
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)!

        return [
            Event(
                title: "Weekly",
                startDate: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: today)!,
                endDate: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today)!,
                role: .participant
            ),
            Event(
                title: "Стилеру",
                startDate: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today)!,
                endDate: calendar.date(bySettingHour: 21, minute: 30, second: 0, of: today)!,
                role: .creator
            ),
            Event(
                title: "Стилеру",
                startDate: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: tomorrow)!,
                endDate: calendar.date(bySettingHour: 21, minute: 30, second: 0, of: tomorrow)!,
                role: .creator
            ),
            Event(
                title: "Weekly",
                startDate: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: tomorrow)!,
                endDate: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: tomorrow)!,
                role: .participant
            ),
            Event(
                title: "Weekly",
                startDate: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: dayAfterTomorrow)!,
                endDate: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: dayAfterTomorrow)!,
                role: .participant
            )
        ]
    }
}

// MARK: - Previews
#Preview("События") {
    NavigationView {
        let viewModel = HomeViewModel()
        viewModel.events = MockData.events
        return HomeView(viewModel: viewModel)
    }
}

#Preview("Пустое состояние") {
    NavigationView {
        let viewModel = HomeViewModel()
        viewModel.events = []
        return HomeView(viewModel: viewModel)
    }
}

// Для инжекции ViewModel в Preview
extension HomeView {
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}
