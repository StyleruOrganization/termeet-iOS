# ``Router``


**Внутренний компонент маршрутизации SwiftUI** для управления стеком навигации, sheet-представлениями и полноэкранными cover-экранами через UIKit view controller’ы.

## Назначение

`Router` используется как центральная точка переходов между экранами приложения. Он:
- хранит стек маршрутов;
- умеет открывать модальные экраны;
- синхронизирует состояние SwiftUI с `UINavigationController`;
- снижает риск повторных переходов с помощью debounce-защиты.

## Ключевые типы рядом с ним

- `Routable` — протокол, который должен уметь построить `UIViewController`.
- `RouterContainer` — обёртка над конкретным view controller’ом.
- `PresentType` — тип модального показа: `.sheet` или `.fullScreen`.
- `RouterView` — готовая обёртка для корневого SwiftUI-экрана.
- `RouterNavigationControllerHost` — мост между SwiftUI и UIKit.

## Поведение

### Навигация
Метод `navigate(to:)` добавляет новый контроллер в стек.  
Если включена защита от двойного нажатия, повторный вызов блокируется на интервал, заданный в `Constants.navigationDebounceInterval` (`0.5s` по умолчанию).

### Модальные окна
`present(route:type:onDismiss:)` показывает экран как sheet или full-screen cover.  
`dismiss(type:)` закрывает соответствующее представление и очищает callback закрытия.

### Управление стеком
`pop()` удаляет верхний экран.  
`popToRoot()` очищает весь стек до корня.

## Важные ограничения

- Все методы должны вызываться с main thread.
- `Router` не предназначен для одновременного использования с нативным управлением `NavigationStack` в той же ветке навигации.
- Объекты экранов удерживаются в контейнерах до тех пор, пока не будут удалены из стека.

## Использование

```swift
@main
struct CameraControlApp: App {
    @StateObject var router = Router()

    var body: some Scene {
        WindowGroup {
            RouterView(router: router) {
                HomeView()
            }
            .environmentObject(router)
        }
    }
}
```

```swift
router.navigate(to: AppRoute.cameraControl(camera: camera))
router.present(route: AppRoute.editSaved(camera: camera, onComplete: { _ in }))
router.popToRoot()
```
