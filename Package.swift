// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ParallaxViews",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "ParallaxViews",
            targets: ["ParallaxViews"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ParallaxViews",
            dependencies: []),
        .testTarget(
            name: "ParallaxViewsTests",
            dependencies: ["ParallaxViews"]),
    ]
)
