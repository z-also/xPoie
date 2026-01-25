// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Llmx",
    platforms: [.macOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Llmx",
            targets: ["Llmx"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown", from: "0.7.3"),
        .package(url: "https://github.com/huggingface/swift-transformers", from: "1.1.6"),
        .package(url: "https://github.com/ml-explore/mlx-swift", from: "0.30.3"),
        .package(url: "https://github.com/z-also/AnyLanguageModel.git", branch: "main", traits: ["MLX"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Llmx",
            dependencies: [
                .product(name: "MLX", package: "mlx-swift"),
//                .product(name: "MLXRandom", package: "mlx-swift"),  // 用于 sampling
                .product(name: "Hub", package: "swift-transformers"),
//                .product(name: "Tokenizers", package: "swift-transformers"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "AnyLanguageModel", package: "AnyLanguageModel"),
                
            ]
        ),
        .testTarget(
            name: "LlmxTests",
            dependencies: ["Llmx"]
        ),
    ]
)
