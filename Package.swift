// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MagicIntregations",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "MagicIntregations",
            targets: ["MagicIntregations"])
    ],
    targets: [
        .target(
            name: "MagicIntregations"),
        .testTarget(
            name: "MagicIntregationsTests",
            dependencies: ["MagicIntregations"])
    ]
)
