// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Numbers",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "Numbers",
            dependencies: ["SwiftTUI"]),
        .testTarget(
            name: "NumbersTests",
            dependencies: ["Numbers"]),
    ]
)
