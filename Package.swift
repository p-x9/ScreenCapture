// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ScreenCapture",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "ScreenCapture",
            targets: ["ScreenCapture"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/p-x9/MovieWriter.git", .upToNextMajor(from: "0.1.0"))
    ],
    targets: [
        .target(
            name: "ScreenCapture",
            dependencies: [
                .product(name: "MovieWriter", package: "MovieWriter")
            ]
        ),
        .testTarget(
            name: "ScreenCaptureTests",
            dependencies: ["ScreenCapture"]
        ),
    ]
)
