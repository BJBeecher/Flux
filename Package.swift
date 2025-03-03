// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Flux",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Flux",
            targets: ["Flux"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", .upToNextMajor(from: "1.3.9")),
    ],
    targets: [
        .target(name: "Flux", dependencies: [.product(name: "Dependencies", package: "swift-dependencies")]),
        .testTarget(name: "FluxTests", dependencies: ["Flux"])
    ]
)
