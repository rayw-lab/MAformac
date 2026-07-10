import XCTest
@testable import MAformacCore

final class RuntimeTraceFallbackTests: XCTestCase {
    func testPartialReceiptPreservesInternalFactsAndObservedStateMutation() throws {
        let writer = InternalTraceReceiptWriter()

        let receipt = try writer.record(
            traceID: "trace-partial-receipt",
            subactions: [
                InternalTraceSubactionFact(
                    subactionID: "accepted-ac",
                    disposition: .accepted,
                    family: "ac",
                    reasonKind: "accepted_tool_call",
                    finiteReason: nil,
                    observedToolCallCount: 1,
                    stateMutation: true,
                    speechText: "空调已打开",
                    readbackKeys: ["ac.power"]
                ),
                InternalTraceSubactionFact(
                    subactionID: "refused-window",
                    disposition: .refused,
                    family: "window",
                    reasonKind: "capability_not_mounted",
                    finiteReason: .unmountedToolName,
                    observedToolCallCount: 0,
                    stateMutation: false,
                    speechText: "当前演示暂不支持车窗控制",
                    readbackKeys: []
                )
            ]
        )

        XCTAssertEqual(receipt.schemaVersion, "c3_internal_trace_receipt.v1")
        XCTAssertEqual(receipt.traceID, "trace-partial-receipt")
        XCTAssertEqual(receipt.subactions.map(\.subactionID), ["accepted-ac", "refused-window"])
        XCTAssertTrue(receipt.subactions[0].stateMutation)
        XCTAssertEqual(receipt.subactions[0].observedToolCallCount, 1)
        XCTAssertNil(receipt.subactions[0].finiteReason)
        XCTAssertEqual(receipt.subactions[1].finiteReason?.rawValue, "unmounted_tool_name")
        XCTAssertFalse(receipt.subactions[1].stateMutation)
        XCTAssertEqual(receipt.subactions[1].speechText, "当前演示暂不支持车窗控制")
        XCTAssertEqual(writer.receipts, [receipt])

        let encoded = String(data: try JSONEncoder().encode(receipt), encoding: .utf8)!
        XCTAssertTrue(encoded.contains("finite_reason"))
        XCTAssertTrue(encoded.contains("unmounted_tool_name"))
        XCTAssertTrue(encoded.contains("state_mutation"))
        XCTAssertTrue(encoded.contains("speech_text"))
    }

    func testFallbackReceiptRejectsUnknownFiniteReason() {
        XCTAssertNil(RuntimeFiniteReason(rawValue: "invented_reason"))
    }

    func testStaleStateRevisionReceiptUsesGeneratedFiniteReasonAuthority() throws {
        XCTAssertEqual(
            Set(InternalTraceFiniteReason.allCases.map(\.rawValue)),
            Set(RuntimePresentationReasonAuthority.finiteReasonRawValues)
        )

        let writer = InternalTraceReceiptWriter()
        let receipt = try writer.record(
            traceID: "trace-stale-state-revision",
            subactions: [
                InternalTraceSubactionFact(
                    subactionID: "refused-stale-ac",
                    disposition: .refused,
                    family: "ac",
                    reasonKind: "runtime_unavailable",
                    finiteReason: .staleStateRevision,
                    observedToolCallCount: 0,
                    stateMutation: false,
                    speechText: "状态已变化，请重试",
                    readbackKeys: []
                )
            ]
        )

        XCTAssertEqual(receipt.subactions[0].finiteReason?.rawValue, "stale_state_revision")
        let encoded = try JSONEncoder().encode(receipt)
        XCTAssertTrue(String(decoding: encoded, as: UTF8.self).contains("stale_state_revision"))
    }

    func testRefusedReceiptFailsWhenActualStateMutationOrToolCallExists() {
        let writer = InternalTraceReceiptWriter()

        XCTAssertThrowsError(
            try writer.record(
                traceID: "trace-refused-mutation",
                subactions: [
                    InternalTraceSubactionFact(
                        subactionID: "refused-door",
                        disposition: .refused,
                        family: "car_door",
                        reasonKind: "safety_policy",
                        finiteReason: .safetyOrPolicyRefusal,
                        observedToolCallCount: 1,
                        stateMutation: true,
                        speechText: "当前状态下不能执行开门操作",
                        readbackKeys: []
                    )
                ]
            )
        ) { error in
            XCTAssertEqual(
                error as? InternalTraceReceiptError,
                .refusedSubactionHasObservedEffects(
                    subactionID: "refused-door",
                    observedToolCallCount: 1,
                    stateMutation: true
                )
            )
        }
    }

    func testReceiptDecodesWithoutRawFiniteReasonForAcceptedSubaction() throws {
        let json = """
        {
          "schema_version": "c3_internal_trace_receipt.v1",
          "trace_id": "trace-backward-compatible",
          "subactions": [
            {
              "subaction_id": "accepted-ac",
              "disposition": "accepted",
              "family": "ac",
              "reason_kind": "accepted_tool_call",
              "observed_tool_call_count": 1,
              "state_mutation": true,
              "speech_text": "空调已打开",
              "readback_keys": ["ac.power"]
            }
          ]
        }
        """.data(using: .utf8)!

        let receipt = try JSONDecoder().decode(InternalTraceReceipt.self, from: json)

        XCTAssertNil(receipt.subactions[0].finiteReason)
        XCTAssertTrue(receipt.subactions[0].stateMutation)
    }
}
