// GENERATED from contracts/capabilities.yaml and contracts/agents.yaml — do not edit.
import Foundation

public struct GeneratedIntegerRange: Equatable, Sendable {
    public let minimum: Int
    public let maximum: Int
}

public struct GeneratedToolProperty: Equatable, Sendable {
    public let type: String
    public let enumValues: [String]
    public let minimum: Int?
    public let maximum: Int?
}

public struct GeneratedToolSchema: Equatable, Sendable {
    public let name: String
    public let description: String
    public let properties: [String: GeneratedToolProperty]
    public let required: [String]
}

public struct GeneratedReferenceBinding: Equatable, Sendable {
    public let readable: Bool
    public let writable: Bool
    public let valueType: String
    public let allowedValues: [String]
}

public struct GeneratedStateTransform: Equatable, Sendable {
    public let field: String
    public let stateCell: String
    /// When true and the field value equals "unchanged", skip writing this cell.
    public let unchangedSkip: Bool
    /// When true, apply ambient composite logic (power:on → write color; power:off → write "off").
    public let ambientComposite: Bool
}

public struct GeneratedExecutionRule: Equatable, Sendable {
    public let connector: String
    public let mockBehavior: String
    public let stateCell: String
    public let relatedStateCells: [String]
    public let idempotent: Bool
    public let exclusiveBus: String
    /// Declarative field→state_cell mapping for multi-cell mock transitions.
    public let stateTransforms: [GeneratedStateTransform]
}

public struct GeneratedDemoGuardRule: Equatable, Sendable {
    public let riskLevel: String
    public let confirmPolicy: String
    public let writable: Bool
    public let ranges: [String: GeneratedIntegerRange]
    public let enumValues: [String: [String]]
    public let preconditions: [String]
}

public struct GeneratedCapabilityContract: Equatable, Sendable, Identifiable {
    public let id: String
    public let status: String
    public let displayZH: String
    public let toolSchema: GeneratedToolSchema
    public let referenceBinding: GeneratedReferenceBinding
    public let execution: GeneratedExecutionRule
    public let demoGuard: GeneratedDemoGuardRule
}

public struct GeneratedAgentContract: Equatable, Sendable, Identifiable {
    public let id: String
    public let displayZH: String
    public let connector: String
    public let enabled: Bool
    public let availability: String
    public let capabilityIDs: [String]
    public let surfacePolicy: SurfacePolicy
}

