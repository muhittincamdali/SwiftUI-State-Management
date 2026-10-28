// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SwiftUIStateManagement",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "SwiftUIStateManagement", targets: ["SwiftUIStateManagement"]),
        .library(name: "SwiftUIStateManagementTesting", targets: ["SwiftUIStateManagementTesting"]),
    ],
    targets: [
        .target(name: "SwiftUIStateManagement"),
        .target(
            name: "SwiftUIStateManagementTesting",
            dependencies: ["SwiftUIStateManagement"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
