// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ScreenCapture",
    products: [
        .library(
            name: "ScreenCapture",
            targets: ["ScreenCapture"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ScreenCapture",
            dependencies: []
        ),
        .testTarget(
            name: "ScreenCaptureTests",
            dependencies: ["ScreenCapture"]
        ),
    ]
)
