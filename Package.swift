// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftUIStateManagement",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "SwiftUIStateManagement", targets: ["SwiftUIStateManagement"]),
    ],
    targets: [
        .target(
            name: "SwiftUIStateManagement",
            path: "Sources/SwiftUIStateManagement",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SwiftUIStateManagementTests",
            dependencies: ["SwiftUIStateManagement"]
        )
    ]
)
