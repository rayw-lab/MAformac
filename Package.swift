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
        .executable(name: "C6BenchCLI", targets: ["C6BenchCLI"])
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
        )
    ]
)
