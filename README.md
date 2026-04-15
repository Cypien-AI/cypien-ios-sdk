# Cypien iOS SDK

[![iOS](https://img.shields.io/badge/iOS-13.0%2B-blue?logo=apple)](https://developer.apple.com)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange?logo=swift)](https://swift.org)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen)](https://swift.org/package-manager)
[![Version](https://img.shields.io/badge/version-1.0.2-orange)](https://github.com/Cypien-AI/cypien-ios-sdk/releases)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)

Behavioral analytics and personalized content delivery SDK for iOS. Tracks user interactions to build interest profiles and serves personalized product descriptions, images, and banners — bringing web-level CRO personalization to native iOS apps.

**How it works:** Screen views, product interactions, and purchase events are collected automatically. The backend processes this data to assign the user an interest segment (e.g. `sport`, `electronics`, `home`). On product detail pages, descriptions and images are filtered by that segment in real time.

> This package distributes a prebuilt XCFramework binary via Swift Package Manager. No source code is included.

---

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Setup](#setup)
- [Page Integration](#page-integration)
  - [Home](#home)
  - [Category / List](#category--list)
  - [Product Detail](#product-detail)
  - [Cart](#cart)
  - [Checkout](#checkout)
  - [Purchase](#purchase)
  - [Search](#search)
- [User Management](#user-management)
- [Personalization](#personalization)
- [Triggers & Dynamic Content](#triggers--dynamic-content)
- [Debug & Testing](#debug--testing)
- [Privacy / GDPR](#privacy--gdpr)
- [How It Works](#how-it-works)
- [Configuration](#configuration)
- [API Reference](#api-reference)

---

## Requirements

| Requirement | Minimum |
|-------------|---------|
| iOS | 13.0+ |
| Swift | 5.9+ |
| Xcode | 15+ |

---

## Installation

### Swift Package Manager

In Xcode, open **File → Add Package Dependencies** and enter:

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

> **Firebase (Optional):** If your app already includes `FirebaseAnalytics`, Cypien events are automatically forwarded to GA4. No additional configuration is needed — the SDK detects Firebase at runtime.

---

## Setup

Initialize the SDK once at app startup. You need two values from Cypien: **Workspace ID** and **API Key**.

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

func applicationDidBecomeActive(_ application: UIApplication) {
    Cypien.shared.applicationDidBecomeActive()
}

func applicationDidEnterBackground(_ application: UIApplication) {
    Cypien.shared.applicationDidEnterBackground()
}
```

---

## Page Integration

Quick reference:

| Page | Required | Personalization |
|------|----------|-----------------|
| **Every screen** | `trackScreen(path, title)` | — |
| **Home** | `trackScreen("/")` | `.cypienImage(tag:)` — dynamic banner |
| **Category / List** | `trackScreen("/collections/slug")`, `commerce.viewItemList()` | — |
| **Product Detail** | `trackScreen("/products/sku")`, `commerce.viewItem()` | `.cypienDescription()`, `.cypienProductImage()` |
| **Cart** | `trackScreen("/cart")`, `commerce.viewCart()` | — |
| **Checkout** | `trackScreen("/checkout")`, `commerce.beginCheckout()` | — |
| **Purchase** | `commerce.purchase()` | — |
| **Search** | `trackScreen("/search")`, `trackSearch(query)` | — |

---

### Home

<details>
<summary><strong>SwiftUI</strong></summary>

```swift
import CypienSDK

struct HomeView: View {
    @State private var bannerUrl: URL?

    var body: some View {
        ScrollView {
            if let url = bannerUrl {
                AsyncImage(url: url)
                    .frame(maxWidth: .infinity, height: 200)
                    .clipped()
            }
            // Product list...
        }
        .onAppear {
            Cypien.shared.trackScreen("/", title: "Home")
        }
        .cypienImage(tag: "home_banner") { url, _ in
            bannerUrl = url
        }
    }
}
```

</details>

<details>
<summary><strong>UIKit</strong></summary>

```swift
import CypienSDK

class HomeViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Cypien.shared.trackScreen("/", title: "Home")

        Cypien.shared.content.fetchImage(tag: "home_banner") { [weak self] result in
            switch result {
            case .image(let url, _):
                DispatchQueue.main.async { self?.bannerImageView.load(url) }
            default:
                break
            }
        }
    }
}
```

</details>

---

### Category / List

<details>
<summary><strong>SwiftUI</strong></summary>

```swift
import CypienSDK

struct CategoryView: View {
    let category: Category
    let products: [Product]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(products) { ProductCard(product: $0) }
        }
        .onAppear {
            Cypien.shared.trackScreen(
                "/collections/\(category.slug)",
                title: category.name
            )
            Cypien.shared.commerce.viewItemList(
                items: products.map { $0.toCypienItem() },
                listName: category.name,
                listId: category.slug
            )
        }
    }
}
```

</details>

<details>
<summary><strong>UIKit</strong></summary>

```swift
import CypienSDK

class CategoryViewController: UIViewController {
    var category: Category!
    var products: [Product] = []

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Cypien.shared.trackScreen("/collections/\(category.slug)", title: category.name)
        Cypien.shared.commerce.viewItemList(
            items: products.map { $0.toCypienItem() },
            listName: category.name,
            listId: category.slug
        )
    }
}
```

</details>

---

### Product Detail

The primary personalization touchpoint. Fetches interest-matched descriptions and images alongside commerce tracking.

<details>
<summary><strong>SwiftUI</strong></summary>

```swift
import CypienSDK

struct ProductDetailView: View {
    let product: Product
    @State private var personalizedDesc: String?
    @State private var personalizedImageUrl: URL?

    var body: some View {
        ScrollView {
            AsyncImage(url: personalizedImageUrl ?? URL(string: product.imageUrl))
                .frame(maxWidth: .infinity, height: 380)
                .clipped()

            VStack(alignment: .leading, spacing: 12) {
                Text(product.name).font(.title2.bold())
                Text(personalizedDesc ?? product.description)
                    .foregroundColor(.secondary)

                Button("Add to Cart") {
                    Cypien.shared.commerce.addToCart(
                        item: product.toCypienItem(),
                        currency: "USD",
                        value: product.price
                    )
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .onAppear {
            Cypien.shared.trackScreen("/products/\(product.sku)", title: product.name)
            Cypien.shared.commerce.viewItem(
                item: product.toCypienItem(),
                currency: "USD",
                value: product.price
            )
        }
        .cypienDescription(sku: product.sku, category: product.category) { text in
            personalizedDesc = text
        }
        .cypienProductImage(sku: product.sku, category: product.category) { url in
            personalizedImageUrl = url
        }
    }
}

extension Product {
    func toCypienItem(quantity: Int = 1) -> CypienItem {
        CypienItem(
            itemId: sku,
            itemName: name,
            itemCategory: category,
            itemBrand: brand,
            price: price,
            quantity: quantity
        )
    }
}
```

</details>

<details>
<summary><strong>UIKit</strong></summary>

```swift
import CypienSDK

class ProductDetailViewController: UIViewController {
    var product: Product!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Cypien.shared.trackScreen("/products/\(product.sku)", title: product.name)
        Cypien.shared.commerce.viewItem(
            item: product.toCypienItem(),
            currency: "USD",
            value: product.price
        )

        Cypien.shared.content.fetchDescription(
            sku: product.sku,
            category: product.category
        ) { [weak self] result in
            if case .description(let text) = result {
                DispatchQueue.main.async { self?.descriptionLabel.text = text }
            }
        }

        Cypien.shared.content.fetchProductImage(
            sku: product.sku,
            category: product.category
        ) { [weak self] result in
            if case .image(let url, _) = result {
                DispatchQueue.main.async { self?.productImageView.load(url) }
            }
        }
    }
}
```

</details>

---

### Cart

<details>
<summary><strong>SwiftUI</strong></summary>

```swift
.onAppear {
    Cypien.shared.trackScreen("/cart", title: "Cart")
    Cypien.shared.commerce.viewCart(
        items: cartItems.map { $0.toCypienItem(quantity: $0.quantity) },
        currency: "USD",
        value: cartTotal
    )
}
```

</details>

<details>
<summary><strong>UIKit</strong></summary>

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Cypien.shared.trackScreen("/cart", title: "Cart")
    Cypien.shared.commerce.viewCart(
        items: cartItems.map { $0.toCypienItem(quantity: $0.quantity) },
        currency: "USD",
        value: cartTotal
    )
}
```

</details>

---

### Checkout

<details>
<summary><strong>SwiftUI</strong></summary>

```swift
.onAppear {
    Cypien.shared.trackScreen("/checkout", title: "Checkout")
    Cypien.shared.commerce.beginCheckout(
        items: cartItems.map { $0.toCypienItem() },
        currency: "USD",
        value: cartTotal
    )
}
```

</details>

<details>
<summary><strong>UIKit</strong></summary>

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Cypien.shared.trackScreen("/checkout", title: "Checkout")
    Cypien.shared.commerce.beginCheckout(
        items: cartItems.map { $0.toCypienItem() },
        currency: "USD",
        value: cartTotal
    )
}
```

</details>

---

### Purchase

Call on the order confirmation screen or inside the payment success callback.

```swift
Cypien.shared.commerce.purchase(
    transactionId: order.id,
    items: order.items.map { $0.toCypienItem(quantity: $0.quantity) },
    currency: "USD",
    value: order.total,
    tax: order.tax,
    shipping: order.shippingCost
)
```

---

### Search

```swift
Cypien.shared.trackScreen("/search", title: "Search")
Cypien.shared.trackSearch(query)
```

---

## User Management

Identify users on login and clear their identity on logout. This correctly merges anonymous and authenticated event streams.

```swift
// On login
Cypien.shared.setUserId("user-123")
Cypien.shared.setUserProperties(["plan": "premium", "country": "US"])

// On logout
Cypien.shared.resetUser()
```

---

## Personalization

The SDK automatically assigns an interest segment based on browsing behavior. Calling `fetchDescription` or `fetchProductImage` returns content filtered by that segment.

### Interest Updates

```swift
// Register once at app start
Cypien.shared.onInterestUpdated { interest in
    // interest is a string like "sport", "electronics", "home", etc.
    print("User interest segment: \(interest)")
}

// Read current interest synchronously
let currentInterest = Cypien.shared.currentInterest
```

### Content Result Types

```swift
switch result {
case .description(let text):
    // Use text as the product description
case .image(let url, let link):
    // Display image at url; link is an optional click-through URL
case .empty:
    // No personalized content defined — show your default
case .error(let error):
    // Network or backend failure — show your default
}
```

---

## Triggers & Dynamic Content

### Triggers (Popup / Banner / Toast / Bottom Sheet)

Triggers fire automatically based on user behavior rules defined in the Cypien Dashboard.

Add `.cypienTriggers()` to your root view in SwiftUI — popups and banners are displayed automatically with no additional code:

```swift
WindowGroup {
    ContentView()
        .cypienTriggers()
}
```

### Dynamic Content (Show / Hide / Replace)

Register a handler once at app startup to respond to dashboard-driven content updates:

```swift
Cypien.shared.dynamicContent.onAction { action in
    DispatchQueue.main.async {
        switch action {
        case .show(let tag, let content):
            // Show a UI element associated with tag
        case .hide(let tag):
            // Hide a UI element associated with tag
        case .replace(let tag, let content):
            // Update content for tag with new content
        }
    }
}

// Evaluate rules for the current screen
Cypien.shared.dynamicContent.evaluate(forScreen: "/")
```

---

## Debug & Testing

```swift
// Development configuration — verbose logging, faster flush
Cypien.shared.initialize(config: CypienConfig(
    workspaceId: "YOUR_WORKSPACE_ID",
    apiKey: "YOUR_API_KEY",
    debugMode: true,
    emitInterval: 5.0
))

// Force a specific interest segment for UI testing
Cypien.shared.debug.setInterestOverride(interest: "sport", durationDays: 1)

// Flush the event buffer immediately (useful in UI tests)
Cypien.shared.debug.forceEmit()

// Fetch the interest segment currently assigned by the backend
let interest = await Cypien.shared.debug.fetchInterest()
```

> Use `debugMode: false` and the default `emitInterval: 15.0` in production builds.

---

## Privacy / GDPR

```swift
// Stop all event collection and transmission
Cypien.shared.optOut()

// Resume event collection after opt-out
Cypien.shared.optIn()

// Erase all stored user data — GDPR Article 17 right to erasure
Cypien.shared.deleteUserData()
```

Opt-out state persists across app launches. When opted out, no events are collected or transmitted and no personalization requests are made.

---

## How It Works

```
1. SDK Init
   └─ Fetches workspace settings: trigger rules, content slots, interest hierarchy

2. Behavioral Data Collection
   └─ trackScreen(), commerce.viewItem(), addToCart(), trackSearch() ...
      Events are buffered in memory

3. Batch Emission (every 15s by default)
   └─ POST /v1/events → Cypien backend
   └─ Forwarded to Firebase GA4 (if FirebaseAnalytics is linked)

4. Interest Assignment (backend)
   └─ Browsing patterns are analyzed
   └─ User is assigned an interest segment (e.g. "sport", "electronics")

5. Personalization Request
   └─ fetchDescription() / fetchProductImage() called on product detail screen
   └─ Backend returns content filtered by the user's interest segment

6. Content Rendered
   └─ Product description and/or image replaced with personalized version
```

---

## Configuration

```swift
CypienConfig(
    workspaceId: "YOUR_WORKSPACE_ID",  // Required
    apiKey: "YOUR_API_KEY",            // Required — from Cypien
    debugMode: false,                  // Enable verbose console logging
    emitInterval: 15.0,               // Seconds between batch sends
    emitMode: .dual                    // .dual | .ga4Only | .backendOnly
)
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `workspaceId` | — | **Required.** Obtained from Cypien |
| `apiKey` | — | **Required.** SDK API key from Cypien |
| `debugMode` | `false` | Enables verbose console logging |
| `emitInterval` | `15.0` | Seconds between event batch sends |
| `emitMode` | `.dual` | `.dual` sends to GA4 + backend; `.ga4Only`; `.backendOnly` |

---

## API Reference

### Core (`Cypien.shared`)

| Method | Description |
|--------|-------------|
| `initialize(config:)` | Initialize the SDK — call once at app startup |
| `trackScreen(_ path:title:params:)` | Record a screen view |
| `trackSearch(_ query:params:)` | Record a search query |
| `track(event:parameters:)` | Send a custom GA4 event |
| `setUserId(_)` | Identify the current user |
| `resetUser()` | Clear user identity on logout |
| `setUserProperties(_)` | Set persistent user properties |
| `handleDeepLink(_)` | Process a deep link URL and capture UTM parameters |
| `onInterestUpdated(_)` | Register a callback for interest segment changes |
| `applicationDidBecomeActive()` | Call from UIKit `applicationDidBecomeActive` |
| `applicationDidEnterBackground()` | Call from UIKit `applicationDidEnterBackground` |
| `optOut()` | Stop all tracking and data transmission |
| `optIn()` | Resume tracking after opt-out |
| `deleteUserData()` | Erase all stored user data (GDPR Art. 17) |

### Commerce (`Cypien.shared.commerce`)

| Method | GA4 Event |
|--------|-----------|
| `viewItem(item:currency:value:)` | `view_item` |
| `viewItemList(items:listName:listId:)` | `view_item_list` |
| `selectItem(item:listName:)` | `select_item` |
| `addToCart(item:currency:value:)` | `add_to_cart` |
| `removeFromCart(item:currency:value:)` | `remove_from_cart` |
| `viewCart(items:currency:value:)` | `view_cart` |
| `beginCheckout(items:currency:value:coupon:)` | `begin_checkout` |
| `addShippingInfo(items:currency:value:shippingTier:)` | `add_shipping_info` |
| `addPaymentInfo(items:currency:value:paymentType:)` | `add_payment_info` |
| `purchase(transactionId:items:currency:value:tax:shipping:coupon:)` | `purchase` |

### Content (`Cypien.shared.content`)

| Method | Description |
|--------|-------------|
| `fetchDescription(sku:category:lang:callback:)` | Fetch a personalized product description |
| `fetchProductImage(sku:category:lang:callback:)` | Fetch a personalized product image URL |
| `fetchImage(tag:lang:callback:)` | Fetch a dynamic campaign or banner image |

### SwiftUI View Modifiers

| Modifier | Description |
|----------|-------------|
| `.cypienDescription(sku:category:) { text in }` | Delivers a personalized product description via callback |
| `.cypienProductImage(sku:category:) { url in }` | Delivers a personalized product image URL via callback |
| `.cypienImage(tag:) { url, link in }` | Delivers a dynamic banner image URL and optional click-through link |
| `.cypienTriggers()` | Enables automatic display of dashboard-configured popups and banners |

### CypienItem

```swift
CypienItem(
    itemId: "SKU-001",          // Required — product SKU or ID
    itemName: "Product Name",
    itemCategory: "Category",
    itemBrand: "Brand",
    price: 49.99,
    quantity: 1,
    currency: "USD",
    discount: 5.0,
    index: 0,                   // Position in list (0-based)
    itemListName: "Featured"
)
```

---

## License

MIT © [Cypien AI](https://cypien.ai)
