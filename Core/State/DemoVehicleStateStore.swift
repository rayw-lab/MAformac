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

    public init(key: String, actualValue: String, revision: Int, spokenText: String) {
        self.key = key
        self.actualValue = actualValue
        self.revision = revision
        self.spokenText = spokenText
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

    /// Applies multiple state transitions atomically, returning readback for the primary cell.
    /// Secondary cells are written but their readback is not returned.
    /// This is the unique write entry point for multi-cell capabilities; immutability is preserved
    /// by constructing new DemoVehicleStateCell values rather than mutating in place.
    @discardableResult
    public func applyMockTransitions(primary: DemoMockTransition, secondary: [DemoMockTransition]) -> DemoActionReadback {
        for transition in secondary {
            var cell = cellsByKey[transition.key] ?? DemoVehicleStateCell(key: transition.key, actualValue: "unknown")
            cell.desiredValue = transition.desiredValue
            cell.actualValue = transition.desiredValue
            cell.source = transition.source
            cell.revision += 1
            cell.timestamp = Date()
            cell.visualState = transition.desiredValue == "on" ? .satisfied : .normal
            cellsByKey[transition.key] = cell
        }
        return applyMockTransition(primary)
    }

    public func readback(for key: String) -> DemoActionReadback {
        let cell = cellsByKey[key] ?? DemoVehicleStateCell(key: key, actualValue: "unknown", availability: .unknown)
        return DemoActionReadback(
            key: cell.key,
            actualValue: cell.actualValue,
            revision: cell.revision,
            spokenText: Self.spokenText(for: cell)
        )
    }

    public func reset() {
        cellsByKey = Dictionary(uniqueKeysWithValues: Self.defaultCells().map { ($0.key, $0) })
    }

    public static func defaultCells() -> [DemoVehicleStateCell] {
        [
            DemoVehicleStateCell(key: "hvac.ac", actualValue: "off"),
            DemoVehicleStateCell(key: "hvac.temperature", actualValue: "24"),
            DemoVehicleStateCell(key: "seat.driver.heat", actualValue: "off"),
            DemoVehicleStateCell(key: "seat.driver.ventilation", actualValue: "0"),
            DemoVehicleStateCell(key: "window.driver", actualValue: "closed"),
            DemoVehicleStateCell(key: "lighting.ambient", actualValue: "off"),
            DemoVehicleStateCell(key: "screen.brightness", actualValue: "70"),
            DemoVehicleStateCell(key: "fan.speed", actualValue: "0")
        ]
    }

    private static func spokenText(for cell: DemoVehicleStateCell) -> String {
        switch (cell.key, cell.actualValue) {
        case ("hvac.ac", "on"):
            return "空调已打开"
        case ("hvac.ac", "off"):
            return "空调已关闭"
        default:
            return "\(cell.key) 当前为 \(cell.actualValue)"
        }
    }
}
