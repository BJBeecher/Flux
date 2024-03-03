// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
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
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
    ],
    targets: [
        .target(
            name: "Flux",
            dependencies: []),
        .testTarget(
            name: "FluxTests",
            dependencies: ["Flux"]),
        .macro(
            name: "FluxMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
    ]
)
