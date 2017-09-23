// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftPriorityQueue",
    products: [
        .library(
            name: "SwiftPriorityQueue",
            targets: ["SwiftPriorityQueue"]),
        ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftPriorityQueue",
            dependencies: []),
        .testTarget(
            name: "SwiftPriorityQueueTests",
            dependencies: ["SwiftPriorityQueue"]),
        ]
)
