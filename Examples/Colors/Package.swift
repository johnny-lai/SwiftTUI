// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Colors",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "Colors",
            dependencies: ["SwiftTUI"]
        )
    ]
)
