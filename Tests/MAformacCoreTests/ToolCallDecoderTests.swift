import XCTest
@testable import MAformacCore

final class ToolCallDecoderTests: XCTestCase {
    func testRawToolCallCandidateMapsFrameFieldsFromGeneratedCatalog() throws {
        let decoder = ToolCallDecoder()
        let candidate = ToolCallCandidate(
            toolName: "set_cabin_ac",
            arguments: ["power": .string("on")],
            source: .rawToolCall,
            stopReason: "stop"
        )

        let frame = try decoder.decode(candidate)

        XCTAssertEqual(frame.toolName, "set_cabin_ac")
        XCTAssertEqual(frame.capabilityID, "cabin.ac")
        XCTAssertEqual(frame.agentID, "vehicle-control")
        XCTAssertEqual(frame.surfacePolicy, .primaryPanel)
        XCTAssertEqual(frame.arguments["power"], .string("on"))
    }

    func testDecodeErrorsAreTableDrivenAndSpecific() {
        let decoder = ToolCallDecoder()
        let cases: [(String, ToolCallDecodeError)] = [
            ("no_tool_call", .no_tool_call),
            ("malformed", .malformed("bad_json")),
            ("unknown_tool", .schema_invalid(.unknown_tool("unknown_tool"))),
            ("missing_field", .schema_invalid(.missing_field(toolName: "set_cabin_ac", field: "power"))),
            ("type_mismatch", .schema_invalid(.type_mismatch(toolName: "set_cabin_ac", field: "power", expected: "string", actual: "int"))),
            ("out_of_range", .schema_invalid(.out_of_range(toolName: "set_cabin_ac", field: "target_temperature", minimum: 16, maximum: 30, actual: 31)))
        ]

        XCTAssertEqual(cases.map(\.0), ToolCallDecodeFailureKind.acceptanceTable.map(\.rawValue))
        XCTAssertEqual(decoder.failureKind(for: .no_tool_call), .no_tool_call)
        XCTAssertEqual(decoder.failureKind(for: .malformed("bad_json")), .malformed)
        XCTAssertEqual(decoder.failureKind(for: .schema_invalid(.unknown_tool("unknown_tool"))), .unknown_tool)
        XCTAssertEqual(decoder.failureKind(for: .schema_invalid(.missing_field(toolName: "set_cabin_ac", field: "power"))), .missing_field)
        XCTAssertEqual(decoder.failureKind(for: .schema_invalid(.type_mismatch(toolName: "set_cabin_ac", field: "power", expected: "string", actual: "int"))), .type_mismatch)
        XCTAssertEqual(decoder.failureKind(for: .schema_invalid(.out_of_range(toolName: "set_cabin_ac", field: "target_temperature", minimum: 16, maximum: 30, actual: 31))), .out_of_range)
    }

    func testSchemaInvalidCasesAreRejectedBeforeExecution() {
        let decoder = ToolCallDecoder()
        let invalidCases: [(ToolCallCandidate, ToolCallDecodeError)] = [
            (
                ToolCallCandidate(toolName: "unknown_tool", arguments: [:], source: .rawToolCall),
                .schema_invalid(.unknown_tool("unknown_tool"))
            ),
            (
                ToolCallCandidate(toolName: "set_cabin_ac", arguments: [:], source: .rawToolCall),
                .schema_invalid(.missing_field(toolName: "set_cabin_ac", field: "power"))
            ),
            (
                ToolCallCandidate(toolName: "set_cabin_ac", arguments: ["power": .int(1)], source: .rawToolCall),
                .schema_invalid(.type_mismatch(toolName: "set_cabin_ac", field: "power", expected: "string", actual: "int"))
            ),
            (
                ToolCallCandidate(toolName: "set_cabin_ac", arguments: ["power": .string("on"), "target_temperature": .int(31)], source: .rawToolCall),
                .schema_invalid(.out_of_range(toolName: "set_cabin_ac", field: "target_temperature", minimum: 16, maximum: 30, actual: 31))
            ),
            (
                ToolCallCandidate(toolName: "set_cabin_ac", arguments: ["power": .string("invalid")], source: .rawToolCall),
                .schema_invalid(.type_mismatch(toolName: "set_cabin_ac", field: "power", expected: "enum:on|off|unchanged", actual: "invalid"))
            )
        ]

        for (candidate, expectedError) in invalidCases {
            XCTAssertThrowsError(try decoder.decode(candidate)) { error in
                XCTAssertEqual(error as? ToolCallDecodeError, expectedError)
            }
        }
    }

    func testContentFallbackExtractsOnlySingleBareJSONCandidate() throws {
        let decoder = ToolCallDecoder(contentFallbackEnabled: true)
        let content = #"{"name":"set_cabin_ac","arguments":{"power":"off"}}"#

        let candidate = try XCTUnwrap(decoder.contentFallbackCandidate(from: content, stopReason: "stop"))

        XCTAssertEqual(candidate.toolName, "set_cabin_ac")
        XCTAssertEqual(candidate.arguments, ["power": .string("off")])
        XCTAssertEqual(candidate.source, .contentFallback)
        XCTAssertNil(try decoder.contentFallbackCandidate(from: #"prefix {"name":"set_cabin_ac","arguments":{"power":"off"}}"#, stopReason: "stop"))
    }

    func testCandidateArgumentNormalizationPreservesSyntheticBoundaryShapes() throws {
        let stringifiedObject = try ToolCallCandidate(
            toolName: "set_cabin_ac",
            argumentsValue: .string(#"{"power":"on","extras":["front",2],"scalar":5}"#),
            source: .rawToolCall
        )
        let arrayArgument = try ToolCallCandidate(
            toolName: "set_cabin_ac",
            argumentsValue: .array([.string("front"), .int(2)]),
            source: .rawToolCall
        )
        let scalarArgument = try ToolCallCandidate(
            toolName: "set_cabin_ac",
            argumentsValue: .int(2),
            source: .rawToolCall
        )

        XCTAssertEqual(stringifiedObject.arguments["extras"], .array([.string("front"), .int(2)]))
        XCTAssertEqual(stringifiedObject.arguments["scalar"], .int(5))
        XCTAssertEqual(arrayArgument.arguments, ["_value": .array([.string("front"), .int(2)])])
        XCTAssertEqual(scalarArgument.arguments, ["_value": .int(2)])
    }

    func testUnknownModelStopReasonDecodesAsUnknownInsteadOfThrowing() throws {
        struct Envelope: Decodable {
            let stopReason: ToolCallStopReason
        }

        let data = Data(#"{"stopReason":"model_specific_finish"}"#.utf8)

        let decoded = try JSONDecoder().decode(Envelope.self, from: data)

        XCTAssertEqual(decoded.stopReason, .unknown("model_specific_finish"))
    }

    func testRetryPolicyAllowsMalformedOnceOnly() {
        let policy = ToolCallDecodeRetryPolicy(maxMalformedRetries: 1)

        XCTAssertEqual(policy.decision(for: .malformed("bad_json"), priorMalformedRetries: 0), .retry)
        XCTAssertEqual(policy.decision(for: .malformed("bad_json"), priorMalformedRetries: 1), .clarify)
        XCTAssertEqual(policy.decision(for: .no_tool_call, priorMalformedRetries: 0), .clarify)
        XCTAssertEqual(policy.decision(for: .schema_invalid(.missing_field(toolName: "set_cabin_ac", field: "power")), priorMalformedRetries: 0), .clarify)
    }
}
