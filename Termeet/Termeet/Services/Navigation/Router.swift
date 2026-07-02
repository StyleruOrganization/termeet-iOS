//
//  Router.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 29.11.2026.
//

import SwiftUI
import UIKit
import OSLog
import Combine

private enum Constants {
    static let navigationDebounceInterval: TimeInterval = 0.5
    static let loggerCategory = "Routing"
}

protocol Routable {
    func makeViewController() -> UIViewController
}

struct RouterContainer: Hashable, Identifiable {
    let viewController: UIViewController
    private let identifier = UUID()

    var id: UUID { identifier }

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    static func == (lhs: RouterContainer, rhs: RouterContainer) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@MainActor
final class Router: NSObject, ObservableObject, UINavigationControllerDelegate {

    enum PresentType {
        case sheet, fullScreen
    }

    @Published private(set) var containers = [RouterContainer]()
    @Published private(set) var presentedSheetContainer: RouterContainer?
    @Published private(set) var fullScreenCoverContainer: RouterContainer?

    private(set) var onDismissPresentedSheet: (() -> Void)?
    private(set) var onDismissFullScreenCover: (() -> Void)?

    private var isNavigating = false
    private let id = UUID()
    private let logger: Logger

    private weak var navigationController: UINavigationController?
    private var navigationContainersByVCID: [ObjectIdentifier: RouterContainer] = [:]

    override init() {
        logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "Unknown",
            category: "\(Constants.loggerCategory):\(UUID().uuidString)"
        )
        super.init()
        logger.info("Initialized router")
    }

    deinit {
        logger.info("Deinitialized router")
    }

    var bindingNavigationStack: Binding<[RouterContainer]> {
        .init(
            get: { [weak self] in
                self?.containers ?? []
            },
            set: { [weak self] value in
                guard let self else { return }
                self.containers = value
                self.logger.debug("Navigation stack manually set to \(value.count) containers")
                self.syncNavigationController(animated: true)
            }
        )
    }

    var bindingPresentedSheetContainer: Binding<RouterContainer?> {
        .init(
            get: { [weak self] in
                self?.presentedSheetContainer
            },
            set: { [weak self] value in
                guard let self else { return }
                self.presentedSheetContainer = value
                self.logger.info("presentedSheetContainer changed: \(String(describing: value))")
            }
        )
    }

    var bindingFullScreenCoverContainer: Binding<RouterContainer?> {
        .init(
            get: { [weak self] in
                self?.fullScreenCoverContainer
            },
            set: { [weak self] value in
                guard let self else { return }
                self.fullScreenCoverContainer = value
                self.logger.info("fullScreenCoverContainer changed: \(String(describing: value))")
            }
        )
    }

    func attachNavigationController(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController?.delegate = self
        logger.info("Attached UINavigationController")

        syncNavigationController(animated: false)
    }

    func detachNavigationController() {
        if navigationController?.delegate === self {
            navigationController?.delegate = nil
        }
        navigationController = nil
        logger.info("Detached UINavigationController")
    }

    private func registerNavigationContainer(_ container: RouterContainer) {
        let key = ObjectIdentifier(container.viewController)
        navigationContainersByVCID[key] = container
    }

    private func container(for viewController: UIViewController) -> RouterContainer {
        let key = ObjectIdentifier(viewController)

        if let existing = navigationContainersByVCID[key] {
            return existing
        }

        let container = RouterContainer(viewController: viewController)
        navigationContainersByVCID[key] = container
        return container
    }

    private func pruneNavigationContainerCache(keeping currentStack: [UIViewController]) {
        let keptIDs = Set(currentStack.map { ObjectIdentifier($0) })
        navigationContainersByVCID = navigationContainersByVCID.filter { keptIDs.contains($0.key) }
    }