public enum GeneratedCapabilityCatalog {
    public static let capabilities: [GeneratedCapabilityContract] = [
        GeneratedCapabilityContract(
            id: "cabin.ac",
            status: "active",
            displayZH: "空调",
            toolSchema: GeneratedToolSchema(
                name: "set_cabin_ac",
                description: "控制本地 mock 空调开关、温度和冷暖模式。",
                properties: ["delta": GeneratedToolProperty(type: "string", enumValues: ["warmer", "cooler", "none"], minimum: nil, maximum: nil), "mode": GeneratedToolProperty(type: "string", enumValues: ["auto", "cooling", "heating"], minimum: nil, maximum: nil), "power": GeneratedToolProperty(type: "string", enumValues: ["on", "off", "unchanged"], minimum: nil, maximum: nil), "target_temperature": GeneratedToolProperty(type: "integer", enumValues: [], minimum: 16, maximum: 30)],
                required: ["power"]
            ),
            referenceBinding: GeneratedReferenceBinding(
                readable: true,
                writable: true,
                valueType: "boolean",
                allowedValues: ["on", "off"]
            ),
            execution: GeneratedExecutionRule(
                connector: "local",
                mockBehavior: "update_mock_state",
                stateCell: "hvac.ac",
                relatedStateCells: ["hvac.temperature"],
                idempotent: true,
                exclusiveBus: "hvac",
                stateTransforms: [GeneratedStateTransform(field: "power", stateCell: "hvac.ac", unchangedSkip: true, ambientComposite: false), GeneratedStateTransform(field: "target_temperature", stateCell: "hvac.temperature", unchangedSkip: false, ambientComposite: false)]
            ),
            demoGuard: GeneratedDemoGuardRule(
                riskLevel: "R0",
                confirmPolicy: "none",
                writable: true,
                ranges: ["target_temperature": GeneratedIntegerRange(minimum: 16, maximum: 30)],
                enumValues: ["mode": ["auto", "cooling", "heating"], "power": ["on", "off", "unchanged"]],
                preconditions: []
            )
        ),
        GeneratedCapabilityContract(
            id: "cabin.seat_heating",
            status: "active",
            displayZH: "座椅加热",
            toolSchema: GeneratedToolSchema(
                name: "set_cabin_seat_heating",
                description: "调整本地 mock 座椅加热挡位。",
                properties: ["level": GeneratedToolProperty(type: "integer", enumValues: [], minimum: 0, maximum: 3), "position": GeneratedToolProperty(type: "string", enumValues: ["driver", "passenger", "all"], minimum: nil, maximum: nil)],
                required: ["position", "level"]
            ),
            referenceBinding: GeneratedReferenceBinding(
                readable: true,
                writable: true,
                valueType: "integer",
                allowedValues: ["0", "1", "2", "3"]
            ),
            execution: GeneratedExecutionRule(
                connector: "local",
                mockBehavior: "update_mock_state",
                stateCell: "seat.driver.heat",
                relatedStateCells: [],
                idempotent: true,
                exclusiveBus: "seat_comfort",
                stateTransforms: [GeneratedStateTransform(field: "level", stateCell: "seat.driver.heat", unchangedSkip: false, ambientComposite: false)]
            ),
            demoGuard: GeneratedDemoGuardRule(
                riskLevel: "R0",
                confirmPolicy: "none",
                writable: true,
                ranges: ["level": GeneratedIntegerRange(minimum: 0, maximum: 3)],
                enumValues: ["position": ["driver", "passenger", "all"]],
                preconditions: []
            )
        ),
        GeneratedCapabilityContract(
            id: "cabin.seat_ventilation",
            status: "active",
            displayZH: "座椅通风",
            toolSchema: GeneratedToolSchema(
                name: "set_cabin_seat_ventilation",
                description: "调整本地 mock 座椅通风挡位。",
                properties: ["level": GeneratedToolProperty(type: "integer", enumValues: [], minimum: 0, maximum: 3), "position": GeneratedToolProperty(type: "string", enumValues: ["driver", "passenger", "all"], minimum: nil, maximum: nil)],
                required: ["position", "level"]
            ),
            referenceBinding: GeneratedReferenceBinding(
                readable: true,
                writable: true,
                valueType: "integer",
                allowedValues: ["0", "1", "2", "3"]
            ),
            execution: GeneratedExecutionRule(
                connector: "local",
                mockBehavior: "update_mock_state",
                stateCell: "seat.driver.ventilation",
                relatedStateCells: [],
                idempotent: true,
                exclusiveBus: "seat_comfort",
                stateTransforms: [GeneratedStateTransform(field: "level", stateCell: "seat.driver.ventilation", unchangedSkip: false, ambientComposite: false)]
            ),
            demoGuard: GeneratedDemoGuardRule(
                riskLevel: "R0",
                confirmPolicy: "none",
                writable: true,
                ranges: ["level": GeneratedIntegerRange(minimum: 0, maximum: 3)],
                enumValues: ["position": ["driver", "passenger", "all"]],
                preconditions: []
            )
        ),
        GeneratedCapabilityContract(
            id: "cabin.window",
            status: "active",
            displayZH: "车窗",
            toolSchema: GeneratedToolSchema(
                name: "set_cabin_window",
                description: "调整本地 mock 车窗开度百分比。",
                properties: ["percent": GeneratedToolProperty(type: "integer", enumValues: [], minimum: 0, maximum: 100), "position": GeneratedToolProperty(type: "string", enumValues: ["driver", "passenger", "rear_left", "rear_right", "all"], minimum: nil, maximum: nil)],
                required: ["position", "percent"]
            ),
            referenceBinding: GeneratedReferenceBinding(
                readable: true,
                writable: true,
                valueType: "integer",
                allowedValues: []
            ),
            execution: GeneratedExecutionRule(
                connector: "local",
                mockBehavior: "update_mock_state",
                stateCell: "window.driver",
                relatedStateCells: [],
                idempotent: true,
                exclusiveBus: "window",
                stateTransforms: [GeneratedStateTransform(field: "percent", stateCell: "window.driver", unchangedSkip: false, ambientComposite: false)]
            ),
            demoGuard: GeneratedDemoGuardRule(
                riskLevel: "R1",
                confirmPolicy: "none",
                writable: true,
                ranges: ["percent": GeneratedIntegerRange(minimum: 0, maximum: 100)],
                enumValues: ["position": ["driver", "passenger", "rear_left", "rear_right", "all"]],
                preconditions: []
            )
        ),
        GeneratedCapabilityContract(
            id: "cabin.ambient_light",
            status: "active",
            displayZH: "氛围灯",
            toolSchema: GeneratedToolSchema(
                name: "set_cabin_ambient_light",
                description: "调整本地 mock 氛围灯开关和颜色。",
                properties: ["color": GeneratedToolProperty(type: "string", enumValues: ["warm", "cool", "blue", "amber", "white"], minimum: nil, maximum: nil), "power": GeneratedToolProperty(type: "string", enumValues: ["on", "off", "unchanged"], minimum: nil, maximum: nil)],
                required: ["power"]
            ),
            referenceBinding: GeneratedReferenceBinding(
                readable: true,
                writable: true,
                valueType: "string",
                allowedValues: ["off", "warm", "cool", "blue", "amber", "white"]
            ),
            execution: GeneratedExecutionRule(
                connector: "local",
                mockBehavior: "update_mock_state",
                stateCell: "lighting.ambient",
                relatedStateCells: [],
                idempotent: true,
                exclusiveBus: "lighting",
                stateTransforms: [GeneratedStateTransform(field: "power", stateCell: "lighting.ambient", unchangedSkip: true, ambientComposite: true)]
            ),
            demoGuard: GeneratedDemoGuardRule(
                riskLevel: "R0",
                confirmPolicy: "none",
                writable: true,
                ranges: [:],
                enumValues: ["color": ["warm", "cool", "blue", "amber", "white"], "power": ["on", "off", "unchanged"]],
                preconditions: []
            )
        ),
        GeneratedCapabilityContract(
            id: "cabin.screen_brightness",
            status: "active",
            displayZH: "屏幕亮度",
            toolSchema: GeneratedToolSchema(
                name: "set_cabin_screen_brightness",
                description: "调整本地 mock 中控屏幕亮度百分比。",
                properties: ["delta": GeneratedToolProperty(type: "string", enumValues: ["brighter", "dimmer", "none"], minimum: nil, maximum: nil), "percent": GeneratedToolProperty(type: "integer", enumValues: [], minimum: 0, maximum: 100)],
                required: ["percent"]
            ),
            referenceBinding: GeneratedReferenceBinding(
                readable: true,
                writable: true,
                valueType: "integer",
                allowedValues: []
            ),
            execution: GeneratedExecutionRule(
                connector: "local",
                mockBehavior: "update_mock_state",
                stateCell: "screen.brightness",
                relatedStateCells: [],
                idempotent: true,
                exclusiveBus: "display",
                stateTransforms: [GeneratedStateTransform(field: "percent", stateCell: "screen.brightness", unchangedSkip: false, ambientComposite: false)]
            ),
            demoGuard: GeneratedDemoGuardRule(
                riskLevel: "R0",
                confirmPolicy: "none",
                writable: true,
                ranges: ["percent": GeneratedIntegerRange(minimum: 0, maximum: 100)],
                enumValues: ["delta": ["brighter", "dimmer", "none"]],
                preconditions: []
            )
        ),
        GeneratedCapabilityContract(
            id: "cabin.fan",
            status: "active",
            displayZH: "风量",
            toolSchema: GeneratedToolSchema(
                name: "set_cabin_fan",
                description: "调整本地 mock 空调风量挡位。",
                properties: ["level": GeneratedToolProperty(type: "integer", enumValues: [], minimum: 0, maximum: 5)],
                required: ["level"]
            ),
            referenceBinding: GeneratedReferenceBinding(
                readable: true,
                writable: true,
                valueType: "integer",
                allowedValues: ["0", "1", "2", "3", "4", "5"]
            ),
            execution: GeneratedExecutionRule(
                connector: "local",
                mockBehavior: "update_mock_state",
                stateCell: "fan.speed",
                relatedStateCells: [],
                idempotent: true,
                exclusiveBus: "hvac",
                stateTransforms: [GeneratedStateTransform(field: "level", stateCell: "fan.speed", unchangedSkip: false, ambientComposite: false)]
            ),
            demoGuard: GeneratedDemoGuardRule(
                riskLevel: "R0",
                confirmPolicy: "none",
                writable: true,
                ranges: ["level": GeneratedIntegerRange(minimum: 0, maximum: 5)],
                enumValues: [:],
                preconditions: []
            )
        ),
        GeneratedCapabilityContract(
            id: "cabin.comfort_query",
            status: "active",
            displayZH: "舒适状态查询",
            toolSchema: GeneratedToolSchema(
                name: "query_cabin_comfort",
                description: "读取本地 mock 舒适状态,不写入车控状态。",
                properties: ["topic": GeneratedToolProperty(type: "string", enumValues: ["temperature", "hvac", "seat", "all"], minimum: nil, maximum: nil)],
                required: ["topic"]
            ),
            referenceBinding: GeneratedReferenceBinding(
                readable: true,
                writable: false,
                valueType: "integer",
                allowedValues: []
            ),
            execution: GeneratedExecutionRule(
                connector: "local",
                mockBehavior: "read_mock_state",
                stateCell: "hvac.temperature",
                relatedStateCells: [],
                idempotent: true,
                exclusiveBus: "none",
                stateTransforms: []
            ),
            demoGuard: GeneratedDemoGuardRule(
                riskLevel: "R0",
                confirmPolicy: "none",
                writable: false,
                ranges: [:],
                enumValues: ["topic": ["temperature", "hvac", "seat", "all"]],
                preconditions: []
            )
        )
    ]

