# ``ConfirmButton``

Custom action button with dynamic interface elements

![Preview](ConfirmButton.png)

## Overview
A confirmation button component supporting:
- Primary action button
- Optional header
- Secondary footer button
- Custom styling

## Behavior

### Visibility Conditions
- **Header**: Only shown when `headerText` is set
```swift
// Without header
ConfirmButton(configuration: .init(title: "Submit"))
```

- **Footer Button**: Appears only when `footerTextButton` is provided
```swift
// With footer
ConfirmButton(configuration: .init(
    title: "Pay",
    footerTextButton: "Cancel Payment"
))
```

### States
- **Disabled State**: Button becomes inactive when `isEnabled = false`
```swift
ConfirmButton(configuration: .init(
    title: "Submit",
    isEnabled: false
))
```

## Configuration

### Core Parameters
```swift
struct ConfirmButtonConfiguration {
    var title: String                  // Required button label
    var headerText: String?            // Optional header text
    var footerTextButton: String?      // Secondary button text
    var isEnabled: Bool = true         // Active state
}
```

### Styling
```swift
// Custom colors example
ConfirmButton(configuration: .init(
    title: "Save",
    titleColor: .blue,
    backgroundColor: .yellow
))
```

## Usage Examples

### Minimal Configuration
```swift
ConfirmButton(title: "Confirm Order")
```

### Full Configuration
```swift
ConfirmButton(configuration: .init(
    title: "Delete Account",
    headerText: "Danger Zone",
    footerTextButton: "Cancel",
    action: {
        // Handle delete action
    }
))
```

## See Also
- ``InputTextView``
