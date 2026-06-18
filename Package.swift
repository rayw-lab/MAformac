// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MAformac",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "MAformacCore", targets: ["MAformacCore"])
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
                "Resources",
                "Tests",
                "contracts",
                "dev",
                "docs",
                "openspec",
                "prototypes",
                "referencerepo",
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
        )
    ]
)
