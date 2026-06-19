//
//  PasswordRecoveryViewModel.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 16.05.2025.
//

import SwiftUI
import OSLog

private enum Constants {
    enum Texts {
        static let emailPlaceholder = "Введите почту"
        static let emailHeader = "Почта"
        static let emailFooter = "На эту почту будет отправлено письмо с восстановлением"
        static let invalidEmailFooter = "Почта некорректна"

        static let passwordPlaceholder = "Введите пароль"
        static let passwordHeader = "Новый пароль"
        static let passwordFooter = "Пароль должен содержать не менее 8 символов и состоять из цифр и латинских букв"
        static let repeatPasswordHeader = "Пароль повторно"
        static let mismatchedPasswords = "Пароли не совпадают"
        static let incorrectPasswordFooter = "Некорректный пароль. Пароль должен содержать не менее 8 символов" +
        "и состоять из цифр и латинских букв"

        static let confirmSendEmail = "Отправить письмо на почту"
        static let confirmResend = "Отправить повторно"
        static let confirmRestore = "Восстановить"
        static let returnToLogin = "Вернуться ко входу"
        static let resendAvailableIn = "Вы можете запросить повторно через"
    }
}

private class MockNetworkingService {
    func isCorrectEmail(_ email: String) -> Bool {
        email == "test@test.com"
    }
}

private enum ContainerUUIDs {
    enum InputEmail {
        static let email = UUID()
    }

    enum SendingLetter {}

    enum InputNewPassword {
        static let password = UUID()
        static let repeatPassword = UUID()
    }
}

final class PasswordRecoveryViewModel: ObservableObject {
    let stateView: PasswordRecoveryView.Route
    private var router: Router?
    private var tempTimer: Timer?
    private var repeatSendEmailTimer: Timer?

    init(stateView: PasswordRecoveryView.Route = .inputEmail) {
        self.stateView = stateView
        initContainers()
        initConfirmButton()
    }

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Unknown",
        category: String(describing: PasswordRecoveryViewModel.self)
    )
    private let networkingService = MockNetworkingService()
    @Published private(set) var containers = [UUID: Container]()
    @Published private(set) var confirmButtonConfiguration = ConfirmButtonConfiguration(title: "Test")

    func injectRouter(_ router: Router, isReplacing: Bool = false) {
        if self.router != nil && !isReplacing {
            return
        }
        self.router = router
    }

}

// MARK: Containers

extension PasswordRecoveryViewModel {
    struct Container {
        var text: String = ""
        var configuration: InputTextConfiguration
    }

    func binding(for id: UUID) -> Binding<String> {
        Binding(
            get: { self.containers[id]?.text ?? "" },
            set: { self.containers[id]?.text = $0 }
        )
    }

    func getContainer(for id: UUID) -> Container {
        guard let container = containers[id] else {
            logger.warning("Container not found for id: \(id)")
            return .init(configuration: .init())
        }
        return container
    }

    func getContainers() -> [(id: UUID, container: Container)] {
        let uuids = getContainerUUIDs()
        return uuids.map { uuid in
            (uuid, getContainer(for: uuid))
        }
    }

    private func getContainerUUIDs() -> [UUID] {
        return switch stateView {
        case .inputEmail:
            [ContainerUUIDs.InputEmail.email]
        case .sendingLetter:
            []
        case .inputNewPassword:
            [ContainerUUIDs.InputNewPassword.password, ContainerUUIDs.InputNewPassword.repeatPassword]
        }
    }

    private func initContainers() {
        switch stateView {
        case .inputEmail:
            containers[ContainerUUIDs.InputEmail.email] = .init(
                configuration: .init(
                    placeholder: Constants.Texts.emailPlaceholder,
                    headerText: Constants.Texts.emailHeader,
                    footerText: Constants.Texts.emailFooter,
                    isSecured: true,
                    onTextChange: {
                        self.checkEmail($0)
                        self.checkFillForms()
                    }
                )
            )
        case .inputNewPassword:
            containers[ContainerUUIDs.InputNewPassword.password] = .init(
                configuration: .init(
                    placeholder: Constants.Texts.passwordPlaceholder,
                    headerText: Constants.Texts.passwordHeader,
                    footerText: Constants.Texts.passwordFooter,
                    isSecured: true,
                    onEndEditing: { self.checkPassword() },
                    onTextChange: { _ in
                        self.checkFillForms()
                    }
                )
            )

            containers[ContainerUUIDs.InputNewPassword.repeatPassword] = .init(
                configuration: .init(
                    placeholder: Constants.Texts.passwordPlaceholder,
                    headerText: Constants.Texts.repeatPasswordHeader,
                    isSecured: true,
                    onEndEditing: { self.checkPassword() },
                    onTextChange: { _ in
                        self.checkFillForms()
                    }
                )
            )
        default:
            break
        }
    }
}

