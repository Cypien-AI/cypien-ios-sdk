// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CypienSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "CypienSDK", targets: ["CypienSDK"]),
    ],
    targets: [
        .binaryTarget(
            name: "CypienSDK",
            url: "https://github.com/Cypien-AI/cypien-ios-sdk/releases/download/v1.0.3/CypienSDK-1.0.3.xcframework.zip",
            checksum: "aa5a1950a41b02e19452102244b9e7e1a663f3c9d6c4a5549565b776bbfbef8b"
        ),
    ]
)
