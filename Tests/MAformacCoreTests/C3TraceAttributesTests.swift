import XCTest
@testable import MAformacCore

/// gap#6: trace 不能只有 message:String。
/// tasks.md:48 + spec tool-execution:157 要求记录 candidate_source / tool_call_count /
/// stop_reason / repair_used / guard_reason / readback_result 强类型 attributes。
final class C3TraceAttributesTests: XCTestCase {
    @MainActor
    func testSuccessfulExecutionRecordsStructuredAttributesAcrossFiveStages() throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let pipeline = try makePipeline(intentConfirmed: true)
        let frame = ToolCallFrame(
            traceID: "trace-attr",
            agentID: "vehicle-control",
            capabilityID: "cabin.ac_temperature",
            toolName: "vehicle_control",
            device: "ac_temperature",
            actionPrimitive: "increase_by_exp",
            slots: ["direction": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "LITTLE", type: "EXP"),
            stateRevision: 0,
            candidateSource: .upstreamToolCall
        )

        _ = try pipeline.execute(frame, store: store, traceLogger: trace)

        let decode = try XCTUnwrap(trace.entries.first { $0.stage == .decode })
        XCTAssertEqual(decode.attributes.candidateSource, .upstreamToolCall)
        XCTAssertEqual(decode.attributes.toolCallCount, 1)
        XCTAssertEqual(decode.attributes.repairUsed, false)

        let guardEntry = try XCTUnwrap(trace.entries.last { $0.stage == .guard })
        XCTAssertEqual(guardEntry.attributes.guardReason, "allow")

        let readback = try XCTUnwrap(trace.entries.first { $0.stage == .readback })
        XCTAssertEqual(readback.attributes.readbackResult, .verified)
    }

    @MainActor
    func testGuardDeniedTraceRecordsGuardReasonAndNoFakeExecuteReadback() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "vehicle.speed", desiredValue: "12"))
        let trace = InMemoryTraceLogger()
        let pipeline = try makePipeline(intentConfirmed: true)
        let frame = ToolCallFrame.fixture(device: "car_door", actionPrimitive: "power_on", stateRevision: store.currentRevision)

        XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: trace))

        let guardEntry = try XCTUnwrap(trace.entries.last { $0.stage == .guard })
        XCTAssertFalse(guardEntry.attributes.guardReason?.isEmpty ?? true)
        // 拒绝时不得伪造 execute/readback 成功段。
        XCTAssertNil(trace.entries.first { $0.stage == .execute })
        XCTAssertFalse(trace.entries.contains { $0.attributes.readbackResult == .verified })
    }

    @MainActor
    func testParserRepairCandidateMarksRepairUsedInTrace() throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let pipeline = try makePipeline(intentConfirmed: true)
        var frame = ToolCallFrame.fixture(
            device: "window",
            actionPrimitive: "by_percent",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "ZERO", direct: "+", offset: "30", type: "PERCENT"),
            stateRevision: 0
        )
        frame.candidateSource = .parserRepair

        _ = try pipeline.execute(frame, store: store, traceLogger: trace)

        let decode = try XCTUnwrap(trace.entries.first { $0.stage == .decode })
        XCTAssertEqual(decode.attributes.candidateSource, .parserRepair)
        XCTAssertEqual(decode.attributes.repairUsed, true)
    }

    func testTraceEntriesCarryRunTreeFieldsWithoutChangingFiveStages() {
        let trace = InMemoryTraceLogger(
            runId: "demo-run-1",
            parentSpanId: "route-span-1",
            spanKind: .stage
        )

        trace.recordDecode(traceID: "trace-tree", message: "decode")
        trace.recordPlan(traceID: "trace-tree", message: "plan")

        XCTAssertEqual(trace.entries.map(\.stage), [.decode, .plan])
        XCTAssertEqual(trace.entries.map(\.runId), ["demo-run-1", "demo-run-1"])
        XCTAssertEqual(trace.entries.map(\.parentSpanId), ["route-span-1", "route-span-1"])
        XCTAssertEqual(trace.entries.map(\.spanKind), [.stage, .stage])
    }

    func testTraceEntryDecodesOldRecordsWithDefaultSpanKind() throws {
        let json = """
        {
          "stage": "decode",
          "traceID": "old-trace",
          "message": "old entry",
          "attributes": {},
          "timestamp": "2026-06-20T00:00:00Z"
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let entry = try decoder.decode(TraceEntry.self, from: json)

        XCTAssertEqual(entry.stage, .decode)
        XCTAssertEqual(entry.spanKind, .stage)
        XCTAssertNil(entry.runId)
        XCTAssertNil(entry.parentSpanId)
    }

    private func makePipeline(intentConfirmed: Bool) throws -> C3ExecutionPipeline {
        let semantic = try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl"))
        let stateCells = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let allowlist = try L1DemoAllowlistLookup(yaml: readRepoFile("contracts/l1-demo-allowlist.yaml"))
        return C3ExecutionPipeline(
            semantic: semantic,
            stateCells: stateCells,
            riskPolicy: risk,
            allowlist: allowlist,
            intentConfirmed: { intentConfirmed }
        )
    }

    private func readRepoFile(_ relativePath: String) throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(contentsOf: repoRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }
}

private extension ToolCallFrame {
    static func fixture(
        device: String,
        actionPrimitive: String,
        slots: [String: String] = [:],
        value: ContractValue = ContractValue(),
        stateRevision: Int
    ) -> ToolCallFrame {
        ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.\(device)",
            toolName: "vehicle_control",
            device: device,
            actionPrimitive: actionPrimitive,
            slots: slots,
            value: value,
            stateRevision: stateRevision,
            candidateSource: .upstreamToolCall
        )
    }
}
