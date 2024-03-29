// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIRemoteImage",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftUIRemoteImage",
            targets: ["SwiftUIRemoteImage"]),
    ],
    targets: [
        .target(
            name: "SwiftUIRemoteImage",
            dependencies: [])
    ]
)
