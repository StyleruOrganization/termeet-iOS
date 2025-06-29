import SwiftUI
import UIKit

private enum Constants {
    static let navigationDebounceInterval: TimeInterval = 0.5
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

    var bindingNavigationStack: Binding<[RouterContainer]> {
        .init(
            get: { [weak self] in
                self?.containers ?? []
            },
            set: { [weak self] value in
                self?.containers = value
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
            }
        )
    }

    func navigate(to route: Routable, isDoubleTapProtectionEnabled: Bool = true) {
        if isDoubleTapProtectionEnabled {
            guard !isNavigating else {
                return
            }
            isNavigating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.navigationDebounceInterval) { [weak self] in
                self?.isNavigating = false
            }

        }
        let container = RouterContainer(viewController: route.makeViewController())
        containers.append(container)
    }

    func present(route: Routable, type: PresentType = .sheet, onDismiss: (() -> Void)? = nil) {
        let container = RouterContainer(viewController: route.makeViewController())
        switch type {
        case .sheet:
            presentedSheetContainer = container
            onDismissPresentedSheet = onDismiss
        case .fullScreen:
            fullScreenCoverContainer = container
            onDismissFullScreenCover = onDismiss
        }
    }

    func dismiss(type: PresentType = .sheet) {
        switch type {
        case .sheet:
            presentedSheetContainer = nil
            onDismissPresentedSheet = nil
        case .fullScreen:
            fullScreenCoverContainer = nil
            onDismissFullScreenCover = nil
        }
    }

    func pop() {
        containers.removeLast()
    }

    func popToRoot() {
        containers.removeAll()
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
            .fullScreenCover(item: router.bindingFullScreenCoverContainer, onDismiss: { router.onDismissFullScreenCover?() }) { container in
                ViewControllerWrapper {
                    container.viewController
                }
            }
        return view
    }

    func globalPresentedSheet(router: Router) -> some View {
        let view = self
            .sheet(item: router.bindingPresentedSheetContainer, onDismiss: { router.onDismissPresentedSheet?() }) { container in
                ViewControllerWrapper {
                    container.viewController
                }
            }
        return view
    }
}

struct ViewControllerWrapper<VC: UIViewController>: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: VC, context: Context) {

    }

    private let makeViewController: () -> VC

    init(_ makeViewController: @escaping () -> VC) {
        self.makeViewController = makeViewController
    }

    func makeUIViewController(context: Context) -> VC {
        makeViewController()
    }
}
