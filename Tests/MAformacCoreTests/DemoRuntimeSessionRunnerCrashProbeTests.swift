import XCTest
@testable import MAformacCore

final class DemoRuntimeSessionRunnerCrashProbeTests: XCTestCase {
    @MainActor
    func testFastPathNoMatchFallsBackToUnsupportedPayloadForNonFastPathText() async throws {
        let samples = ["随便说一句", "帮我放首歌"]

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

            let payload = try await runner.run(text: sample)

            XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
            XCTAssertEqual(payload.outcome.reason, RuntimePresentationSafeReasonKind.notAvailableInDemo.rawValue)
            XCTAssertEqual(payload.reconciliation.status, .notApplicable)
            XCTAssertEqual(payload.reconciliation.safeReason, RuntimePresentationSafeReasonKind.notAvailableInDemo.rawValue)
            XCTAssertEqual(payload.readbacks, [])
            XCTAssertEqual(speech.spokenTexts, ["这个我先记下来，稍后帮您处理"])
            XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")

            let failureEntry = trace.entries.first { $0.message == "unsupported_tool_plan" }
            XCTAssertEqual(failureEntry?.attributes.guardReason, "unsupported_tool_plan")
            XCTAssertEqual(failureEntry?.attributes.finiteReason, "fast_path_no_match")
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