extension PasswordRecoveryViewModel {
    private func initConfirmButton() {
        switch stateView {
        case .inputEmail:
            confirmButtonConfiguration.update {
                $0.title = Constants.Texts.confirmSendEmail
                $0.isEnabled = false
                $0.footerTextButton = Constants.Texts.returnToLogin
                $0.action = { self.router?.navigate(to: PasswordRecoveryView.Route.sendingLetter) }
                $0.footerTextActionButton = { self.router?.popToRoot() }
            }
        case .sendingLetter:
            confirmButtonConfiguration.update {
                $0.title = Constants.Texts.confirmResend
                $0.isEnabled = false
                $0.footerTextButton = Constants.Texts.returnToLogin
                $0.action = { self.router?.navigate(to: PasswordRecoveryView.Route.inputNewPassword) }
                $0.footerTextActionButton = { self.router?.popToRoot() }
            }
        case .inputNewPassword:
            confirmButtonConfiguration.update {
                $0.title = Constants.Texts.confirmRestore
                $0.isEnabled = false
                $0.footerTextButton = Constants.Texts.returnToLogin
                $0.footerTextActionButton = { self.router?.popToRoot() }
            }
        }
    }
}

private extension PasswordRecoveryViewModel {
    func checkEmail(_ email: String) {
        if email == "123" {
            containers[ContainerUUIDs.InputEmail.email]?.configuration.update {
                $0.isErrored = true
                $0.footerText = Constants.Texts.invalidEmailFooter
            }
        } else {
            containers[ContainerUUIDs.InputEmail.email]?.configuration.update {
                $0.isErrored = false
                $0.footerText = Constants.Texts.emailFooter
            }
        }
    }

    func checkFillForms() {
        if containers.isEmpty {
            return
        }
        let isAllTextFill = containers.values.allSatisfy({ !$0.text.isEmpty })
        confirmButtonConfiguration.update {
            $0.isEnabled = isAllTextFill
        }
    }

    func checkPassword() {
        guard
            var containerPassword = containers[ContainerUUIDs.InputNewPassword.password],
            var containerRepeatPassword = containers[ContainerUUIDs.InputNewPassword.repeatPassword]
        else {
            return
        }

        if containerPassword.text == "123" {
            containerPassword.configuration.update {
                $0.isErrored = true
                $0.footerText = Constants.Texts.incorrectPasswordFooter
            }
            containers[ContainerUUIDs.InputNewPassword.password] = containerPassword
            return
        } else {
            containerPassword.configuration.update {
                $0.isErrored = false
                $0.footerText = Constants.Texts.passwordFooter
            }
        }
        if containerPassword.text != containerRepeatPassword.text {
            containerRepeatPassword.configuration.update {
                $0.isErrored = true
                $0.footerText = Constants.Texts.mismatchedPasswords
            }
        } else {
            containerRepeatPassword.configuration.update {
                $0.isErrored = false
                $0.footerText = nil
            }
        }

        containers[ContainerUUIDs.InputNewPassword.password] = containerPassword
        containers[ContainerUUIDs.InputNewPassword.repeatPassword] = containerRepeatPassword
    }
}

extension PasswordRecoveryViewModel {
    func startCheckingAnswerEmail() {
        if stateView != .sendingLetter || tempTimer != nil {
            return
        }
        tempTimer = .scheduledTimer(withTimeInterval: 5, repeats: false, block: { [weak self] timer in
            guard let self else {
                return
            }
            self.router?.navigate(to: PasswordRecoveryView.Route.inputNewPassword)
            timer.invalidate()
            self.tempTimer = nil
        })
        var counter = 0
        self.confirmButtonConfiguration.update {
            $0.headerText = "\(Constants.Texts.resendAvailableIn) 3:00"
            $0.isEnabled = false
        }

        repeatSendEmailTimer = .scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                return
            }
            if counter >= 180 {
                timer.invalidate()
                self.repeatSendEmailTimer = nil
                self.confirmButtonConfiguration.update {
                    $0.headerText = nil
                    $0.isEnabled = true
                }
            } else {
                let time = 180 - counter
                let minutes = time / 60
                let seconds = time % 60
                let secondsString = String(format: "%02d", seconds)
                self.confirmButtonConfiguration.update {
                    $0.headerText = "\(Constants.Texts.resendAvailableIn) \(minutes):\(secondsString)"
                    $0.isEnabled = false
                }
                counter += 1
            }
        }
    }

    func endCheckingAnswerEmail() {
        if stateView != .sendingLetter {
            return
        }
        tempTimer?.invalidate()
        tempTimer = nil
        repeatSendEmailTimer?.invalidate()
        repeatSendEmailTimer = nil
    }
}
