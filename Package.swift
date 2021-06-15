// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Flux",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Flux",
            targets: ["Flux"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Flux",
            dependencies: []),
        .testTarget(
            name: "FluxTests",
            dependencies: ["Flux"]),
    ]
)
