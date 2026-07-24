import XCTest
@testable import MAformacCore

@MainActor
final class FrontstageRouteReceiptTests: XCTestCase {
    func testForeignModeRequiresAllFiveKeysAndNeverFallsBack() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        XCTAssertThrowsError(
            try FrontstageRouteReceiptConfiguration.environment(
                [
                    "C1_FRONTSTAGE_RECEIPT_EMIT": "1",
                    "C1_FRONTSTAGE_RUN_ID": "run-1",
                    "C1_RUN_DIR": root.path,
                    "C1_FRONTSTAGE_SOURCE_HEAD_SHA": String(repeating: "a", count: 40)
                ],
                currentDirectory: root
            )
        )
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("receipts/c1/frontstage-route-receipt.v2.json").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("receipts/c1/frontstage-route-receipt.v1.json").path))
    }

    func testForeignWriterUsesExactPathAndBindsFiveKeys() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let configuration = try FrontstageRouteReceiptConfiguration.environment(
            [
                "C1_FRONTSTAGE_RECEIPT_EMIT": "1",
                "C1_FRONTSTAGE_RUN_ID": "c1-v5b-test-run",
                "C1_FRONTSTAGE_RUN_NONCE": "0123456789abcdef0123456789abcdef",
                "C1_RUN_DIR": root.path,
                "C1_FRONTSTAGE_SOURCE_HEAD_SHA": String(repeating: "a", count: 40)
            ],
            currentDirectory: root
        )
        let turn = try FrontstageVoiceSession(sessionID: "session-1").submitContainment(utterance: "打开空调")

        let receiptURL = try XCTUnwrap(
            RuntimeTurnReceiptAssembler.assembleAndWrite(
                turn: turn,
                routeResult: nil,
                configuration: configuration,
                isCurrent: { true }
            )
        )
        XCTAssertEqual(receiptURL.path, root.appendingPathComponent("receipts/c1/frontstage-route-receipt.v2.json").path)
        let receipt = try RuntimeTurnReceipt.decode(from: receiptURL)
        let encoded = try JSONSerialization.jsonObject(with: Data(contentsOf: receiptURL)) as? [String: Any]
        XCTAssertEqual(receipt.schemaVersion, RuntimeTurnReceipt.schemaVersionValue)
        XCTAssertEqual(receipt.runID, "c1-v5b-test-run")
        XCTAssertEqual(receipt.runNonce, "0123456789abcdef0123456789abcdef")
        XCTAssertEqual(receipt.sourceHeadSHA, String(repeating: "a", count: 40))
        XCTAssertEqual(encoded?["tested_checkout_sha"] as? String, String(repeating: "a", count: 40))
        XCTAssertEqual(encoded?["matrix_source_sha256"] as? String, DemoCapabilityMatrixCatalog.sourceSHA256)
        XCTAssertNil(encoded?["proof_class"])
        XCTAssertNil(encoded?["proofClass"])
        XCTAssertEqual(receipt.sessionID, "session-1")
        XCTAssertEqual(receipt.finalOutcome, .refusalNoAvailableTool)
        XCTAssertFalse(receipt.stateMutation)
        XCTAssertEqual(receipt.readbackCount, 0)
        XCTAssertEqual(receipt.actions.count, 1)
        XCTAssertEqual(receipt.actions[0].disposition, "refused")
        XCTAssertEqual(receipt.codeHeadDigest, String(repeating: "a", count: 40))
        XCTAssertFalse(receipt.mountReceiptBodySHA256.isEmpty)
        XCTAssertFalse(receipt.mountedCatalogDigest.isEmpty)
        XCTAssertFalse(receipt.touchedCellCanonicalSnapshotDigest.isEmpty)
    }

    func testStaleTurnWritesZeroBytes() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let configuration = try FrontstageRouteReceiptConfiguration.environment(
            [
                "C1_FRONTSTAGE_RECEIPT_EMIT": "1",
                "C1_FRONTSTAGE_RUN_ID": "run-stale",
                "C1_FRONTSTAGE_RUN_NONCE": "0123456789abcdef0123456789abcdef",
                "C1_RUN_DIR": root.path,
                "C1_FRONTSTAGE_SOURCE_HEAD_SHA": String(repeating: "b", count: 40)
            ],
            currentDirectory: root
        )
        let turn = try FrontstageVoiceSession().submitContainment(utterance: "打开车窗")

        XCTAssertNil(
            try RuntimeTurnReceiptAssembler.assembleAndWrite(
                turn: turn,
                routeResult: nil,
                configuration: configuration,
                isCurrent: { false }
            )
        )
        XCTAssertFalse(FileManager.default.fileExists(atPath: configuration.receiptURL.path))
    }

    func testOldAliasesAreRejected() throws {
        for alias in [
            "FRONTSTAGE_RUN_ID",
            "FRONTSTAGE_RUN_NONCE",
            "FRONTSTAGE_RECEIPT_PATH",
            "C1_FRONTSTAGE_RECEIPT_PATH"
        ] {
            XCTAssertThrowsError(
                try FrontstageRouteReceiptConfiguration.environment(
                    [alias: "legacy"],
                    currentDirectory: try temporaryDirectory()
                ),
                alias
            )
        }
    }

    func testForeignModeRejectsEachInvalidABIKeyWithoutReceiptFallback() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let valid = [
            "C1_FRONTSTAGE_RECEIPT_EMIT": "1",
            "C1_FRONTSTAGE_RUN_ID": "run-1",
            "C1_FRONTSTAGE_RUN_NONCE": "0123456789abcdef0123456789abcdef",
            "C1_RUN_DIR": root.path,
            "C1_FRONTSTAGE_SOURCE_HEAD_SHA": String(repeating: "a", count: 40)
        ]
        let invalidValues = [
            "C1_FRONTSTAGE_RECEIPT_EMIT": "true",
            "C1_FRONTSTAGE_RUN_ID": "  ",
            "C1_FRONTSTAGE_RUN_NONCE": String(repeating: "A", count: 32),
            "C1_RUN_DIR": "relative/run-dir",
            "C1_FRONTSTAGE_SOURCE_HEAD_SHA": String(repeating: "A", count: 40)
        ]

        for (key, invalidValue) in invalidValues {
            var environment = valid
            environment[key] = invalidValue
            XCTAssertThrowsError(
                try FrontstageRouteReceiptConfiguration.environment(environment, currentDirectory: root),
                key
            )
            XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("receipts/c1/frontstage-route-receipt.v2.json").path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent(".build/c1-run").path))
        }
    }

    func testAssemblerCoversRunnerZeroAndLinkedPreviousTurn() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let configuration = try FrontstageRouteReceiptConfiguration.environment(
            [
                "C1_FRONTSTAGE_RECEIPT_EMIT": "1",
                "C1_FRONTSTAGE_RUN_ID": "run-link",
                "C1_FRONTSTAGE_RUN_NONCE": "0123456789abcdef0123456789abcdef",
                "C1_RUN_DIR": root.path,
                "C1_FRONTSTAGE_SOURCE_HEAD_SHA": String(repeating: "c", count: 40)
            ],
            currentDirectory: root
        )
        let session = FrontstageVoiceSession(sessionID: "session-link")
        let turn1 = try session.submitContainment(utterance: "打开空调")
        let url1 = try XCTUnwrap(
            RuntimeTurnReceiptAssembler.assembleAndWrite(
                turn: turn1,
                routeResult: nil,
                configuration: configuration,
                isCurrent: { true }
            )
        )
        let receipt1 = try RuntimeTurnReceipt.decode(from: url1)
        XCTAssertNil(receipt1.linkedPreviousTurnID)

        let turn2 = try session.submitContainment(utterance: "算了")
        let cancelReadOnly = DemoSliceReadOnlyOutcome(
            classification: .cancel(target: nil),
            payload: RuntimePresentationPayload(
                traceID: "trace-cancel",
                turnID: turn2.turnID,
                eventID: "cancel-preempt:link",
                isTerminal: true,
                outcome: DemoRuntimeOutcome(result: .cancelled, reason: "cancelled"),
                cards: [],
                readbacks: [
                    DemoActionReadback(
                        key: "presentation.cancel",
                        actualValue: "preempt",
                        revision: 0,
                        spokenText: "已取消"
                    )
                ],
                reconciliation: PresentationReconciliation(status: .notApplicable, safeReason: "cancelled"),
                mutationCount: 0
            ),
            runnerCallCount: 0
        )
        let routeResult = DemoSliceRouteResult(classification: .cancel(target: nil), readOnly: cancelReadOnly)
        let url2 = try XCTUnwrap(
            RuntimeTurnReceiptAssembler.assembleAndWrite(
                turn: turn2,
                routeResult: routeResult,
                configuration: configuration,
                isCurrent: { true },
                linkedPreviousTurnID: receipt1.turnID
            )
        )
        let receipt2 = try RuntimeTurnReceipt.decode(from: url2)
        XCTAssertEqual(receipt2.linkedPreviousTurnID, receipt1.turnID)
        XCTAssertEqual(receipt2.finalOutcome, .cancelled)
        XCTAssertEqual(receipt2.actions.count, 1)
        XCTAssertEqual(receipt2.actions[0].disposition, "cancelled")
        XCTAssertTrue(receipt2.actions[0].isVirtualReadback)
        XCTAssertEqual(receipt2.readbackCount, 0, "virtual presentation.* keys are not business readbacks")
    }

    func testDurableWriteFailedSurfacesB10ErrorCase() throws {
        // Encode round-trip of durableWriteFailed equatable surface used by App.
        let error = FrontstageRouteReceiptWriteError.durableWriteFailed(underlying: "failedToReplaceReceipt")
        XCTAssertEqual(error, .durableWriteFailed(underlying: "failedToReplaceReceipt"))
        XCTAssertNotEqual(error, .appExecutableUnavailable)
    }

    private func temporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
