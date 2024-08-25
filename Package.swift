// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageViewer",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "ImageViewer", targets: ["ImageViewer"]),
    ],
    targets: [
        .target(name: "ImageViewer", path: "Sources"),
//        .testTarget(name: "ImageViewerTests", dependencies: ["ImageViewer"]) // No unit tests yet, uncomment once available
    ]
)
