// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIRemoteImage",
    products: [
        .library(
            name: "SwiftUIRemoteImage",
            targets: ["SwiftUIRemoteImage"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftUIRemoteImage",
            dependencies: []),
        .testTarget(
            name: "SwiftUIRemoteImageTests",
            dependencies: ["SwiftUIRemoteImage"]),
    ]
)
