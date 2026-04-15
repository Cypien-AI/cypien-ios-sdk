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
            url: "https://github.com/Cypien-AI/cypien-ios-sdk/releases/download/v1.0.1/CypienSDK-1.0.1.xcframework.zip",
            checksum: "1f7222d8120f8e9ef1629e9b91dee98359aa781e91eb7983dde410688900552a"
        )
    ]
)
