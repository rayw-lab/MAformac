import Foundation
import XCTest
@testable import MAformacCore

final class RuntimeActionReadbackProbeTests: XCTestCase {
  private let acceptanceRouteID = "product.frontstage.text.v1"

  @MainActor
  func testDiagnosticDefaultRuntimeRefusesMatrix4Probe() async throws {
    let catalog = try loadCatalog()
    let probe = try XCTUnwrap(catalog.probes.first { $0.matrixID == 4 })

    let store = DemoVehicleStateStore()
    let trace = InMemoryTraceLogger()
    let speech = RecordingSpeechSynthesisEngine()
    let beforeValue = try XCTUnwrap(store.cell(for: probe.expectedStateDelta.key)?.actualValue)
    XCTAssertEqual(beforeValue, probe.expectedStateDelta.beforeValue)

    let runner = try DemoRuntimeSessionRunner.defaultRunner(
      store: store,
      traceLogger: trace,
      speech: speech
    )
    let payload = try await runner.run(text: probe.utterance)

    XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
    XCTAssertEqual(
      store.cell(for: probe.expectedStateDelta.key)?.actualValue,
      probe.expectedStateDelta.beforeValue
    )
    let traceEntries = trace.entries.filter { $0.traceID == payload.traceID }
    let observedToolCallCount = traceEntries
      .filter { $0.stage == .decode }
      .compactMap(\.attributes.toolCallCount)
      .max() ?? 0
    XCTAssertEqual(observedToolCallCount, 0)
  }

