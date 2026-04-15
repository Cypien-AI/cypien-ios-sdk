// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CypienSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "CypienSDK", targets: ["CypienSDK"])
    ],
    targets: [
        .binaryTarget(
            name: "CypienSDK",
            url: "https://github.com/Cypien-AI/cypien-ios-sdk/releases/download/v1.0.2/CypienSDK-1.0.2.xcframework.zip",
            checksum: "109b26ef16e32810b2c94fb6b1cf2cff27acfd3cf005b437cc9b1f34db7affb4"
        )
    ]
)
