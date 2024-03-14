// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Umbrella package to workaround "The selected package cannot be a direct ancestor of the project."
// error when importing CutwormBDD from a local path.

import PackageDescription

let package = Package(
    name: "CutwormBDDLocalWrapper",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "CutwormBDDLocalWrapper",
            targets: ["CutwormBDDLocalWrapper"])
    ],
    dependencies: [
        .package(
            name: "CutwormBDD",
            path: "../../../../.."
        )
    ],
    targets: [
        .target(
            name: "CutwormBDDLocalWrapper",
            dependencies: ["CutwormBDD"],
            path: "Sources"
        )
    ]
)
