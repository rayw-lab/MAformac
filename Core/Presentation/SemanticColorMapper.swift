import Foundation

enum ThermalTint: String, Equatable, Sendable {
    case cooling
    case heating
    case neutral
}

enum SemanticColorMapper {
    private static let acModeTints: [String: ThermalTint] = [
        "制冷": .cooling,
        "制热": .heating,
        "auto": .neutral,
        "自动": .neutral
    ]

    static func acThermalTint(siblingCells: [DemoVehicleStateCell]) -> ThermalTint {
        guard let mode = siblingCells.first(where: { ScopedStateKey($0.key).base == "ac.mode" }) else {
            return .neutral
        }
        guard let tint = acModeTints[mode.actualValue] else {
            return .neutral
        }
        return tint
    }
}
