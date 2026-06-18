// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SpikeE3FunctionCall",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "spike-e3", targets: ["SpikeE3"])
    ],
    dependencies: [
        .package(url: "https://github.com/ml-explore/mlx-swift-lm", exact: "3.31.3"),
        .package(url: "https://github.com/huggingface/swift-transformers", exact: "1.3.3"),
        .package(url: "https://github.com/huggingface/swift-huggingface.git", exact: "0.9.0"),
    ],
    targets: [
        .executableTarget(
            name: "SpikeE3",
            dependencies: [
                .product(name: "MLXLLM", package: "mlx-swift-lm"),
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
                .product(name: "MLXHuggingFace", package: "mlx-swift-lm"),
                .product(name: "Tokenizers", package: "swift-transformers"),
                .product(name: "HuggingFace", package: "swift-huggingface"),
            ],
            path: "Sources/SpikeE3",
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
