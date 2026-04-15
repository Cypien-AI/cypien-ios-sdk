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
            url: "https://github.com/Cypien-AI/cypien-ios-sdk/releases/download/v1.0.0/CypienSDK-1.0.0.xcframework.zip",
            checksum: "bdd8501491bf5de9c41a54796d3625baa0b3ba6ef15d659dc3b4ff43bc4c9c7f"
        )
    ]
)
