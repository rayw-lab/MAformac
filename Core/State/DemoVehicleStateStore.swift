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

public struct DemoActionReadback: Equatable, Sendable {
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

    public var currentRevision: Int {
        cellsByKey.values.map(\.revision).max() ?? 0
    }

    public var stateValues: [String: String] {
        cellsByKey.mapValues(\.actualValue)
    }

    public func cell(for key: String) -> DemoVehicleStateCell? {
        cellsByKey[key]
    }

    @discardableResult
    public func applyMockTransition(_ transition: DemoMockTransition) -> DemoActionReadback {
        var cell = cellsByKey[transition.key] ?? DemoVehicleStateCell(key: transition.key, actualValue: "unknown")
        cell.desiredValue = transition.desiredValue
        cell.actualValue = transition.desiredValue
        cell.source = transition.source
        cell.revision += 1
        cell.timestamp = Date()
        cell.visualState = transition.desiredValue == "on" ? .satisfied : .normal
        cellsByKey[transition.key] = cell

        return DemoActionReadback(
            key: cell.key,
            actualValue: cell.actualValue,
            revision: cell.revision,
            spokenText: DemoVehicleStateStore.spokenText(for: cell)
        )
    }

    public func reset() {
        cellsByKey = Dictionary(uniqueKeysWithValues: Self.defaultCells().map { ($0.key, $0) })
    }

    public static func defaultCells() -> [DemoVehicleStateCell] {
        [
            DemoVehicleStateCell(key: "ac.power", actualValue: "off"),
            DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24"),
            DemoVehicleStateCell(key: "ac.temp_setpoint[副驾]", actualValue: "24"),
            DemoVehicleStateCell(key: "ac.temp_setpoint[左后]", actualValue: "24"),
            DemoVehicleStateCell(key: "ac.temp_setpoint[右后]", actualValue: "24"),
            DemoVehicleStateCell(key: "window.position[主驾]", actualValue: "0"),
            DemoVehicleStateCell(key: "window.position[副驾]", actualValue: "0"),
            DemoVehicleStateCell(key: "window.position[左后]", actualValue: "0"),
            DemoVehicleStateCell(key: "window.position[右后]", actualValue: "0"),
            DemoVehicleStateCell(key: "screen.brightness[中控屏]", actualValue: "70"),
            DemoVehicleStateCell(key: "ambient.brightness[面发光氛围灯]", actualValue: "70"),
            DemoVehicleStateCell(key: "ambient.color", actualValue: "白"),
            DemoVehicleStateCell(key: "vehicle.speed", actualValue: "0"),
            DemoVehicleStateCell(key: "vehicle.gear", actualValue: "P"),
            DemoVehicleStateCell(key: "hvac.temperature", actualValue: "24"),
            DemoVehicleStateCell(key: "seat.driver.heat", actualValue: "off"),
            DemoVehicleStateCell(key: "seat.driver.ventilation", actualValue: "0"),
            DemoVehicleStateCell(key: "window.driver", actualValue: "closed"),
            DemoVehicleStateCell(key: "lighting.ambient", actualValue: "off"),
            DemoVehicleStateCell(key: "screen.brightness", actualValue: "70"),
            DemoVehicleStateCell(key: "fan.speed", actualValue: "0")
        ]
    }

    public static func spokenText(for cell: DemoVehicleStateCell) -> String {
        switch (cell.key, cell.actualValue) {
        case ("ac.power", "on"):
            return "空调已打开"
        case ("ac.power", "off"):
            return "空调已关闭"
        default:
            return "\(cell.key) 当前为 \(cell.actualValue)"
        }
    }
}