    public static let agents: [GeneratedAgentContract] = [
        GeneratedAgentContract(
            id: "vehicle-control",
            displayZH: "车控",
            connector: "local",
            enabled: true,
            availability: "available",
            capabilityIDs: ["cabin.ac", "cabin.seat_heating", "cabin.seat_ventilation", "cabin.window", "cabin.ambient_light", "cabin.screen_brightness", "cabin.fan", "cabin.comfort_query"],
            surfacePolicy: .primaryPanel
        ),
        GeneratedAgentContract(
            id: "navigation",
            displayZH: "导航",
            connector: "mock",
            enabled: false,
            availability: "planned",
            capabilityIDs: [],
            surfacePolicy: .overlayCard
        ),
        GeneratedAgentContract(
            id: "music",
            displayZH: "音乐",
            connector: "mock",
            enabled: false,
            availability: "planned",
            capabilityIDs: [],
            surfacePolicy: .overlayCard
        ),
        GeneratedAgentContract(
            id: "food-delivery",
            displayZH: "外卖",
            connector: "mock",
            enabled: false,
            availability: "planned",
            capabilityIDs: [],
            surfacePolicy: .overlayCard
        )
    ]

    public static let toolNameToCapabilityID: [String: String] = ["query_cabin_comfort": "cabin.comfort_query", "set_cabin_ac": "cabin.ac", "set_cabin_ambient_light": "cabin.ambient_light", "set_cabin_fan": "cabin.fan", "set_cabin_screen_brightness": "cabin.screen_brightness", "set_cabin_seat_heating": "cabin.seat_heating", "set_cabin_seat_ventilation": "cabin.seat_ventilation", "set_cabin_window": "cabin.window"]
    public static let capabilityIDToAgentID: [String: String] = ["cabin.ac": "vehicle-control", "cabin.ambient_light": "vehicle-control", "cabin.comfort_query": "vehicle-control", "cabin.fan": "vehicle-control", "cabin.screen_brightness": "vehicle-control", "cabin.seat_heating": "vehicle-control", "cabin.seat_ventilation": "vehicle-control", "cabin.window": "vehicle-control"]
    public static let capabilityIDToSurfacePolicy: [String: SurfacePolicy] = ["cabin.ac": .primaryPanel, "cabin.ambient_light": .primaryPanel, "cabin.comfort_query": .primaryPanel, "cabin.fan": .primaryPanel, "cabin.screen_brightness": .primaryPanel, "cabin.seat_heating": .primaryPanel, "cabin.seat_ventilation": .primaryPanel, "cabin.window": .primaryPanel]
    public static let toolNameToAgentID: [String: String] = ["query_cabin_comfort": "vehicle-control", "set_cabin_ac": "vehicle-control", "set_cabin_ambient_light": "vehicle-control", "set_cabin_fan": "vehicle-control", "set_cabin_screen_brightness": "vehicle-control", "set_cabin_seat_heating": "vehicle-control", "set_cabin_seat_ventilation": "vehicle-control", "set_cabin_window": "vehicle-control"]
    public static let toolNameToSurfacePolicy: [String: SurfacePolicy] = ["query_cabin_comfort": .primaryPanel, "set_cabin_ac": .primaryPanel, "set_cabin_ambient_light": .primaryPanel, "set_cabin_fan": .primaryPanel, "set_cabin_screen_brightness": .primaryPanel, "set_cabin_seat_heating": .primaryPanel, "set_cabin_seat_ventilation": .primaryPanel, "set_cabin_window": .primaryPanel]

    public static func capability(id: String) -> GeneratedCapabilityContract? {
        capabilities.first { $0.id == id }
    }

    public static func capability(toolName: String) -> GeneratedCapabilityContract? {
        guard let capabilityID = toolNameToCapabilityID[toolName] else {
            return nil
        }
        return capability(id: capabilityID)
    }
}
