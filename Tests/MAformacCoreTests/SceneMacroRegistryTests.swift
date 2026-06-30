import XCTest
@testable import MAformacCore

final class SceneMacroRegistryTests: XCTestCase {
    func testDefaultRegistryExposesFiniteStableNames() throws {
        let registry = SceneMacroRegistry()

        XCTAssertEqual(SceneMacroRegistry.version, "d16.scene_macro_registry.v1")
        XCTAssertEqual(
            registry.stableConfigKeys.map(\.rawValue),
            [
                "scene_macro_registry.version",
                "scene_macro_registry.stable_names",
                "d17.consumer_authority"
            ]
        )
        XCTAssertEqual(
            registry.stableSceneMacroNames.map(\.rawValue),
            [
                "scene1.human_language_comfort",
                "scene2.multi_intent_comfort",
                "scene3.followup_window_memory",
                "scene4.driver_window_generalization",
                "scene5.driving_safety_refusal"
            ]
        )
    }

    func testKnownSceneMacroCarriesMainOwnedDefinitionAndNoReadinessCaps() throws {
        let registry = SceneMacroRegistry()
        let definition = try registry.definition(named: "scene5.driving_safety_refusal")

        XCTAssertEqual(definition.scenarioID, "scene5")
        XCTAssertEqual(definition.title, "关键时刻拦得住")
        XCTAssertEqual(definition.requiredStateCells, ["vehicle.speed", "vehicle.gear"])
        XCTAssertEqual(definition.stableToolNames, [])
        XCTAssertEqual(definition.proofClass, .localUnit)
        XCTAssertTrue(definition.proofClass.displayCaps.isEmpty)
    }

    func testUnknownConfigAndMacroNamesFailClosed() throws {
        let registry = SceneMacroRegistry()

        XCTAssertThrowsError(try registry.configKey(named: "uiue.local.config")) { error in
            XCTAssertEqual(error as? SceneMacroRegistryError, .unknownConfigKey("uiue.local.config"))
        }

        XCTAssertThrowsError(try registry.definition(named: "scene6.uiue_invented")) { error in
            XCTAssertEqual(error as? SceneMacroRegistryError, .unknownSceneMacroName("scene6.uiue_invented"))
        }

        XCTAssertFalse(registry.containsD17ConsumableName("DemoRuntimeAdapter.failureLedger"))
        XCTAssertFalse(registry.containsD17ConsumableName("runtime_ready"))
    }

    func testD17ConsumableNamesAreOnlyStableConfigAndMacroNames() {
        let registry = SceneMacroRegistry()

        XCTAssertTrue(registry.containsD17ConsumableName("d17.consumer_authority"))
        XCTAssertTrue(registry.containsD17ConsumableName("scene1.human_language_comfort"))
        XCTAssertTrue(registry.containsD17ConsumableName("scene5.driving_safety_refusal"))

        let forbiddenNames = [
            "DemoRuntimeAdapter",
            "RuntimeAdapterBox",
            "requestFingerprint",
            "parentRequestFingerprint",
            "failureLedger",
            "runtimeStore",
            "rawModelOutput",
            "trainingReceipt",
            "true_device_ready",
            "V-PASS"
        ]

        for forbiddenName in forbiddenNames {
            XCTAssertFalse(registry.containsD17ConsumableName(forbiddenName), forbiddenName)
        }
    }
}
