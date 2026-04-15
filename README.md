# CypienSDK for iOS

[![iOS](https://img.shields.io/badge/iOS-13.0%2B-blue?logo=apple)](https://developer.apple.com)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange?logo=swift)](https://swift.org)
[![Version](https://img.shields.io/badge/version-1.0.0-orange)](https://github.com/Cypien-AI/cypien-ios-sdk/releases)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)

Behavioral analytics and personalized content delivery SDK for iOS.

## Requirements

- iOS 13.0+
- Swift 5.9+
- Xcode 15+

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies** and enter:

```
https://github.com/Cypien-AI/cypien-ios-sdk.git
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Cypien-AI/cypien-ios-sdk.git", from: "1.0.0"),
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "CypienSDK", package: "cypien-ios-sdk")
        ]
    ),
]
```

## Setup

Initialize the SDK at app startup with your **Workspace ID** and **API Key** from the Cypien Dashboard.

### SwiftUI

```swift
import CypienSDK

@main
struct MyApp: App {
    init() {
        Cypien.shared.initialize(config: CypienConfig(
            workspaceId: "YOUR_WORKSPACE_ID",
            apiKey: "YOUR_API_KEY"
        ))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .cypienTriggers()
                .onOpenURL { url in
                    Cypien.shared.handleDeepLink(url)
                }
        }
    }
}
```

### UIKit

```swift
import CypienSDK

func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    Cypien.shared.initialize(config: CypienConfig(
        workspaceId: "YOUR_WORKSPACE_ID",
        apiKey: "YOUR_API_KEY"
    ))
    return true
}
```

## Basic Usage

```swift
// Track screens
Cypien.shared.trackScreen("/products/sku-123", title: "Product Detail")

// Personalized description
view.cypienDescription(sku: product.sku, category: product.category) { text in
    label.text = text
}

// Personalized product image
view.cypienProductImage(sku: product.sku, category: product.category) { url in
    imageView.load(url)
}

// Commerce events
Cypien.shared.commerce.viewItem(item: item, currency: "USD", value: 49.99)
Cypien.shared.commerce.addToCart(item: item, currency: "USD", value: 49.99)
Cypien.shared.commerce.purchase(transactionId: "TXN-001", items: items, currency: "USD", value: 99.99)
```

## Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `workspaceId` | — | **Required** — from Cypien Dashboard |
| `apiKey` | — | **Required** — from Cypien Dashboard |
| `debugMode` | `false` | Verbose console logging |
| `emitInterval` | `15.0` | Seconds between event batch sends |
| `emitMode` | `.dual` | `.dual`, `.ga4Only`, `.backendOnly` |

## Documentation

Full documentation and integration guide: [cypien.ai/docs](https://cypien.ai/docs)

## License

MIT © [Cypien AI](https://cypien.ai)
