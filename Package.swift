// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StrideSync",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "StrideSync",
            targets: ["StrideSync"]
        ),
        .executable(
            name: "StrideSyncDemo",
            targets: ["StrideSyncDemo"]
        )
    ],
    targets: [
        .target(
            name: "StrideSync",
            dependencies: [],
            path: "Sources/StrideSync"
        ),
        .executableTarget(
            name: "StrideSyncDemo",
            dependencies: ["StrideSync"],
            path: "Sources/StrideSyncDemo"
        ),
        .testTarget(
            name: "StrideSyncTests",
            dependencies: ["StrideSync"],
            path: "Tests/StrideSyncTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
