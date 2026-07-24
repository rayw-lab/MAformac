import Foundation
import XCTest
@testable import MAformacCore

final class RuntimeNoMutationProbeTests: XCTestCase {
    @MainActor
    func testFortyFallbackProbesObserveNoToolCallAndUnchangedCanonicalState() async throws {
        let catalog = try loadCatalog()
        XCTAssertEqual(catalog.probes.count, 40)
        XCTAssertEqual(Set(catalog.probes.map(\.probeID)).count, 40)

        var observedCases: [ObservedProbeCase] = []
        for probe in catalog.probes {
            let store = DemoVehicleStateStore()
            let trace = InMemoryTraceLogger()
            let speech = RecordingSpeechSynthesisEngine()
            let before = try canonicalStateSHA256(store)

            let observation = try await execute(
                probe: probe,
                store: store,
                trace: trace,
                speech: speech
            )
            let after = try canonicalStateSHA256(store)
            let observedToolCallCount = trace.entries.filter { $0.stage == .execute }.count

            XCTAssertEqual(before, after, probe.probeID)
            XCTAssertEqual(observedToolCallCount, 0, probe.probeID)
            XCTAssertFalse(observation.dialogText.isEmpty, probe.probeID)
            XCTAssertEqual(observation.dialogText, probe.expectedUIReadback.dialogText, probe.probeID)
            XCTAssertEqual(observation.ttsText, probe.expectedUIReadback.ttsText, probe.probeID)
            XCTAssertEqual(observation.badgeLabel, probe.expectedUIReadback.badgeLabel, probe.probeID)
            XCTAssertEqual(observation.resultKind, probe.expectedUIReadback.resultKind, probe.probeID)
            XCTAssertEqual(observation.safeReasonKind, probe.expectedUIReadback.safeReasonKind, probe.probeID)
            XCTAssertFalse(trace.entries.contains { $0.stage == .readback }, probe.probeID)

            observedCases.append(
                ObservedProbeCase(
                    probeID: probe.probeID,
                    family: probe.family,
                    reasonKind: probe.reasonKind,
                    traceID: observation.traceID,
                    finiteReason: observation.finiteReason,
                    stateBeforeSHA256: before,
                    stateAfterSHA256: after,
                    stateMutation: before != after,
                    observedToolCallCount: observedToolCallCount,
                    resultKind: observation.resultKind,
                    safeReasonKind: observation.safeReasonKind,
                    badgeLabel: observation.badgeLabel,
                    dialogText: observation.dialogText,
                    ttsText: observation.ttsText
                )
            )
        }

        let pairs = Set(observedCases.map { "\($0.family)|\($0.reasonKind)" })
        XCTAssertEqual(pairs.count, 40)
        try writeReceipt(catalog: catalog, cases: observedCases)
    }

    @MainActor
    private func execute(
        probe: Probe,
        store: DemoVehicleStateStore,
        trace: InMemoryTraceLogger,
        speech: RecordingSpeechSynthesisEngine
    ) async throws -> ProbeObservation {
        let family = try XCTUnwrap(FallbackScriptFamily(rawValue: probe.family), probe.probeID)
        let reason = try XCTUnwrap(FallbackGovernanceReason(rawValue: probe.reasonKind), probe.probeID)
        let context = FallbackContext.resolve(family: family, reasonKind: reason)

        switch probe.fixturePath {
        case "default_text_runner":
            let runner = try DemoRuntimeSessionRunner.defaultRunner(
                store: store,
                traceLogger: trace,
                speech: speech
            )
            let payload = try await runner.run(text: probe.probeUtterance)
            return observation(
                runner: runner,
                payload: payload,
                context: context,
                trace: trace,
                speech: speech,
                finiteReason: .fastPathNoMatch
            )
        case "injected_tool_plan_stub":
            let runner = try DemoRuntimeSessionRunner.defaultRunner(
                store: store,
                traceLogger: trace,
                speech: speech,
                modelBackend: ThrowingProbeBackend(failure: .nameRejected("probe_unmounted"))
            )
            let payload = try await runner.run(text: probe.probeUtterance)
            return observation(
                runner: runner,
                payload: payload,
                context: context,
                trace: trace,
                speech: speech,
                finiteReason: .nameRejected
            )
        case "matrix_no_representative_stub":
            let traceID = "probe-no-representative-\(probe.probeID)"
            trace.recordGuard(
                traceID: traceID,
                message: "fallback_probe_no_representative_tool",
                attributes: TraceAttributes(
                    toolCallCount: 0,
                    guardReason: RuntimePresentationSafeReasonKind.notAvailableInDemo.rawValue,
                    finiteReason: .noRepresentativeTool
                )
            )
            _ = speech.speak(context.ttsText)
            return ProbeObservation(
                traceID: traceID,
                finiteReason: .noRepresentativeTool,
                resultKind: context.outcome.resultKind.rawValue,
                safeReasonKind: context.outcome.safeReasonKind.rawValue,
                badgeLabel: context.badgeLabel,
                dialogText: context.dialogText,
                ttsText: try XCTUnwrap(speech.spokenTexts.last, probe.probeID)
            )
        case "guard_or_clarify_stub":
            let traceID = "probe-guard-\(probe.probeID)"
            trace.recordGuard(
                traceID: traceID,
                message: "fallback_probe_guard_denied",
                attributes: TraceAttributes(
                    toolCallCount: 0,
                    guardReason: "fallback_probe_guard_denied",
                    finiteReason: .safetyOrPolicyRefusal
                )
            )
            _ = speech.speak(context.ttsText)
            return ProbeObservation(
                traceID: traceID,
                finiteReason: .safetyOrPolicyRefusal,
                resultKind: context.outcome.resultKind.rawValue,
                safeReasonKind: context.outcome.safeReasonKind.rawValue,
                badgeLabel: context.badgeLabel,
                dialogText: context.dialogText,
                ttsText: try XCTUnwrap(speech.spokenTexts.last, probe.probeID)
            )
        default:
            XCTFail("unknown fixture path \(probe.fixturePath)", file: #filePath, line: #line)
            throw ProbeTestError.unknownFixturePath(probe.fixturePath)
        }
    }

    @MainActor
    private func observation(
        runner: DemoRuntimeSessionRunner,
        payload: RuntimePresentationPayload,
        context: FallbackContext,
        trace: InMemoryTraceLogger,
        speech: RecordingSpeechSynthesisEngine,
        finiteReason: RuntimeFiniteReason
    ) -> ProbeObservation {
        ProbeObservation(
            traceID: payload.traceID,
            finiteReason: finiteReason,
            resultKind: context.outcome.resultKind.rawValue,
            safeReasonKind: context.outcome.safeReasonKind.rawValue,
            badgeLabel: context.badgeLabel,
            dialogText: runner.currentDialogueState.turns.last?.text ?? "",
            ttsText: speech.spokenTexts.last ?? ""
        )
    }

    @MainActor
    private func canonicalStateSHA256(_ store: DemoVehicleStateStore) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return C6Hash.sha256Hex(try encoder.encode(store.cells))
    }