  @MainActor
  func testProductAcceptanceRoutePassesActionProbeCatalog() async throws {
    let witness = try requireWitnessBindings()
    let catalog = try loadCatalog()
    XCTAssertEqual(catalog.probes.count, 3)

    var observedCases: [ObservedActionProbeCase] = []
    for probe in catalog.probes {
      let store = DemoVehicleStateStore()
      let trace = InMemoryTraceLogger()
      let speech = RecordingSpeechSynthesisEngine()
      let beforeCells = store.cells
      let beforeHash = try canonicalStateSHA256(store)
      let beforeValue = try XCTUnwrap(store.cell(for: probe.expectedStateDelta.key)?.actualValue)
      XCTAssertEqual(beforeValue, probe.expectedStateDelta.beforeValue, probe.probeID)

      let route = try DemoSliceRoute(
        store: store,
        traceLogger: trace,
        speech: speech
      )
      let result = try await route.route(text: probe.utterance)
      let execution = try XCTUnwrap(result.execution, probe.probeID)
      let payload = execution.payload

      XCTAssertEqual(payload.outcome.result, .acceptedToolCall, probe.probeID)
      XCTAssertEqual(route.runnerCallCount, 1, probe.probeID)

      let afterHash = try canonicalStateSHA256(store)
      let traceEntries = trace.entries.filter { $0.traceID == payload.traceID }
      let observedToolCallCount = route.runnerCallCount
      let emittedToolNames = [execution.admission.frame.toolName]
      let stateDeltas = stateDeltas(before: beforeCells, after: store.cells)

      XCTAssertEqual(observedToolCallCount, 1, probe.probeID)
      XCTAssertEqual(emittedToolNames, [probe.representativeTool], probe.probeID)
      XCTAssertTrue(beforeHash != afterHash, probe.probeID)
      XCTAssertEqual(
        store.cell(for: probe.expectedStateDelta.key)?.actualValue,
        probe.expectedStateDelta.afterValue,
        probe.probeID
      )
      XCTAssertEqual(payload.reconciliation.status, .verified, probe.probeID)
      XCTAssertTrue(
        payload.readbacks.contains {
          $0.key == probe.expectedReadback.key
            && $0.actualValue == probe.expectedReadback.actualValue
            && !$0.spokenText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        },
        probe.probeID
      )

      let targetDelta = stateDeltas.first {
        $0.key == probe.expectedStateDelta.key
          && $0.beforeValue == probe.expectedStateDelta.beforeValue
          && $0.afterValue == probe.expectedStateDelta.afterValue
      }
      XCTAssertNotNil(targetDelta, probe.probeID)
      let deltaKeys = Set(stateDeltas.map(\.key))
      XCTAssertTrue(
        deltaKeys.isSubset(of: [probe.expectedStateDelta.key, "ac.power"]),
        probe.probeID
      )

      let stageTraceIDs = Dictionary(grouping: traceEntries, by: { $0.stage.rawValue })
        .mapValues { $0.map(\.traceID) }
      for stage in ["decode", "execute", "readback"] {
        let ids = try XCTUnwrap(stageTraceIDs[stage], probe.probeID)
        XCTAssertFalse(ids.isEmpty, probe.probeID)
        XCTAssertTrue(ids.allSatisfy { $0 == payload.traceID }, probe.probeID)
      }

      observedCases.append(
        ObservedActionProbeCase(
          probeID: probe.probeID,
          matrixID: probe.matrixID,
          register: probe.register,
          utterance: probe.utterance,
          representativeTool: probe.representativeTool,
          pathKind: "product_acceptance_route",
          injectionUsed: false,
          acceptanceRouteID: acceptanceRouteID,
          traceID: payload.traceID,
          stageTraceIDs: stageTraceIDs,
          observedToolCallCount: observedToolCallCount,
          emittedToolNames: emittedToolNames,
          stateBeforeSHA256: beforeHash,
          stateAfterSHA256: afterHash,
          stateMutation: true,
          stateDeltas: stateDeltas,
          confirmedState: ConfirmedState(
            key: probe.expectedStateDelta.key,
            actualValue: probe.expectedStateDelta.afterValue
          ),
          resultKind: payload.outcome.result.rawValue,
          reconciliationStatus: payload.reconciliation.status.rawValue,
          readbacks: payload.readbacks.map {
            ObservedReadback(
              key: $0.key,
              actualValue: $0.actualValue,
              spokenText: $0.spokenText
            )
          }
        )
      )
    }

    try writeReceipt(
      catalog: catalog,
      cases: observedCases,
      witness: witness
    )
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

  private func requireWitnessBindings(
    file: StaticString = #filePath,
    line: UInt = #line
  ) throws -> WitnessBindings {
    let env = ProcessInfo.processInfo.environment
    let zeroSHA = String(repeating: "0", count: 40)
    let zeroNonce = String(repeating: "0", count: 32)

    guard let sourceHeadSHA = env["C1_WITNESS_SOURCE_HEAD_SHA"],
          sourceHeadSHA.range(of: "^[0-9a-f]{40}$", options: .regularExpression) != nil,
          sourceHeadSHA != zeroSHA else {
      XCTFail("C1_WITNESS_SOURCE_HEAD_SHA must be a non-default 40-char git SHA", file: file, line: line)
      throw WitnessError.missing
    }
    guard let testedCheckoutSHA = env["C1_WITNESS_TESTED_CHECKOUT_SHA"],
          testedCheckoutSHA.range(of: "^[0-9a-f]{40}$", options: .regularExpression) != nil,
          testedCheckoutSHA != zeroSHA else {
      XCTFail("C1_WITNESS_TESTED_CHECKOUT_SHA must be a non-default 40-char git SHA", file: file, line: line)
      throw WitnessError.missing
    }
    guard let nonce = env["C1_WITNESS_NONCE"],
          nonce.range(of: "^[0-9a-f]{32}$", options: .regularExpression) != nil,
          nonce != zeroNonce else {
      XCTFail("C1_WITNESS_NONCE must be a non-default 32-char hex value", file: file, line: line)
      throw WitnessError.missing
    }
    guard let runID = env["C1_WITNESS_RUN_ID"], !runID.isEmpty else {
      XCTFail("C1_WITNESS_RUN_ID must be set", file: file, line: line)
      throw WitnessError.missing
    }
    guard let probeCatalogSHA256 = env["C1_WITNESS_PROBE_CATALOG_SHA256"],
          probeCatalogSHA256.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil else {
      XCTFail("C1_WITNESS_PROBE_CATALOG_SHA256 must be a 64-char hex digest", file: file, line: line)
      throw WitnessError.missing
    }

    return WitnessBindings(
      runID: runID,
      sourceHeadSHA: sourceHeadSHA,
      testedCheckoutSHA: testedCheckoutSHA,
      nonce: nonce,
      probeCatalogSHA256: probeCatalogSHA256
    )
  }

  private func writeReceipt(
    catalog: ActionProbeCatalog,
    cases: [ObservedActionProbeCase],
    witness: WitnessBindings
  ) throws {
    let catalogURL = repoRoot.appendingPathComponent("contracts/runtime-action-readback-probes.json")
    let receipt = RuntimeActionReadbackReceipt(
      schemaVersion: "runtime_action_readback_receipt_v2",
      receiptID: catalog.receiptID,
      probePackSHA256: try C6Hash.fileHash(url: catalogURL),
      proofClass: "local_unit",
      caseCount: cases.count,
      cases: cases,
      runID: witness.runID,
      sourceHeadSHA: witness.sourceHeadSHA,
      testedCheckoutSHA: witness.testedCheckoutSHA,
      nonce: witness.nonce,
      buildIdentity: "swift-test",
      modelIdentity: "DemoSliceAdmissionCatalog",
      runtimeContractBundleDigest: DemoRuntimeContractBundleCatalog.runtimeContractBundleDigest,
      probeCatalogSHA256: witness.probeCatalogSHA256
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

private enum WitnessError: Error {
  case missing
}

private struct WitnessBindings {
  let runID: String
  let sourceHeadSHA: String
  let testedCheckoutSHA: String
  let nonce: String
  let probeCatalogSHA256: String
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
  let acceptanceRouteID: String
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
  let probeCatalogSHA256: String

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
