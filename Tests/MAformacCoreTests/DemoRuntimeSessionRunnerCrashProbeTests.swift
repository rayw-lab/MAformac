import XCTest
@testable import MAformacCore

final class DemoRuntimeSessionRunnerCrashProbeTests: XCTestCase {
    @MainActor
    func testFastPathNoMatchProducesTypedPresentationSafeFallback() async throws {
        let samples = [
            (text: "随便说一句", speech: "这个说法还没稳稳接住，请换个车控说法再试。"),
            (text: "帮我放首歌", speech: "这个音量说法还没稳稳接住，您可以说音量调低一点。"),
        ]

        for sample in samples {
            let store = DemoVehicleStateStore()
            let trace = InMemoryTraceLogger()
            let speech = RecordingSpeechSynthesisEngine()
            let runner = DemoRuntimeSessionRunner(
                store: store,
                pipeline: try makeRepoPipeline(),
                traceLogger: trace,
                speech: speech
            )

            let payload = try await runner.run(text: sample.text)

            XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
            XCTAssertEqual(payload.outcome.reason, FallbackSafeReasonKind.notAvailableInDemo.rawValue)
            XCTAssertEqual(payload.reconciliation.status, .notApplicable)
            XCTAssertEqual(payload.reconciliation.safeReason, FallbackSafeReasonKind.notAvailableInDemo.rawValue)
            XCTAssertEqual(payload.readbacks, [])
            XCTAssertEqual(speech.spokenTexts, [sample.speech])
            XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")

            let failureEntry = trace.entries.first { $0.message == "unsupported_tool_plan" }
            XCTAssertEqual(failureEntry?.attributes.guardReason, "unsupported_tool_plan")
            XCTAssertEqual(failureEntry?.attributes.finiteReason, "fast_path_no_match")
            let encoded = String(decoding: try JSONEncoder().encode(payload), as: UTF8.self)
            XCTAssertFalse(encoded.contains("fast_path_no_match"))
            XCTAssertFalse(encoded.contains("这个我先记下来，稍后帮您处理"))
        }
    }

    private func makeRepoPipeline() throws -> C3ExecutionPipeline {
        let semantic = try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl"))
        let stateCells = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let allowlist = try L1DemoAllowlistLookup(yaml: readRepoFile("contracts/l1-demo-allowlist.yaml"))
        return C3ExecutionPipeline(
            semantic: semantic,
            stateCells: stateCells,
            riskPolicy: risk,
            allowlist: allowlist
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
