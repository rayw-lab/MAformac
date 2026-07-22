import Foundation
import XCTest
@testable import MAformacCore

final class RuntimeActionReadbackProbeTests: XCTestCase {
    @MainActor
    func testDefaultRuntimeRecordsHonestActionReadbackEvidenceWithoutInjection() async throws {
        let catalog = try loadCatalog()
        XCTAssertEqual(catalog.probes.count, 3)
        XCTAssertEqual(Set(catalog.probes.map(\.probeID)).count, catalog.probes.count)
        XCTAssertEqual(Set(catalog.probes.map(\.matrixID)).count, catalog.probes.count)
        XCTAssertEqual(Set(catalog.probes.map(\.utterance)).count, catalog.probes.count)

        var observedCases: [ObservedActionProbeCase] = []
        for probe in catalog.probes {
            let store = DemoVehicleStateStore()
            let trace = InMemoryTraceLogger()
            let speech = RecordingSpeechSynthesisEngine()
            let beforeCells = store.cells
            let beforeHash = try canonicalStateSHA256(store)
            let beforeValue = try XCTUnwrap(store.cell(for: probe.expectedStateDelta.key)?.actualValue)
            XCTAssertEqual(beforeValue, probe.expectedStateDelta.beforeValue, probe.probeID)

            // Deliberately use the default runtime composition. No model backend,
            // completion provider, ToolCallFrame, or direct store mutation is injected.
            let runner = try DemoRuntimeSessionRunner.defaultRunner(
                store: store,
                traceLogger: trace,
                speech: speech
            )
            let payload = try await runner.run(text: probe.utterance)
            let afterHash = try canonicalStateSHA256(store)
            let traceEntries = trace.entries.filter { $0.traceID == payload.traceID }
            let observedToolCallCount = traceEntries
                .filter { $0.stage == .decode }
                .compactMap(\.attributes.toolCallCount)
                .max() ?? 0
            let emittedToolNames = emittedToolNames(
                traceEntries: traceEntries
            )
            let stateDeltas = stateDeltas(before: beforeCells, after: store.cells)

            let observed = ObservedActionProbeCase(
                probeID: probe.probeID,
                matrixID: probe.matrixID,
                register: probe.register,
                utterance: probe.utterance,
                representativeTool: probe.representativeTool,
                pathKind: "default_runtime",
                injectionUsed: false,
                traceID: payload.traceID,
                stageTraceIDs: Dictionary(grouping: traceEntries, by: { $0.stage.rawValue })
                    .mapValues { $0.map(\.traceID) },
                observedToolCallCount: observedToolCallCount,
                emittedToolNames: emittedToolNames,
                stateBeforeSHA256: beforeHash,
                stateAfterSHA256: afterHash,
                stateMutation: beforeHash != afterHash,
                stateDeltas: stateDeltas,
                confirmedState: ConfirmedState(
                    key: probe.expectedStateDelta.key,
                    actualValue: store.cell(for: probe.expectedStateDelta.key)?.actualValue ?? ""
                ),
                resultKind: payload.outcome.result.rawValue,
                reconciliationStatus: payload.reconciliation.status.rawValue,
                readbacks: payload.readbacks.map {
                    ObservedReadback(key: $0.key, actualValue: $0.actualValue, spokenText: $0.spokenText)
                }
            )
            observedCases.append(observed)

        }

        // WP1a-7 TODO: this probe still primarily emits an evidence receipt; add post-run
        // XCTAssertEqual checks for expectedStateDelta.afterValue and expectedReadback.actualValue
        // before promoting it from observation probe to product behavior gate.
        try writeReceipt(catalog: catalog, cases: observedCases)
    }

    private func emittedToolNames(
        traceEntries: [TraceEntry]
    ) -> [String] {
        traceEntries.compactMap { entry in
            guard entry.stage == .decode,
                  let marker = entry.message.range(of: "tool_name=") else {
                return nil
            }
            return entry.message[marker.upperBound...]
                .split(separator: ",", maxSplits: 1)
                .first
                .map(String.init)
        }
    }

    @MainActor
    private func stateDeltas(
        before: [DemoVehicleStateCell],
        after: [DemoVehicleStateCell]
    ) -> [ObservedStateDelta] {
        let beforeByKey = Dictionary(uniqueKeysWithValues: before.map { ($0.key, $0.actualValue) })
        return after.compactMap { cell in
            guard let beforeValue = beforeByKey[cell.key], beforeValue != cell.actualValue else {
                return nil
            }
            return ObservedStateDelta(
                key: cell.key,
                beforeValue: beforeValue,
                afterValue: cell.actualValue
            )
        }
    }

