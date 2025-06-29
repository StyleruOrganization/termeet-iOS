import SwiftUI
import UIKit
import OSLog

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

final class Router: ObservableObject {
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

    init() {
        logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "Unknown",
            category: "\(Constants.loggerCategory):\(self.id)"
        )
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
                self?.containers = value
                self?.logger.debug("Navigation stack manually set to \("\(value.count)") containers")
            }
        )
    }

    var bindingPresentedSheetContainer: Binding<RouterContainer?> {
        .init(
            get: { [weak self] in
                self?.presentedSheetContainer
            },
            set: { [weak self] value in
                self?.presentedSheetContainer = value
                self?.logger.info("presentedSheetContainer changed: \(String(describing: value))")
            }
        )
    }

    var bindingFullScreenCoverContainer: Binding<RouterContainer?> {
        .init(
            get: { [weak self] in
                self?.fullScreenCoverContainer
            },
            set: { [weak self] value in
                self?.fullScreenCoverContainer = value
                self?.logger.info("fullScreenCoverContainer changed: \(String(describing: value))")
            }
        )
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
                self?.isNavigating = false
                self?.logger.debug("Debounce expired; isNavigating=false")
            }
        }

        let container = RouterContainer(viewController: route.makeViewController())
        containers.append(container)
        logger.info("Pushed new view controller. Stack size now \(self.containers.count)")
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
    }

    func popToRoot() {
        containers.removeAll()
        logger.info("Popped to root")
    }
}

extension View {
    func convertToViewController() -> UIViewController {
        UIHostingController(rootView: self)
    }
}

extension View {
    func globalNavigationDestination(router: Router) -> some View {
        let view = self
            .navigationDestination(for: RouterContainer.self) { container in
                ViewControllerWrapper {
                    container.viewController
                }
            }
        return view
    }

    func globalFullCoverScreen(router: Router) -> some View {
        let view = self
            .fullScreenCover(
                item: router.bindingFullScreenCoverContainer,
                onDismiss: { router.onDismissFullScreenCover?() },
                content: { container in ViewControllerWrapper { container.viewController } }
            )
        return view
    }

    func globalPresentedSheet(router: Router) -> some View {
        let view = self
            .sheet(
                item: router.bindingPresentedSheetContainer,
                onDismiss: { router.onDismissPresentedSheet?() },
                content: { container in ViewControllerWrapper { container.viewController } }
            )
        return view
    }
}

struct ViewControllerWrapper<VC: UIViewController>: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: VC, context: Context) {}

    private let makeViewController: () -> VC

    init(_ makeViewController: @escaping () -> VC) {
        self.makeViewController = makeViewController
    }

    func makeUIViewController(context: Context) -> VC {
        makeViewController()
    }
}
