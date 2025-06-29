# ``Router``

**Internal SwiftUI routing component** for managing navigation stacks, sheets, and full-screen covers using UIKit view controllers.  

---

## Design Rationale  

### Why RouterContainer?  
`RouterContainer` solves two key problems:  
1. Provides stable identifiers for navigation paths  
2. Enables type-erasure for different view controller types  

### Debounce Mechanism  
Navigation requests are throttled to prevent:  
- Accidental double-taps  
- Navigation conflicts during animations  
- Race conditions in state updates  

**Default interval**: `0.5s` (configurable via `Constants.navigationDebounceInterval`).  

---

## Overview  
The `Router` is a lightweight helper for in-app navigation, providing:  

* **Debounced Navigation**: Prevents rapid pushes with configurable interval  
* **Modal Presentation**: Unified API for sheets and full-screen covers  
* **Pop & Reset**: Simple `pop()` and `popToRoot()` methods  
* **SwiftUI Integration**: Built-in view modifiers for seamless binding  
* **Lifecycle Tracking**: OSLog integration for debugging  

![Preview](RouterDiagram.svg)

---

## Important Considerations  

### Thread Safety  
⚠️ **All router methods must be called from main thread**  
Router modifies UI state and is not thread-safe.  

### SwiftUI Integration  
❗ **Do not mix with native NavigationStack management**  
Use either router methods or standard NavigationStack APIs, not both simultaneously.  

### Memory Management  
♻️ Router holds strong references to view controllers until explicitly removed.  

---

## Usage  

### 1. Instantiate in App or Root View  
```swift  
@main
struct TermeetApp: App {
  @StateObject var router = Router()

  var body: some Scene {
    WindowGroup {
      NavigationStack(path: router.bindingNavigationStack) {
        PasswordRecoveryView()
          .globalNavigationDestination(router: router)
          .globalPresentedSheet(router: router)
          .globalFullCoverScreen(router: router)
      }
      .environmentObject(router)
    }
  }
}
```  

### 2. Define Routes via `Routable` Protocol  
```swift
enum AppRoute: Routable {
  case detail(id: String)
  case settings

  func makeViewController() -> UIViewController {
    switch self {
    case .detail(let id):
      DetailView(itemID: id).convertToViewController()
    case .settings:
      SettingsView().convertToViewController()
    }
  }
}
```  

### 3. Navigation Operations  

#### Push into Stack (with debounce)  
```swift
router.navigate(to: AppRoute.detail(id: "123")) 
// Disable protection: 
// router.navigate(to: route, isDoubleTapProtectionEnabled: false)
```  

#### Present Modals  
```swift
// Sheet (default)
router.present(
  route: AppRoute.settings,
  onDismiss: { print("Sheet dismissed") }
)

// Full-screen cover
router.present(
  route: AppRoute.detail(id: "456"),
  type: .fullScreen,
  onDismiss: { print("Cover dismissed") }
)
```  

#### Dismiss Modals  
```swift
router.dismiss()           // Default: .sheet
router.dismiss(type: .fullScreen)
```  

#### Stack Management  
```swift
router.pop()       // Remove top view
router.popToRoot() // Clear entire stack
```  

---

## SwiftUI View Modifiers  
Attach these to root views:  

| Modifier | Description | Required for |
|----------|-------------|--------------|
| `.globalNavigationDestination(router:)` | Binds navigation stack | `navigate()` |
| `.globalPresentedSheet(router:)` | Binds sheet presentations | `present(type: .sheet)` |
| `.globalFullCoverScreen(router:)` | Binds full-screen covers | `present(type: .fullScreen)` |  

```swift
ContentView()
  .globalNavigationDestination(router: mainRouter)
  .globalPresentedSheet(router: mainRouter)
  .globalFullCoverScreen(router: authRouter) 
```  

---

## Advanced Usage  

### Isolated Navigation Flows  
```swift
// Feature-specific router
struct SettingsCoordinator: View {
  @StateObject private var settingsRouter = Router()

  var body: some View {
    NavigationStack(path: settingsRouter.bindingNavigationStack) {
      SettingsListView()
        .globalNavigationDestination(router: settingsRouter)
    }
    .environmentObject(settingsRouter)
  }
}

// In parent view
SettingsCoordinator()
  .globalPresentedSheet(router: parentRouter) // Shared modal
```  

### Handling Complex Dismissals  
```swift
router.present(
  route: OnboardingRoute.start,
  type: .fullScreen,
  onDismiss: {
    // Reset parent navigation after dismissal
    parentRouter.popToRoot()
    analytics.trackOnboardingComplete()
  }
)
```  


## Examples  

### Multi-Step Flow with Debounce  
```swift  
enum ShopRoute: Routable {
  case productDetail(id: UUID)
  case checkout

  func makeViewController() -> UIViewController { ... }
}

struct ProductButton: View {
  @EnvironmentObject var router: Router
  
  let productID: UUID

  var body: some View {
    Button("View Details") {
      router.navigate(to: ShopRoute.productDetail(id: productID))
    }
  }
}
```  

### Authentication Flow with Dismiss Handler  
```swift  
router.present(
  route: AuthRoute.login,
  type: .fullScreen,
  onDismiss: {
    // On successful login:
    router.navigate(to: ProfileRoute.dashboard)
  }
)

// Inside LoginView
Button("Login") {
  handleLogin { success in
    if success {
      router.dismiss(type: .fullScreen)
    }
  }
}
```  
