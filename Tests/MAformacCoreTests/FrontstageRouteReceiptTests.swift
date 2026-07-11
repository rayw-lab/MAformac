import XCTest
@testable import MAformacCore

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
        let turn = FrontstageVoiceSession(sessionID: "session-1").submitContainment(utterance: "打开空调")

        let receiptURL = try XCTUnwrap(FrontstageRouteReceiptWriter.writeCurrent(turn, configuration: configuration, isCurrent: { true }))
        XCTAssertEqual(receiptURL.path, root.appendingPathComponent("receipts/c1/frontstage-route-receipt.v1.json").path)
        let receipt = try FrontstageRouteReceipt.decode(from: receiptURL)
        let encoded = try JSONSerialization.jsonObject(with: Data(contentsOf: receiptURL)) as? [String: Any]
        XCTAssertEqual(receipt.runID, "c1-v5b-test-run")
        XCTAssertEqual(receipt.runNonce, "0123456789abcdef0123456789abcdef")
        XCTAssertEqual(receipt.sourceHeadSHA, String(repeating: "a", count: 40))
        XCTAssertEqual(encoded?["tested_checkout_sha"] as? String, String(repeating: "a", count: 40))
        XCTAssertEqual(encoded?["matrix_source_sha256"] as? String, DemoCapabilityMatrixCatalog.sourceSHA256)
        XCTAssertEqual(receipt.sessionID, "session-1")
        XCTAssertEqual(receipt.result, .refusalNoAvailableTool)
        XCTAssertFalse(receipt.stateMutation)
        XCTAssertEqual(receipt.readbackCount, 0)
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
        let turn = FrontstageVoiceSession().submitContainment(utterance: "打开车窗")

        XCTAssertNil(try FrontstageRouteReceiptWriter.writeCurrent(turn, configuration: configuration, isCurrent: { false }))
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
            XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("receipts/c1/frontstage-route-receipt.v1.json").path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent(".build/c1-run").path))
        }
    }

    private func temporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
