import Foundation

enum LiquidGlassSurfaceID: String, CaseIterable, Equatable, Hashable, Sendable {
    case micDock
    case contextCapsule
    case demoControlPanel
}

enum LiquidGlassSurfaceRole: String, CaseIterable, Equatable, Hashable, Sendable {
    case transientInteractiveControl = "transient_interactive_control"
    case functionalControl = "functional_control"
    case contentCard = "content_card"
}

enum LiquidGlassHardeningConcern: String, CaseIterable, Equatable, Hashable, Sendable {
    case reduceTransparency = "reduce_transparency"
    case lowBrightnessContrast = "low_brightness_contrast"
    case iOS26PointRelease = "ios26_point_release"
    case glassEffectContainerReview = "glass_effect_container_review"
}

struct LiquidGlassSurfaceInventoryItem: Equatable, Sendable {
    let id: LiquidGlassSurfaceID
    let sourcePath: String
    let role: LiquidGlassSurfaceRole
    let usesGlassEffect: Bool
    let requiresContainerByDefault: Bool
    let concerns: Set<LiquidGlassHardeningConcern>
}

enum LiquidGlassHardeningInventory {
    static let contentCardGlassAllowed = false

    static let items: [LiquidGlassSurfaceInventoryItem] = [
        LiquidGlassSurfaceInventoryItem(
            id: .micDock,
            sourcePath: "App/ContentView.swift",
            role: .transientInteractiveControl,
            usesGlassEffect: true,
            requiresContainerByDefault: false,
            concerns: defaultConcerns
        ),
        LiquidGlassSurfaceInventoryItem(
            id: .contextCapsule,
            sourcePath: "App/ContextCapsule.swift",
            role: .functionalControl,
            usesGlassEffect: true,
            requiresContainerByDefault: false,
            concerns: defaultConcerns
        ),
        LiquidGlassSurfaceInventoryItem(
            id: .demoControlPanel,
            sourcePath: "App/DemoControlPanel.swift",
            role: .functionalControl,
            usesGlassEffect: true,
            requiresContainerByDefault: false,
            concerns: defaultConcerns
        )
    ]

    private static let defaultConcerns: Set<LiquidGlassHardeningConcern> = [
        .reduceTransparency,
        .lowBrightnessContrast,
        .iOS26PointRelease,
        .glassEffectContainerReview
    ]
}
