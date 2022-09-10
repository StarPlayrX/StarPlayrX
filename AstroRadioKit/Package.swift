// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AstroRadioKit",
    products: [
        .library(
            name: "AstroRadioKit",
            targets: ["AstroRadioKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/StarPlayrX/Swifter-Lite", branch: "1.5.1")
    ],
    targets: [
        .target(
            name: "AstroRadioKit",
            dependencies: [.product(name: "SwifterLite", package: "Swifter-Lite")]
        ),
    ]
)
