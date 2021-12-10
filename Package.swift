// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MathRules",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "MathRules",
            targets: ["MathRules"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "0.0.7"),
    ],
    targets: [
        .target(
            name: "MathRules",
            dependencies: [.product(name: "Numerics", package: "swift-numerics"),]),
        .testTarget(
            name: "MathRulesTests",
            dependencies: ["MathRules"]),
    ]
)