    @MainActor
    private func canonicalStateSHA256(_ store: DemoVehicleStateStore) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return C6Hash.sha256Hex(try encoder.encode(store.cells))
    }

    private func loadCatalog() throws -> ActionProbeCatalog {
        let url = repoRoot.appendingPathComponent("contracts/runtime-action-readback-probes.json")
        return try JSONDecoder().decode(ActionProbeCatalog.self, from: Data(contentsOf: url))
    }

    private func writeReceipt(catalog: ActionProbeCatalog, cases: [ObservedActionProbeCase]) throws {
        let catalogURL = repoRoot.appendingPathComponent("contracts/runtime-action-readback-probes.json")
        let receipt = RuntimeActionReadbackReceipt(
            schemaVersion: "runtime_action_readback_receipt_v2",
            receiptID: catalog.receiptID,
            probePackSHA256: try C6Hash.fileHash(url: catalogURL),
            proofClass: "local_unit",
            caseCount: cases.count,
            cases: cases,
            runID: ProcessInfo.processInfo.environment["C1_WITNESS_RUN_ID"] ?? "local:swift-test",
            sourceHeadSHA: ProcessInfo.processInfo.environment["C1_WITNESS_SOURCE_HEAD_SHA"] ?? "0000000000000000000000000000000000000000",
            testedCheckoutSHA: ProcessInfo.processInfo.environment["C1_WITNESS_TESTED_CHECKOUT_SHA"] ?? "0000000000000000000000000000000000000000",
            nonce: ProcessInfo.processInfo.environment["C1_WITNESS_NONCE"] ?? "00000000000000000000000000000000",
            buildIdentity: "swift-test",
            modelIdentity: "FastPathDemoToolPlanBackend",
            runtimeContractBundleDigest: DemoRuntimeContractBundleCatalog.runtimeContractBundleDigest,
            probeCatalogSHA256: ProcessInfo.processInfo.environment["C1_WITNESS_PROBE_CATALOG_SHA256"]
        )
        let runDirectory = ProcessInfo.processInfo.environment["C1_RUN_DIR"].map {
            URL(fileURLWithPath: $0, isDirectory: true)
        } ?? repoRoot.appendingPathComponent(".build/c1-run", isDirectory: true)
        let output = runDirectory
            .appendingPathComponent("receipts/c1", isDirectory: true)
            .appendingPathComponent("runtime-action-readback-probes.json")
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

private struct ActionProbeCatalog: Decodable {
    let schemaVersion: String
    let receiptID: String
    let probes: [ActionProbe]
}

private struct ActionProbe: Decodable {
    let probeID: String
    let matrixID: Int
    let register: String
    let utterance: String
    let representativeTool: String
    let expectedStateDelta: ExpectedStateDelta
    let expectedReadback: ExpectedReadback
}

private struct ExpectedStateDelta: Decodable {
    let key: String
    let beforeValue: String
    let afterValue: String
}

private struct ExpectedReadback: Decodable {
    let key: String
    let actualValue: String
}

private struct ObservedStateDelta: Codable {
    let key: String
    let beforeValue: String
    let afterValue: String
}

private struct ConfirmedState: Codable {
    let key: String
    let actualValue: String
}

private struct ObservedReadback: Codable {
    let key: String
    let actualValue: String
    let spokenText: String
}

private struct ObservedActionProbeCase: Codable {
    let probeID: String
    let matrixID: Int
    let register: String
    let utterance: String
    let representativeTool: String
    let pathKind: String
    let injectionUsed: Bool
    let traceID: String
    let stageTraceIDs: [String: [String]]
    let observedToolCallCount: Int
    let emittedToolNames: [String]
    let stateBeforeSHA256: String
    let stateAfterSHA256: String
    let stateMutation: Bool
    let stateDeltas: [ObservedStateDelta]
    let confirmedState: ConfirmedState
    let resultKind: String
    let reconciliationStatus: String
    let readbacks: [ObservedReadback]
}

private struct RuntimeActionReadbackReceipt: Codable {
    let schemaVersion: String
    let receiptID: String
    let probePackSHA256: String
    let proofClass: String
    let caseCount: Int
    let cases: [ObservedActionProbeCase]
    let runID: String
    let sourceHeadSHA: String
    let testedCheckoutSHA: String
    let nonce: String
    let buildIdentity: String
    let modelIdentity: String
    let runtimeContractBundleDigest: String
    let probeCatalogSHA256: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion, receiptID, probePackSHA256, proofClass, caseCount, cases
        case runID, sourceHeadSHA, testedCheckoutSHA, nonce, buildIdentity, modelIdentity
        case runtimeContractBundleDigest
        case probeCatalogSHA256 = "probe_catalog_sha256"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(receiptID, forKey: .receiptID)
        try container.encode(probePackSHA256, forKey: .probePackSHA256)
        try container.encode(proofClass, forKey: .proofClass)
        try container.encode(caseCount, forKey: .caseCount)
        try container.encode(cases, forKey: .cases)
        try container.encode(runID, forKey: .runID)
        try container.encode(sourceHeadSHA, forKey: .sourceHeadSHA)
        try container.encode(testedCheckoutSHA, forKey: .testedCheckoutSHA)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(buildIdentity, forKey: .buildIdentity)
        try container.encode(modelIdentity, forKey: .modelIdentity)
        try container.encode(runtimeContractBundleDigest, forKey: .runtimeContractBundleDigest)
        try container.encode(probeCatalogSHA256, forKey: .probeCatalogSHA256)
    }
}
