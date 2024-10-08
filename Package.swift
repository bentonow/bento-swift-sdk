// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "BentoSwiftSDK",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "BentoSwiftSDK",
            targets: ["BentoSwiftSDK"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BentoSwiftSDK",
            dependencies: []),
        .testTarget(
            name: "BentoSwiftSDKTests",
            dependencies: ["BentoSwiftSDK"]),
    ]
)