    private func applyContainersFromNavigationController(
        _ newContainers: [RouterContainer],
        keeping currentStack: [UIViewController]
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            if self.containers != newContainers {
                self.containers = newContainers
                self.logger.info("UINavigationController stack updated. Router stack size now \(self.containers.count)")
            }

            self.pruneNavigationContainerCache(keeping: currentStack)
        }
    }

    fileprivate func syncNavigationController(animated: Bool) {
        guard let navigationController else { return }

        let currentStack = navigationController.viewControllers
        guard let root = currentStack.first else { return }

        let desiredStack: [UIViewController] = [root] + containers.map(\.viewController)

        if currentStack.count == desiredStack.count,
           zip(currentStack, desiredStack).allSatisfy({ $0 === $1 }) {
            pruneNavigationContainerCache(keeping: currentStack)
            return
        }

        if desiredStack.count == currentStack.count + 1,
           currentStack.elementsEqual(desiredStack.dropLast(), by: ===),
           let last = desiredStack.last {
            navigationController.pushViewController(last, animated: animated)
            pruneNavigationContainerCache(keeping: navigationController.viewControllers)
            return
        }

        if desiredStack.count + 1 == currentStack.count,
           desiredStack.elementsEqual(currentStack.dropLast(), by: ===) {
            navigationController.popViewController(animated: animated)
            pruneNavigationContainerCache(keeping: navigationController.viewControllers)
            return
        }

        navigationController.setViewControllers(desiredStack, animated: animated)
        pruneNavigationContainerCache(keeping: navigationController.viewControllers)
    }

    func navigate(to route: Routable, isDoubleTapProtectionEnabled: Bool = true) {
        logger.debug("navigate(to:) called; protectionEnabled=\(isDoubleTapProtectionEnabled)")

        if isDoubleTapProtectionEnabled {
            guard !isNavigating else {
                logger.error("navigate(to:) blocked by debounce (isNavigating=true)")
                return
            }

            isNavigating = true
            logger.debug("Debounce activated for \(Constants.navigationDebounceInterval) seconds")

            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.navigationDebounceInterval) { [weak self] in
                Task { @MainActor in
                    self?.isNavigating = false
                    self?.logger.debug("Debounce expired; isNavigating=false")
                }
            }
        }

        let container = RouterContainer(viewController: route.makeViewController())
        registerNavigationContainer(container)
        containers.append(container)

        logger.info("Pushed new view controller. Stack size now \(self.containers.count)")
        syncNavigationController(animated: true)
    }

    func present(route: Routable, type: PresentType = .sheet, onDismiss: (() -> Void)? = nil) {
        let container = RouterContainer(viewController: route.makeViewController())

        switch type {
        case .sheet:
            presentedSheetContainer = container
            onDismissPresentedSheet = onDismiss
            logger.info("Presented sheet: \(container.id.uuidString)")
        case .fullScreen:
            fullScreenCoverContainer = container
            onDismissFullScreenCover = onDismiss
            logger.info("Presented fullScreen cover: \(container.id.uuidString)")
        }
    }

    func dismiss(type: PresentType = .sheet) {
        switch type {
        case .sheet:
            presentedSheetContainer = nil
            onDismissPresentedSheet = nil
            logger.info("Dismissed sheet")
        case .fullScreen:
            fullScreenCoverContainer = nil
            onDismissFullScreenCover = nil
            logger.info("Dismissed fullScreen cover")
        }
    }

    func pop() {
        guard !containers.isEmpty else {
            logger.error("pop() called on empty navigation stack")
            return
        }

        containers.removeLast()
        logger.info("Popped view controller. Stack size now \(self.containers.count)")
        syncNavigationController(animated: true)
    }

    func popToRoot() {
        containers.removeAll()
        logger.info("Popped to root")
        syncNavigationController(animated: true)
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let stack = navigationController.viewControllers

        guard !stack.isEmpty else {
            applyContainersFromNavigationController([], keeping: [])
            return
        }

        let newContainers = stack.dropFirst().map { container(for: $0) }
        applyContainersFromNavigationController(Array(newContainers), keeping: stack)
    }
}

struct RouterNavigationControllerHost<Content: View>: UIViewControllerRepresentable {
    @ObservedObject var router: Router
    let content: Content

    func makeUIViewController(context: Context) -> UINavigationController {
        let root = UIHostingController(rootView: content)
        let navigationController = UINavigationController(rootViewController: root)
        navigationController.delegate = router
        router.attachNavigationController(navigationController)
        return navigationController
    }

    func updateUIViewController(_ navigationController: UINavigationController, context: Context) {
        if let rootHosting = navigationController.viewControllers.first as? UIHostingController<Content> {
            rootHosting.rootView = content
        } else if navigationController.viewControllers.isEmpty {
            navigationController.viewControllers = [UIHostingController(rootView: content)]
        }

        router.attachNavigationController(navigationController)
        router.syncNavigationController(animated: false)
    }

    static func dismantleUIViewController(_ uiViewController: UINavigationController, coordinator: ()) {
        if let router = uiViewController.delegate as? Router {
            router.detachNavigationController()
        }
    }
}

extension View {
    func globalFullCoverScreen(router: Router) -> some View {
        fullScreenCover(
            item: router.bindingFullScreenCoverContainer,
            onDismiss: { router.onDismissFullScreenCover?() },
            content: { container in
                ViewControllerWrapper {
                    container.viewController
                }
            }
        )
    }

    func globalPresentedSheet(router: Router) -> some View {
        sheet(
            item: router.bindingPresentedSheetContainer,
            onDismiss: { router.onDismissPresentedSheet?() },
            content: { container in
                ViewControllerWrapper {
                    container.viewController
                }
            }
        )
    }
}

struct RouterView<Content: View>: View {
    @ObservedObject var router: Router
    private let content: Content

    init(router: Router, @ViewBuilder content: () -> Content) {
        self.router = router
        self.content = content()
    }

    var body: some View {
        RouterNavigationControllerHost(router: router, content: content)
            .globalPresentedSheet(router: router)
            .globalFullCoverScreen(router: router)
    }
}
