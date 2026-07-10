import Foundation
import XCTest
@testable import MAformacCore

final class RuntimeFiniteReasonAuthorityTests: XCTestCase {
    func testDDomainFailuresUseLockedTypedMappings() {
        let cases: [(DDomainToolPlanFailure, RuntimeFiniteReason, DDomainDecodeFailureKind)] = [
            (.parseFailed, .unsupportedToolPlan, .parseFailed),
            (.nameRejected("secret_raw_tool_name"), .nameRejected, .nameRejected),
            (.irUnclassified("secret_raw_tool_name"), .unsupportedToolPlan, .irUnclassified),
            (.bridgeFailed("secret_bridge_detail"), .unsupportedToolPlan, .bridgeFailed),
        ]

        for (failure, finiteReason, decodeFailureKind) in cases {
            XCTAssertEqual(failure.finiteReason, finiteReason)
            XCTAssertEqual(failure.decodeFailureKind, decodeFailureKind)
        }
    }

    func testRuntimeFiniteReasonRejectsOutsideT0AtDecodeBoundary() throws {
        XCTAssertEqual(RuntimeFiniteReason.allCases.count, 10)
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                RuntimeFiniteReason.self,
                from: Data(#""w1_non_t0_reason""#.utf8)
            )
        )
    }

    func testTraceEncodesFiniteReasonAndDecodeFailureKindAsSeparateTypedFields() throws {
        let attributes = TraceAttributes(
            finiteReason: .unsupportedToolPlan,
            decodeFailureKind: .parseFailed
        )
        let data = try JSONEncoder().encode(attributes)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(object["finiteReason"] as? String, "unsupported_tool_plan")
        XCTAssertEqual(object["decodeFailureKind"] as? String, "parse_failed")

        let traceID = "trace-runtime-finite-reason-authority"
        let envelope = try XCTUnwrap(
            TraceEnvelope(
                traceID: traceID,
                entries: [
                    TraceEntry(
                        stage: .guard,
                        traceID: traceID,
                        message: "unsupported_tool_plan",
                        attributes: attributes,
                        timestamp: Date(timeIntervalSince1970: 1_800_002_000)
                    )
                ]
            )
        )
        let safeAttributes = try XCTUnwrap(envelope.presentationSafe().entries.first?.attributes)
        XCTAssertNil(safeAttributes.finiteReason)
        XCTAssertNil(safeAttributes.decodeFailureKind)
        XCTAssertEqual(safeAttributes.guardReason, RuntimePresentationSafeReasonKind.notAvailableInDemo.rawValue)
    }

    func testFallbackResolutionMatchesHardcodedTenReasonScriptTable() {
        // Intentionally hard-coded: deriving this oracle from projection/fallbackBucket would be self-referential.
        let cases: [(
            finiteReason: RuntimeFiniteReason,
            result: DemoRuntimeResult,
            safeReason: RuntimePresentationSafeReasonKind,
            dialogText: String,
            badgeLabel: String
        )] = [
            (
                .safetyOrPolicyRefusal,
                .refusalSafetyOrPolicy,
                .safetyPolicy,
                "当前状态下不能执行这项操作，车辆状态保持不变。",
                "安全限制"
            ),
            (
                .clarifyMissingSlot,
                .clarifyMissingSlot,
                .clarificationRequired,
                "请先确认温区或目标温度，我先保持空调状态不变。",
                "需确认"
            ),
            (
                .unmountedToolName,
                .refusalNoAvailableTool,
                .capabilityNotMounted,
                "这项空调控制暂未接入演示版，我先不改车内状态。",
                "暂未接入"
            ),
            (
                .nameRejected,
                .refusalNoAvailableTool,
                .capabilityNotMounted,
                "这项空调控制暂未接入演示版，我先不改车内状态。",
                "暂未接入"
            ),
            (
                .fastPathNoMatch,
                .refusalNoAvailableTool,
                .notAvailableInDemo,
                "这个空调说法还没稳稳接住，您可以说空调调到26度。",
                "换个说法"
            ),
            (
                .unsupportedToolPlan,
                .refusalNoAvailableTool,
                .notAvailableInDemo,
                "这个空调说法还没稳稳接住，您可以说空调调到26度。",
                "换个说法"
            ),
            (
                .noRepresentativeTool,
                .refusalNoAvailableTool,
                .notAvailableInDemo,
                "这类空调能力不在本轮演示范围，我先保持原样。",
                "不在范围"
            ),
            (
                .runtimeExecutionError,
                .runtimeError,
                .runtimeUnavailable,
                "当前运行状态不可用，请稍后重试。",
                "暂不可用"
            ),
            (
                .staleStateRevision,
                .runtimeError,
                .runtimeUnavailable,
                "当前运行状态不可用，请稍后重试。",
                "暂不可用"
            ),
            (
                .alreadyStateNoop,
                .alreadyStateNoop,
                .alreadyDone,
                "当前已经是目标状态，无需重复操作。",
                "已完成"
            ),
        ]

        XCTAssertEqual(cases.count, 10)
        for expected in cases {
            let context = FallbackContext.resolve(userText: "空调", finiteReason: expected.finiteReason)

            XCTAssertEqual(context.family, .ac, expected.finiteReason.rawValue)
            XCTAssertEqual(context.outcome.resultKind, expected.result, expected.finiteReason.rawValue)
            XCTAssertEqual(context.outcome.safeReasonKind, expected.safeReason, expected.finiteReason.rawValue)
            XCTAssertEqual(context.dialogText, expected.dialogText, expected.finiteReason.rawValue)
            XCTAssertEqual(context.ttsText, expected.dialogText, expected.finiteReason.rawValue)
            XCTAssertEqual(context.badgeLabel, expected.badgeLabel, expected.finiteReason.rawValue)
        }
    }

    func testTraceRoundTripsHardcodedTenFiniteReasonsEndToEnd() throws {
        // Intentionally hard-coded so trace projection drift cannot update its own expected values.
        let cases: [(
            finiteReason: RuntimeFiniteReason,
            rawValue: String,
            safeReason: String
        )] = [
            (.safetyOrPolicyRefusal, "safety_or_policy_refusal", "safety_policy"),
            (.clarifyMissingSlot, "clarify_missing_slot", "clarification_required"),
            (.unmountedToolName, "unmounted_tool_name", "capability_not_mounted"),
            (.nameRejected, "name_rejected", "capability_not_mounted"),
            (.fastPathNoMatch, "fast_path_no_match", "not_available_in_demo"),
            (.unsupportedToolPlan, "unsupported_tool_plan", "not_available_in_demo"),
            (.noRepresentativeTool, "no_representative_tool", "not_available_in_demo"),
            (.runtimeExecutionError, "runtime_execution_error", "runtime_unavailable"),
            (.staleStateRevision, "stale_state_revision", "runtime_unavailable"),
            (.alreadyStateNoop, "already_state_noop", "already_done"),
        ]

        XCTAssertEqual(cases.count, 10)
        for expected in cases {
            let traceID = "trace-hardcoded-\(expected.rawValue)"
            let attributes = TraceAttributes(finiteReason: expected.finiteReason)
            let encodedAttributes = try JSONEncoder().encode(attributes)
            let decodedAttributes = try JSONDecoder().decode(TraceAttributes.self, from: encodedAttributes)
            let attributesObject = try XCTUnwrap(
                JSONSerialization.jsonObject(with: encodedAttributes) as? [String: Any]
            )

            XCTAssertEqual(decodedAttributes.finiteReason, expected.finiteReason, expected.rawValue)
            XCTAssertEqual(attributesObject["finiteReason"] as? String, expected.rawValue)

            let envelope = try XCTUnwrap(
                TraceEnvelope(
                    traceID: traceID,
                    entries: [
                        TraceEntry(
                            stage: .guard,
                            traceID: traceID,
                            message: "hardcoded finite reason behavior oracle",
                            attributes: decodedAttributes,
                            timestamp: Date(timeIntervalSince1970: 1_800_003_000)
                        )
                    ]
                )
            )
            let safeAttributes = try XCTUnwrap(envelope.presentationSafe().entries.first?.attributes)

            XCTAssertNil(safeAttributes.finiteReason, expected.rawValue)
            XCTAssertEqual(safeAttributes.guardReason, expected.safeReason, expected.rawValue)
        }
    }

    @MainActor
    func testPublicPayloadDoesNotLeakDecodeDiagnosticOrRejectedName() async throws {
        let rawRejectedName = "secret_raw_tool_name"
        let runner = try DemoRuntimeSessionRunner.defaultRunner(
            store: DemoVehicleStateStore(),
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine(),
            modelBackend: RejectingBackend(failure: .nameRejected(rawRejectedName))
        )

        let payload = try await runner.run(text: "打开一个未挂载工具")
        let data = try JSONEncoder().encode(payload)
        let text = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertFalse(text.contains(rawRejectedName), text)
        XCTAssertFalse(text.contains(DDomainDecodeFailureKind.nameRejected.rawValue), text)
        XCTAssertTrue(text.contains(RuntimePresentationSafeReasonKind.capabilityNotMounted.rawValue), text)
    }
}

private struct RejectingBackend: LLMBackend {
    let failure: DDomainToolPlanFailure

    func load() async throws {}
    func generateToolPlan(for request: ToolPlanRequest) async throws -> [ToolCallFrame] { throw failure }
    func streamText(for prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { $0.finish() }
    }
    func cancel() {}
}
