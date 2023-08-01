// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSyntaxSample",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "sss",
            targets: ["SwiftSyntaxSample"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", exact: "1.2.2"),
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "508.0.0")
    ],
    targets: [
        .executableTarget(
            name: "SwiftSyntaxSample",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax")
            ],
            swiftSettings: [
                .define("VISITOR_PATTERN_1"), // 1,2,3の３パターンを試せます
                .define("REWRITER_PATTERN_1") // 1,2の２パターンを試せます
            ]
        )
    ]
)
