// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "media-player",
    defaultLocalization: "en",
    platforms: [
      .macOS(.v14),
      .iOS(.v17),
      .tvOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "media-player",
            targets: ["media-player"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
      .package(url: "https://github.com/shvets/item-navigator", from: "1.0.7")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "media-player",
            dependencies: [
              "item-navigator",
            ]),
        .testTarget(
            name: "media-playerTests",
            dependencies: ["media-player"]),
    ]
)
