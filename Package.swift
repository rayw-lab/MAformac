// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MAformac",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "MAformacCore", targets: ["MAformacCore"]),
        .executable(name: "C5DataGateCLI", targets: ["C5DataGateCLI"]),
        .executable(name: "C5TrainingCLI", targets: ["C5TrainingCLI"]),
        .executable(name: "C6BenchCLI", targets: ["C6BenchCLI"]),
        .executable(name: "Gate7DryRunCLI", targets: ["Gate7DryRunCLI"])
    ],
    targets: [
        .target(
            name: "MAformacCore",
            path: ".",
            exclude: [
                ".claude",
                ".codex",
                "AGENTS.md",
                "App",
                "CLAUDE.md",
                "CONTEXT.md",
                "Makefile",
                "Reports",
                "Resources",
                "Tests",
                "Tools",
                "contracts",
                "dev",
                "docs",
                "generated",
                "openspec",
                "prototypes",
                "referencerepo",
                "scripts",
                "MAformac.xcodeproj"
            ],
            sources: [
                "Core",
                "Features"
            ]
        ),
        .testTarget(
            name: "MAformacCoreTests",
            dependencies: ["MAformacCore"],
            path: "Tests/MAformacCoreTests"
        ),
        .executableTarget(
            name: "C6BenchCLI",
            dependencies: ["MAformacCore"],
            path: "Tools/C6BenchCLI"
        ),
        .executableTarget(
            name: "C5DataGateCLI",
            dependencies: ["MAformacCore"],
            path: "Tools/C5DataGateCLI"
        ),
        .executableTarget(
            name: "C5TrainingCLI",
            dependencies: ["MAformacCore"],
            path: "Tools/C5TrainingCLI",
            exclude: [
                "c5_mlx_train_loop.py",
                "c5_mask_offset_fixture.py",
                "c5_mlx_train_loop.verification.json"
            ]
        ),
        .executableTarget(
            name: "Gate7DryRunCLI",
            dependencies: ["MAformacCore"],
            path: "Tools/Gate7DryRunCLI"
        )
    ]
)
