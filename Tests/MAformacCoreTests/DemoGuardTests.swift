import XCTest
@testable import MAformacCore

final class DemoGuardTests: XCTestCase {
    func testGeneratedSchemaGuardAllowsValidCabinACFrame() {
        let guardrail = DemoSchemaGuard()
        let frame = frame(toolName: "set_cabin_ac", capabilityID: "cabin.ac", arguments: ["power": .string("on")])

        XCTAssertEqual(guardrail.evaluate(frame), .allow(reason: "schema_valid"))
    }

    func testGeneratedSchemaGuardRejectsUnsafeSchemaCases() {
        let guardrail = DemoSchemaGuard()
        let cases: [(ToolCallFrame, DemoGuardDecision)] = [
            (
                frame(toolName: "unknown_tool", capabilityID: "cabin.ac", arguments: [:]),
                .deny(reason: "unknown_tool")
            ),
            (
                frame(toolName: "set_cabin_ac", capabilityID: "cabin.ac", arguments: ["power": .string("on"), "target_temperature": .int(31)]),
                .deny(reason: "out_of_range")
            ),
            (
                frame(toolName: "set_cabin_ac", capabilityID: "cabin.ac", arguments: ["power": .string("invalid")]),
                .deny(reason: "invalid_enum")
            )
        ]

        for (frame, expectedDecision) in cases {
            XCTAssertEqual(guardrail.evaluate(frame), expectedDecision)
        }
    }

    func testReadMockStateCapabilityIsAllowedWithoutWritableBinding() {
        let guardrail = DemoSchemaGuard()
        let frame = frame(
            toolName: "query_cabin_comfort",
            capabilityID: "cabin.comfort_query",
            arguments: ["topic": .string("temperature")]
        )

        XCTAssertEqual(guardrail.evaluate(frame), .allow(reason: "schema_valid"))
    }

    func testSyntheticRiskConfirmationAndExclusiveBusRulesDenyBeforeExecution() {
        let syntheticCapability = GeneratedCapabilityContract(
            id: "synthetic.r2",
            status: "active",
            displayZH: "合成 R2",
            toolSchema: GeneratedToolSchema(
                name: "set_synthetic_r2",
                description: "Synthetic R2 fixture.",
                properties: ["power": GeneratedToolProperty(type: "string", enumValues: ["on"], minimum: nil, maximum: nil)],
                required: ["power"]
            ),
            referenceBinding: GeneratedReferenceBinding(readable: true, writable: true, valueType: "boolean", allowedValues: ["on"]),
            execution: GeneratedExecutionRule(
                connector: "local",
                mockBehavior: "update_mock_state",
                stateCell: "hvac.ac",
                relatedStateCells: [],
                idempotent: true,
                exclusiveBus: "hvac",
                stateTransforms: []
            ),
            demoGuard: GeneratedDemoGuardRule(
                riskLevel: "R2",
                confirmPolicy: "explicit",
                writable: true,
                ranges: [:],
                enumValues: ["power": ["on"]],
                preconditions: ["demo_mode_enabled"]
            )
        )
        let guardrail = DemoSchemaGuard(
            capabilities: [syntheticCapability],
            capabilityIDToAgentID: ["synthetic.r2": "vehicle-control"],
            capabilityIDToSurfacePolicy: ["synthetic.r2": .primaryPanel]
        )
        let frame = frame(toolName: "set_synthetic_r2", capabilityID: "synthetic.r2", arguments: ["power": .string("on")])

        XCTAssertEqual(guardrail.evaluate(frame), .deny(reason: "confirmation_required"))
        XCTAssertEqual(
            guardrail.evaluate(frame, context: DemoGuardContext(confirmedCapabilityIDs: ["synthetic.r2"])),
            .deny(reason: "precondition_missing:demo_mode_enabled")
        )
        XCTAssertEqual(
            guardrail.evaluate(
                frame,
                context: DemoGuardContext(
                    confirmedCapabilityIDs: ["synthetic.r2"],
                    satisfiedPreconditions: ["demo_mode_enabled"],
                    occupiedExclusiveBuses: ["hvac"]
                )
            ),
            .deny(reason: "exclusive_bus_conflict:hvac")
        )
    }

    private func frame(
        toolName: String,
        capabilityID: String,
        arguments: [String: JSONValue]
    ) -> ToolCallFrame {
        ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: capabilityID,
            toolName: toolName,
            arguments: arguments,
            surfacePolicy: .primaryPanel
        )
    }
}
