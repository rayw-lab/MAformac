import Foundation
import Observation

public enum DemoVehicleAvailability: String, Codable, Sendable {
    case available
    case unavailable
    case planned
    case unknown
}

public enum DemoVehicleValueSource: String, Codable, Sendable {
    case mock
    case user
    case system
}

public enum DemoVisualState: String, Codable, Sendable {
    case normal
    case satisfied
    case changing
    case blocked_with_alternative
    case blocked_hard
    case unsafe
    case unknown
}

public struct DemoVehicleStateCell: Identifiable, Codable, Equatable, Sendable {
    public var id: String { key }

    public var key: String
    public var actualValue: String
    public var desiredValue: String?
    public var availability: DemoVehicleAvailability
    public var timestamp: Date
    public var source: DemoVehicleValueSource
    public var revision: Int
    public var visualState: DemoVisualState

    public init(
        key: String,
        actualValue: String,
        desiredValue: String? = nil,
        availability: DemoVehicleAvailability = .available,
        timestamp: Date = Date(),
        source: DemoVehicleValueSource = .mock,
        revision: Int = 0,
        visualState: DemoVisualState = .normal
    ) {
        self.key = key
        self.actualValue = actualValue
        self.desiredValue = desiredValue
        self.availability = availability
        self.timestamp = timestamp
        self.source = source
        self.revision = revision
        self.visualState = visualState
    }
}

public struct DemoMockTransition: Equatable, Sendable {
    public var key: String
    public var desiredValue: String
    public var source: DemoVehicleValueSource

    public init(key: String, desiredValue: String, source: DemoVehicleValueSource = .mock) {
        self.key = key
        self.desiredValue = desiredValue
        self.source = source
    }
}

public struct DemoActionReadback: Codable, Equatable, Sendable {
    public var key: String
    public var actualValue: String
    public var revision: Int
    public var spokenText: String
    public var scopeOrigin: ScopeOrigin?

    public init(
        key: String,
        actualValue: String,
        revision: Int,
        spokenText: String,
        scopeOrigin: ScopeOrigin? = nil
    ) {
        self.key = key
        self.actualValue = actualValue
        self.revision = revision
        self.spokenText = spokenText
        self.scopeOrigin = scopeOrigin
    }
}

@Observable
@MainActor
public final class DemoVehicleStateStore {
    private var cellsByKey: [String: DemoVehicleStateCell]

    public init(cells: [DemoVehicleStateCell] = DemoVehicleStateStore.defaultCells()) {
        self.cellsByKey = Dictionary(uniqueKeysWithValues: cells.map { ($0.key, $0) })
    }

    public var cells: [DemoVehicleStateCell] {
        cellsByKey.values.sorted { $0.key < $1.key }
    }

    public var presentationCells: [DemoVehicleStateCell] {
        cells.filter { !Self.legacyDisplayCompatibilityKeys.contains($0.key) }
    }

    public var currentRevision: Int {
        cellsByKey.values.map(\.revision).max() ?? 0
    }

    public var stateValues: [String: String] {
        cellsByKey.mapValues(\.actualValue)
    }

    public func cell(for key: String) -> DemoVehicleStateCell? {
        cellsByKey[key] ?? legacyCompatibilityCell(for: key)
    }

    public func replaceCells(_ cells: [DemoVehicleStateCell]) {
        cellsByKey = Dictionary(uniqueKeysWithValues: cells.map { ($0.key, $0) })
    }

    @discardableResult
    public func applyMockTransition(_ transition: DemoMockTransition) -> DemoActionReadback {
        guard var cell = cellsByKey[transition.key] else {
            return DemoActionReadback(
                key: transition.key,
                actualValue: "missing",
                revision: currentRevision,
                spokenText: "状态未定义"
            )
        }
        let oldValue = cell.actualValue
        if cell.actualValue == transition.desiredValue {
            return DemoActionReadback(
                key: cell.key,
                actualValue: cell.actualValue,
                revision: cell.revision,
                spokenText: DemoVehicleStateStore.spokenText(for: cell)
            )
        }
        cell.desiredValue = transition.desiredValue
        cell.actualValue = transition.desiredValue
        cell.source = transition.source
        cell.revision += 1
        cell.timestamp = Date()
        cell.visualState = Self.visualStateAfterMockTransition(
            oldValue: oldValue,
            desiredValue: transition.desiredValue,
            previousState: cell.visualState
        )
        cellsByKey[transition.key] = cell

        return DemoActionReadback(
            key: cell.key,
            actualValue: cell.actualValue,
            revision: cell.revision,
            spokenText: DemoVehicleStateStore.spokenText(for: cell)
        )
    }

