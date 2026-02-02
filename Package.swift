// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SwiftUIStateManagement",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "SwiftUIStateManagement",
            targets: ["SwiftUIStateManagement"]
        )
    ],
    targets: [
        .target(
            name: "SwiftUIStateManagement",
            dependencies: [],
            path: "Sources/SwiftUIStateManagement"
        ),
        .testTarget(
            name: "SwiftUIStateManagementTests",
            dependencies: ["SwiftUIStateManagement"],
            path: "Tests/SwiftUIStateManagementTests"
        )
    ]
)
