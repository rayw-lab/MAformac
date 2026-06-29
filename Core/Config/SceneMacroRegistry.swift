import Foundation

public enum CoreConfigKey: String, CaseIterable, Codable, Equatable, Sendable {
    case sceneMacroRegistryVersion = "scene_macro_registry.version"
    case stableSceneMacroNames = "scene_macro_registry.stable_names"
    case d17ConsumerAuthority = "d17.consumer_authority"
}

public enum SceneMacroName: String, CaseIterable, Codable, Equatable, Sendable {
    case humanLanguageComfort = "scene1.human_language_comfort"
    case multiIntentComfort = "scene2.multi_intent_comfort"
    case followupWindowMemory = "scene3.followup_window_memory"
    case driverWindowGeneralization = "scene4.driver_window_generalization"
    case drivingSafetyRefusal = "scene5.driving_safety_refusal"
}

public enum SceneMacroRegistryError: Error, Equatable, Sendable {
    case unknownConfigKey(String)
    case unknownSceneMacroName(String)
}

public struct SceneMacroDefinition: Codable, Equatable, Sendable {
    public let name: SceneMacroName
    public let scenarioID: String
    public let title: String
    public let requiredStateCells: [String]
    public let stableToolNames: [String]
    public var proofClass: PresentationProofClass { .localUnit }

    public init(
        name: SceneMacroName,
        scenarioID: String,
        title: String,
        requiredStateCells: [String],
        stableToolNames: [String]
    ) {
        self.name = name
        self.scenarioID = scenarioID
        self.title = title
        self.requiredStateCells = requiredStateCells
        self.stableToolNames = stableToolNames
    }
}

public struct SceneMacroRegistry: Sendable {
    public static let version = "d16.scene_macro_registry.v1"

    private let definitionsByName: [SceneMacroName: SceneMacroDefinition]

    public init(definitions: [SceneMacroDefinition] = SceneMacroRegistry.defaultDefinitions) {
        self.definitionsByName = Dictionary(uniqueKeysWithValues: definitions.map { ($0.name, $0) })
    }

    public var stableConfigKeys: [CoreConfigKey] {
        CoreConfigKey.allCases
    }

    public var stableSceneMacroNames: [SceneMacroName] {
        definitionsByName.keys.sorted { $0.rawValue < $1.rawValue }
    }

    public var d17ConsumableNames: Set<String> {
        Set(stableConfigKeys.map(\.rawValue) + stableSceneMacroNames.map(\.rawValue))
    }

    public func configKey(named rawValue: String) throws -> CoreConfigKey {
        guard let key = CoreConfigKey(rawValue: rawValue) else {
            throw SceneMacroRegistryError.unknownConfigKey(rawValue)
        }
        return key
    }

    public func definition(named rawValue: String) throws -> SceneMacroDefinition {
        guard let name = SceneMacroName(rawValue: rawValue),
              let definition = definitionsByName[name] else {
            throw SceneMacroRegistryError.unknownSceneMacroName(rawValue)
        }
        return definition
    }

    public func containsD17ConsumableName(_ rawValue: String) -> Bool {
        d17ConsumableNames.contains(rawValue)
    }

    public static let defaultDefinitions: [SceneMacroDefinition] = [
        SceneMacroDefinition(
            name: .humanLanguageComfort,
            scenarioID: "scene1",
            title: "听得懂人话",
            requiredStateCells: ["ac.power", "ac.temp_setpoint", "screen.brightness"],
            stableToolNames: ["open_ac", "raise_ac_temperature_by_exp", "raise_screen_brightness_little"]
        ),
        SceneMacroDefinition(
            name: .multiIntentComfort,
            scenarioID: "scene2",
            title: "一句顶三句",
            requiredStateCells: ["ac.power", "ac.temp_setpoint", "ambient.color", "ambient.brightness"],
            stableToolNames: ["open_ac", "adjust_ac_temperature_to_number", "switch_atmosphere_lamp_color", "lower_atmosphere_lamp_brightness_little"]
        ),
        SceneMacroDefinition(
            name: .followupWindowMemory,
            scenarioID: "scene3",
            title: "记得上文",
            requiredStateCells: ["window.position"],
            stableToolNames: ["open_window", "open_window_little"]
        ),
        SceneMacroDefinition(
            name: .driverWindowGeneralization,
            scenarioID: "scene4",
            title: "没教过也会",
            requiredStateCells: ["window.position"],
            stableToolNames: ["open_window"]
        ),
        SceneMacroDefinition(
            name: .drivingSafetyRefusal,
            scenarioID: "scene5",
            title: "关键时刻拦得住",
            requiredStateCells: ["vehicle.speed", "vehicle.gear"],
            stableToolNames: []
        )
    ]
}
