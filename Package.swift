// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SwiftTUI",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftTUI",
            targets: ["SwiftTUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/ikelax/swift-ansi-escapes", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "SwiftTUI",
            dependencies: [
                .product(name: "AnsiEscapes", package: "swift-ansi-escapes")
            ]),
        .testTarget(
            name: "SwiftTUITests",
            dependencies: ["SwiftTUI"]),
    ]
)
