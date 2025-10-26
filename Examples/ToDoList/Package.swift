// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "ToDoList",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "ToDoList",
            dependencies: ["SwiftTUI"]),
        .testTarget(
            name: "ToDoListTests",
            dependencies: ["ToDoList"]),
    ]
)