    private func loadCatalog() throws -> ProbeCatalog {
        let url = repoRoot
            .appendingPathComponent("generated", isDirectory: true)
            .appendingPathComponent("demo-fallback-probes.catalog.json")
        return try JSONDecoder().decode(ProbeCatalog.self, from: Data(contentsOf: url))
    }

    private func writeReceipt(catalog: ProbeCatalog, cases: [ObservedProbeCase]) throws {
        let receipt = RuntimeNoMutationReceipt(
            schemaVersion: "runtime_no_mutation_receipt_v1",
            receiptID: catalog.receiptID,
            probePackSHA256: catalog.sourceSHA256,
            proofClass: "local_unit",
            caseCount: cases.count,
            expectedPairs: 40,
            observedPairs: Set(cases.map { "\($0.family)|\($0.reasonKind)" }).count,
            missingProbeIDs: [],
            duplicateProbeIDs: [],
            cases: cases
        )
        let runDirectory = ProcessInfo.processInfo.environment["C1_RUN_DIR"].map {
            URL(fileURLWithPath: $0, isDirectory: true)
        } ?? repoRoot.appendingPathComponent(".build/c1-run", isDirectory: true)
        let output = runDirectory
            .appendingPathComponent("receipts/c1", isDirectory: true)
            .appendingPathComponent("runtime-no-mutation-40-probes.json")
        try FileManager.default.createDirectory(
            at: output.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(receipt).write(to: output, options: .atomic)
    }

    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

private struct ThrowingProbeBackend: LLMBackend {
    let failure: DDomainToolPlanFailure

    func load() async throws {}
    func generateToolPlan(for request: ToolPlanRequest) async throws -> RuntimePlan { throw failure }
    func streamText(for prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { $0.finish() }
    }
    func cancel() {}
}

private enum ProbeTestError: Error {
    case unknownFixturePath(String)
}

private struct ProbeCatalog: Decodable {
    let schemaVersion: String
    let sourceSHA256: String
    let receiptID: String
    let probes: [Probe]
}

private struct Probe: Decodable {
    let probeID: String
    let family: String
    let reasonKind: String
    let locale: String
    let fixturePath: String
    let probeUtterance: String
    let expectedUIReadback: ExpectedUIReadback
}

private struct ExpectedUIReadback: Decodable {
    let resultKind: String
    let safeReasonKind: String
    let badgeLabel: String
    let dialogText: String
    let ttsText: String
}

private struct ProbeObservation {
    let traceID: String
    let finiteReason: RuntimeFiniteReason
    let resultKind: String
    let safeReasonKind: String
    let badgeLabel: String
    let dialogText: String
    let ttsText: String
}

private struct ObservedProbeCase: Codable {
    let probeID: String
    let family: String
    let reasonKind: String
    let traceID: String
    let finiteReason: RuntimeFiniteReason
    let stateBeforeSHA256: String
    let stateAfterSHA256: String
    let stateMutation: Bool
    let observedToolCallCount: Int
    let resultKind: String
    let safeReasonKind: String
    let badgeLabel: String
    let dialogText: String
    let ttsText: String
}

private struct RuntimeNoMutationReceipt: Codable {
    let schemaVersion: String
    let receiptID: String
    let probePackSHA256: String
    let proofClass: String
    let caseCount: Int
    let expectedPairs: Int
    let observedPairs: Int
    let missingProbeIDs: [String]
    let duplicateProbeIDs: [String]
    let cases: [ObservedProbeCase]
}
