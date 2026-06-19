import XCTest
@testable import MAformacCore

final class GeneratedCapabilityCatalogTests: XCTestCase {
    func testGeneratedCatalogContainsEightCapabilitiesAndFourAgents() {
        XCTAssertEqual(GeneratedCapabilityCatalog.capabilities.count, 8)
        XCTAssertEqual(GeneratedCapabilityCatalog.agents.count, 4)
    }

    func testGeneratedLookupTablesMapToolToCapabilityAgentAndSurfacePolicy() throws {
        XCTAssertEqual(GeneratedCapabilityCatalog.toolNameToCapabilityID["set_cabin_ac"], "cabin.ac")
        XCTAssertEqual(GeneratedCapabilityCatalog.capabilityIDToAgentID["cabin.ac"], "vehicle-control")
        XCTAssertEqual(GeneratedCapabilityCatalog.capabilityIDToSurfacePolicy["cabin.ac"], .primaryPanel)
    }

    func testGeneratedGuardAndExecutionRulesMatchCabinACContract() throws {
        let capability = try XCTUnwrap(GeneratedCapabilityCatalog.capability(id: "cabin.ac"))

        XCTAssertEqual(capability.toolSchema.name, "set_cabin_ac")
        XCTAssertEqual(capability.toolSchema.required, ["power"])
        XCTAssertEqual(capability.toolSchema.properties["power"]?.enumValues, ["on", "off", "unchanged"])
        XCTAssertEqual(capability.demoGuard.riskLevel, "R0")
        XCTAssertEqual(capability.demoGuard.confirmPolicy, "none")
        XCTAssertEqual(capability.demoGuard.writable, true)
        XCTAssertEqual(capability.demoGuard.ranges["target_temperature"], GeneratedIntegerRange(minimum: 16, maximum: 30))
        XCTAssertEqual(capability.execution.stateCell, "hvac.ac")
        XCTAssertEqual(capability.referenceBinding.writable, true)
    }
}
