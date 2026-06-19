# ``InputTextView``

Enhanced text input field with validation support

![Preview](InputTextView.png)

## Overview
Text input component featuring:
- Header and hint support
- Error validation states
- Secure text entry mode
- Additional actions

## Behavior

### Visibility Rules
- **Header**: Only visible when `headerText` is provided
```swift
InputTextView(text: $password, configuration: .init(
    placeholder: "Enter password"
)) // No header
```

- **Secure Toggle**: Eye icon appears only when `isSecured = true`
```swift
InputTextView(text: $password, configuration: .init(
    isSecured: true
))
```

### Validation
- **Error State**: Red border appears when `isErrored = true`
```swift
InputTextView(configuration: .init(
    isErrored: true,
    footerText: "Invalid format"
))
```

## Configuration

### Main Parameters
```swift
struct InputTextConfiguration {
    var placeholder: String?          // Input hint text
    var headerText: String?           // Field header
    var isSecured: Bool = false       // Password mode
    var isErrored: Bool = false       // Error state
}
```

### Customization
```swift
// Custom error styling
InputTextView(configuration: .init(
    errorColor: .purple,
    boardColor: .gray
))
```

## Usage Examples

### Basic Text Field
```swift
@State private var email = ""
InputTextView(text: $email, configuration: .init(
    placeholder: "user@example.com"
))
```

### Validation Example
```swift
InputTextView(text: $password, configuration: .init(
    placeholder: "Password",
    isSecured: true,
    isErrored: !isPasswordValid,
    footerText: "Min 8 characters"
))
```

## See Also
- ``ConfirmButton``
