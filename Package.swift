// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "MMMParallaxViews",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "MMMParallaxViews",
            targets: ["MMMParallaxViews"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MMMParallaxViews",
            dependencies: []),
        .testTarget(
            name: "MMMParallaxViewsTests",
            dependencies: ["MMMParallaxViews"]),
    ]
)
