// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RealTimeLogs",
    dependencies: [
        .package(url: "https://github.com/tomieq/swifter.git", .upToNextMajor(from: "1.5.6")),
        .package(url: "https://github.com/tomieq/Template.swift.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .executableTarget(
            name: "RealTimeLogs",
            dependencies: [
                .product(name: "Swifter", package: "Swifter")
            ]),
        .testTarget(
            name: "RealTimeLogsTests",
            dependencies: ["RealTimeLogs"]),
    ]
)