    private static func visualStateAfterMockTransition(
        oldValue: String,
        desiredValue: String,
        previousState: DemoVisualState
    ) -> DemoVisualState {
        if desiredValue == oldValue {
            return previousState
        }
        if ["on", "open", "unlocked", "unmuted"].contains(desiredValue) {
            return .satisfied
        }
        if ["off", "closed", "locked", "muted"].contains(desiredValue) {
            return .normal
        }
        return .changing
    }

    public func reset() {
        cellsByKey = Dictionary(uniqueKeysWithValues: Self.defaultCells().map { ($0.key, $0) })
    }

    public static let legacyDisplayCompatibilityKeys: Set<String> = [
        "seat.driver.heat",
        "seat.driver.ventilation",
        "window.driver",
        "lighting.ambient",
        "screen.brightness",
        "fan.speed"
    ]

    private static let archivedComfortQueryStateCellAlias = ["hvac", "temperature"].joined(separator: ".")

    private func legacyCompatibilityCell(for key: String) -> DemoVehicleStateCell? {
        guard key == Self.archivedComfortQueryStateCellAlias else { return nil }
        return cellsByKey["ac.temp_setpoint[主驾]"]
    }

    public static func defaultCells() -> [DemoVehicleStateCell] {
        [
            DemoVehicleStateCell(key: "ac.power", actualValue: "off"),
            DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24"),
            DemoVehicleStateCell(key: "ac.temp_setpoint[副驾]", actualValue: "24"),
            DemoVehicleStateCell(key: "ac.temp_setpoint[左后]", actualValue: "24"),
            DemoVehicleStateCell(key: "ac.temp_setpoint[右后]", actualValue: "24"),
            DemoVehicleStateCell(key: "ac.mode", actualValue: "制冷"),
            DemoVehicleStateCell(key: "ac.fan_speed[主驾]", actualValue: "1"),
            DemoVehicleStateCell(key: "window.position[主驾]", actualValue: "0"),
            DemoVehicleStateCell(key: "window.position[副驾]", actualValue: "0"),
            DemoVehicleStateCell(key: "window.position[左后]", actualValue: "0"),
            DemoVehicleStateCell(key: "window.position[右后]", actualValue: "0"),
            DemoVehicleStateCell(key: "screen.brightness[中控屏]", actualValue: "70"),
            DemoVehicleStateCell(key: "ambient.brightness[面发光氛围灯]", actualValue: "70"),
            DemoVehicleStateCell(key: "ambient.color", actualValue: "白"),
            DemoVehicleStateCell(key: "seat.heat_level[主驾]", actualValue: "0"),
            DemoVehicleStateCell(key: "seat.vent_level[主驾]", actualValue: "0"),
            DemoVehicleStateCell(key: "seat.massage_mode", actualValue: "波浪模式"),
            DemoVehicleStateCell(key: "seat.backrest_angle[主驾]", actualValue: "50"),
            DemoVehicleStateCell(key: "volume.mode", actualValue: "现代"),
            DemoVehicleStateCell(key: "wiper.mode", actualValue: "手动模式"),
            DemoVehicleStateCell(key: "fragrance.mode", actualValue: "若云模式"),
            DemoVehicleStateCell(key: "vehicle.speed", actualValue: "0"),
            DemoVehicleStateCell(key: "vehicle.gear", actualValue: "P"),
            DemoVehicleStateCell(key: "seat.driver.heat", actualValue: "off"),
            DemoVehicleStateCell(key: "seat.driver.ventilation", actualValue: "0"),
            DemoVehicleStateCell(key: "window.driver", actualValue: "closed"),
            DemoVehicleStateCell(key: "lighting.ambient", actualValue: "off"),
            DemoVehicleStateCell(key: "screen.brightness", actualValue: "70"),
            DemoVehicleStateCell(key: "fan.speed", actualValue: "0")
        ]
    }

    public static func spokenText(for cell: DemoVehicleStateCell) -> String {
        let scopedKey = ScopedStateKey(cell.key)
        let catalog = StateCellPresentationCatalog.shared
        if let rendered = catalog.renderReadback(
            stateKey: cell.key,
            scope: scopedKey.scope,
            value: cell.actualValue
        ) {
            return rendered
        }

        switch (cell.key, cell.actualValue) {
        case ("ac.power", "on"):
            return "空调已打开"
        case ("ac.power", "off"):
            return "空调已关闭"
        default:
            let valueType = UIValueTypeMapper.mappedUIValueType(forBase: scopedKey.base) ?? .badge
            let displayValue = VehicleCardDisplay.valueText(for: cell.actualValue, base: scopedKey.base, type: valueType)
            let title = catalog.displayTitle(for: scopedKey.base)
            guard title != scopedKey.base else {
                return "\(cell.key) 当前为 \(cell.actualValue)"
            }
            return "\(title)\(displayValue)"
        }
    }
}
