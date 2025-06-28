import SwiftUI
import UIKit

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

    @Published private var containers = [RouterContainer]()
    @Published private var presentedSheetContainer: RouterContainer?
    @Published private var fullCoverScreenContainer: RouterContainer?

    func bindingNavigationStack() -> Binding<[RouterContainer]> {
        .init(
            get: { [weak self] in
                self?.containers ?? []
            },
            set: { [weak self] value in
                self?.containers = value
            }

        )
    }

    func bindingPresentedSheetContainer() -> Binding<RouterContainer?> {
        .init(
            get: { [weak self] in
                self?.presentedSheetContainer
            },
            set: { [weak self] value in
                self?.presentedSheetContainer = value
            }
        )
    }

    func bindingFullScreenCoverContainer() -> Binding<RouterContainer?> {
        .init(
            get: { [weak self] in
                self?.fullCoverScreenContainer
            },
            set: { [weak self] value in
                self?.fullCoverScreenContainer = value
            }
        )
    }

    func navigate(to route: Routable) {
        let container = RouterContainer(viewController: route.makeViewController())
        containers.append(container)
    }

    func present(route: Routable, type: PresentType = .sheet) {
        let container = RouterContainer(viewController: route.makeViewController())
        switch type {
        case .sheet:
            presentedSheetContainer = container
        case .fullScreen:
            fullCoverScreenContainer = container
        }
    }

    func dismiss(type: PresentType = .sheet) {
        switch type {
        case .sheet:
            presentedSheetContainer = nil
        case .fullScreen:
            fullCoverScreenContainer = nil
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
            .fullScreenCover(item: router.bindingFullScreenCoverContainer()) { container in
                ViewControllerWrapper {
                    container.viewController
                }
            }
        return view
    }

    func globalPresentedSheet(router: Router) -> some View {
        let view = self
            .sheet(item: router.bindingPresentedSheetContainer()) { container in
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
