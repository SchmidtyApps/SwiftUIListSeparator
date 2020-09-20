// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIListSeparator",
    platforms: [
            .iOS(.v13),
        ],
    products: [
        .library(
            name: "SwiftUIListSeparator",
            targets: ["SwiftUIListSeparator"]),
    ],
    targets: [
        .target(
            name: "SwiftUIListSeparator",
            dependencies: []),
        .testTarget(
            name: "SwiftUIListSeparatorTests",
            dependencies: ["SwiftUIListSeparator"]),
    ]
)
