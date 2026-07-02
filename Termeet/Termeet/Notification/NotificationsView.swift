//
//  NotificationsView.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 02.07.2026.
//

import SwiftUI
import Combine

private enum Constants {
    enum Colors {
        static let background = Color.white
    }
    static let chipSpacing: CGFloat = 8
    static let chipHorizontalPadding: CGFloat = 16
    static let chipVerticalPadding: CGFloat = 8
    static let chipBorderWidth: CGFloat = 1
    static let topPadding: CGFloat = 8
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 16
    static let sectionTopPadding: CGFloat = 8
    static let emptySpacing: CGFloat = 12
    static let emptyImageMaxWidth: CGFloat = 319
    static let emptyImageMaxHeight: CGFloat = 299
    static let emptyTextHorizontalPadding: CGFloat = 40
}

struct NotificationsView: View {
    @StateObject private var viewModel: NotificationsViewModel
    @EnvironmentObject private var router: Router
    // Получаем сервис из Environment
    @EnvironmentObject private var toastService: ToastOverlayService

    init(viewModel: NotificationsViewModel = NotificationsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.notifications.isEmpty {
                EmptyNotificationsStateView()
            } else {
                NotificationsFilterChipsView(selectedFilter: $viewModel.selectedFilter)
                    .padding(.horizontal, Constants.horizontalPadding)
                    .padding(.top, Constants.topPadding)

                List {
                    ForEach(viewModel.groupedNotifications, id: \.date) { section in
                        Section(header: sectionHeader(for: section.date)) {
                            ForEach(section.events) { item in
                                NotificationRowView(
                                    model: item,
                                    onDelete: {
                                        viewModel.removeNotification(with: item.id)
                                    },
                                    onTap: {
                                        router.navigate(to: NotificationRoute.notificationDetail(notification: item))
                                    }
                                )
                                .listRowInsets(EdgeInsets(top: 4, leading: Constants.horizontalPadding, bottom: 4, trailing: Constants.horizontalPadding))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Constants.Colors.background)
            }
        }
        .background(Constants.Colors.background)
        .navigationTitle(NotificationsLocalization.title)
        .navigationBarTitleDisplayMode(.inline)
        // При появлении экрана вкладываем сервис в ViewModel
        .onAppear {
            viewModel.inject(toastService: toastService)
        }
    }

    @ViewBuilder
    private func sectionHeader(for date: Date) -> some View {
        HStack(alignment: .center) {
            Text(viewModel.sectionTitle(for: date))
                .font(AppFonts.headline.bold())
                .foregroundColor(AppColors.grayMainText)

            Spacer()

            if Calendar.current.isDateInToday(date) {
                Button(action: {
                    viewModel.clearAllNotifications()
                }) {
                    Image(systemName: "trash")
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.grayMainText)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.top, Constants.sectionTopPadding)
    }
}

// MARK: - Фильтры
struct NotificationsFilterChipsView: View {
    @Binding var selectedFilter: NotificationFilter

    var body: some View {
        HStack(spacing: Constants.chipSpacing) {
            ForEach(NotificationFilter.allCases, id: \.self) { filter in
                let isSelected = selectedFilter == filter
                let titleKey = LocalizedStringKey(filter.localizedKey)

                Button(action: { selectedFilter = filter }) {
                    Text(titleKey)
                        .font(AppFonts.subheadline)
                        .padding(.horizontal, Constants.chipHorizontalPadding)
                        .padding(.vertical, Constants.chipVerticalPadding)
                        .background(Capsule().fill(Color.clear))
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

// MARK: - Строка уведомления
struct NotificationRowView: View {
    let model: NotificationItem
    let onDelete: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.title)
                    .font(AppFonts.headline.bold())
                    .foregroundColor(AppColors.grayMainText)
                    .lineLimit(2)

                Text(model.subtitle)
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.graySecondaryIcons)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(model.date.formatted(date: .omitted, time: .shortened))
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.graySecondaryIcons)

                if !model.isRead {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(AppColors.accentInputsNavigation)
        .cornerRadius(16)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
        }
    }
}

// MARK: - Пустое состояние
struct EmptyNotificationsStateView: View {
    var body: some View {
        VStack(spacing: Constants.emptySpacing) {
            Image("noNotifications")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: Constants.emptyImageMaxWidth, maxHeight: Constants.emptyImageMaxHeight)

            Text(NotificationsLocalization.emptyTitle)
                .font(AppFonts.title2.bold())
                .foregroundColor(AppColors.grayMainText)

            Text(NotificationsLocalization.emptyMessage)
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

// MARK: - Детальный экран
struct NotificationDetailView: View {
    let notification: NotificationItem
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(notification.title)
                .font(AppFonts.largeTitle)
                .foregroundColor(AppColors.grayMainText)

            Text(notification.subtitle)
                .font(AppFonts.body)
                .foregroundColor(AppColors.graySecondaryIcons)

            Spacer()

            Button(action: {
                router.pop()
            }) {
                Text(LocalizedStringKey(NotificationsLocalization.backButton))
                    .font(AppFonts.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.brandMain)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .navigationTitle(LocalizedStringKey(NotificationsLocalization.detailTitle))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews
struct NotificationsPreviewContainer: View {
    let viewModel: NotificationsViewModel
    @StateObject private var router = Router()
    @StateObject private var toastService = ToastOverlayService()

    var body: some View {
        RouterView(router: router) {
            NotificationsView(viewModel: viewModel)
                .environmentObject(toastService)
        }
        .environmentObject(router)
    }
}

struct NotificationsEmptyPreviewContainer: View {
    @StateObject private var router = Router()
    @StateObject private var toastService = ToastOverlayService()

    var body: some View {
        RouterView(router: router) {
            NotificationsView(viewModel: NotificationsViewModel(notifications: []))
                .environmentObject(toastService)
        }
        .environmentObject(router)
    }
}

struct TabBarPreviewContainer: View {
    let viewModel: NotificationsViewModel
    @StateObject private var router = Router()
    @StateObject private var toastService = ToastOverlayService()
    @State private var selectedTab: Tab = .notifications

    var body: some View {
        RouterView(router: router) {
            ZStack(alignment: .bottom) {
                NotificationsView(viewModel: viewModel)
                    .environmentObject(toastService)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                TabBar(selected: $selectedTab)
                    .environmentObject(toastService)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(Color.white)
        }
        .environmentObject(router)
    }
}

#Preview("Notifications View") {
    let now = Date()
    let mockNotifications = [
        NotificationItem(
            title: "Время для «Название» назначено",
            subtitle: "Опрос «Название» завершен. Пользователь Иванов Иван выбрал итоговое время вашей встречи. Перейдите в календарь, чтобы посмотреть",
            date: Calendar.current.date(bySettingHour: 12, minute: 19, second: 0, of: now) ?? now,
            isRead: false
        ),
        NotificationItem(
            title: "Время для «Название» назначено",
            subtitle: "Опрос «Название» завершен. Пользователь Иванов Иван выбрал итоговое время вашей встречи. Перейдите в календарь, чтобы посмотреть",
            date: Calendar.current.date(bySettingHour: 12, minute: 19, second: 0, of: now) ?? now,
            isRead: true
        ),
        NotificationItem(
            title: "Время для «Название» назначено",
            subtitle: "Опрос «Название» завершен. Пользователь Иванов Иван выбрал итоговое время вашей встречи. Перейдите в календарь, чтобы посмотреть",
            date: Calendar.current.date(byAdding: .day, value: -2, to: now) ?? now,
            isRead: false
        )
    ]
    let viewModel = NotificationsViewModel(notifications: mockNotifications)
    return NotificationsPreviewContainer(viewModel: viewModel)
}

#Preview("Empty State") {
    return NotificationsEmptyPreviewContainer()
}

#Preview("With TabBar") {
    let now = Date()
    let mockNotifications = [
        NotificationItem(
            title: "Время для «Название» назначено",
            subtitle: "Опрос «Название» завершен. Пользователь Иванов Иван выбрал итоговое время вашей встречи. Перейдите в календарь, чтобы посмотреть",
            date: Calendar.current.date(bySettingHour: 12, minute: 19, second: 0, of: now) ?? now,
            isRead: false
        ),
        NotificationItem(
            title: "Время для «Название» назначено",
            subtitle: "Опрос «Название» завершен. Пользователь Иванов Иван выбрал итоговое время вашей встречи. Перейдите в календарь, чтобы посмотреть",
            date: Calendar.current.date(bySettingHour: 12, minute: 19, second: 0, of: now) ?? now,
            isRead: true
        ),
        NotificationItem(
            title: "Время для «Название» назначено",
            subtitle: "Опрос «Название» завершен. Пользователь Иванов Иван выбрал итоговое время вашей встречи. Перейдите в календарь, чтобы посмотреть",
            date: Calendar.current.date(byAdding: .day, value: -2, to: now) ?? now,
            isRead: false
        )
    ]
    let viewModel = NotificationsViewModel(notifications: mockNotifications)
    return TabBarPreviewContainer(viewModel: viewModel)
}
