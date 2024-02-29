// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "CutwormBDD",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "CutwormBDD",
            targets: ["CutwormBDD"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CutwormBDD",
            dependencies: []
        ),
        .testTarget(
            name: "CutwormBDDTests",
            dependencies: ["CutwormBDD"]
        ),
    ]
)
