import XCTest
@testable import MAformacCore

/// G6 刀2: mount / catalog / touched-cell digest fact recalculation + dual-turn linked chain.
@MainActor
final class RuntimeTurnReceiptDigestTests: XCTestCase {
    func testMountReceiptBodyDigestRecalculatesFromFixtureBody() throws {
        let body = Data("mount-receipt-fixture-body-v2".utf8)
        let expected = RuntimeTurnReceiptAssembler.mountReceiptBodySHA256(from: body)
        XCTAssertEqual(expected.count, 64)
        XCTAssertEqual(expected, C6Hash.sha256Hex(body))

        let absent = RuntimeTurnReceiptAssembler.mountReceiptBodySHA256(from: nil)
        XCTAssertEqual(absent, C6Hash.sha256Hex(Data("mount_receipt_absent".utf8)))

        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let configuration = try foreignConfiguration(runID: "digest-mount", runDirectory: root)
        let turn = try FrontstageVoiceSession(sessionID: "session-mount").submitContainment(utterance: "打开空调")
        let receipt = try RuntimeTurnReceiptAssembler.assemble(
            turn: turn,
            routeResult: nil,
            configuration: configuration,
            mountReceiptBodySHA256: expected
        )
        XCTAssertEqual(receipt.mountReceiptBodySHA256, expected)
        // Recompute from same body facts — must not depend on live store.
        XCTAssertEqual(
            RuntimeTurnReceiptAssembler.mountReceiptBodySHA256(from: body),
            receipt.mountReceiptBodySHA256
        )
    }

    func testMountedCatalogDigestMatchesIndependentCatalogRecalc() throws {
        let catalog = DemoSliceAdmissionCatalog()
        let expected = RuntimeTurnReceiptAssembler.mountedCatalogDigest(catalog: catalog)
        let independent = independentCatalogDigest(catalog)
        XCTAssertEqual(expected, independent)
        XCTAssertEqual(expected, catalog.catalogDigestSHA256)

        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let configuration = try foreignConfiguration(runID: "digest-catalog", runDirectory: root)
        let turn = try FrontstageVoiceSession(sessionID: "session-catalog").submitContainment(utterance: "打开空调")
        let receipt = try RuntimeTurnReceiptAssembler.assemble(
            turn: turn,
            routeResult: nil,
            configuration: configuration
        )
        XCTAssertEqual(receipt.mountedCatalogDigest, expected)
        XCTAssertEqual(independentCatalogDigest(DemoSliceAdmissionCatalog()), receipt.mountedCatalogDigest)
    }

    func testTouchedCellDigestIsKeyOrderStableAcrossMultiCellPermutations() throws {
        let cellA = DemoActionReadback(key: "ac.power", actualValue: "on", revision: 3, spokenText: "已打开空调")
        let cellB = DemoActionReadback(key: "ac.temp_setpoint", actualValue: "22", revision: 5, spokenText: "温度22度")
        let cellC = DemoActionReadback(key: "ac.mode", actualValue: "cool", revision: 2, spokenText: "制冷")
        let virtual = DemoActionReadback(
            key: "presentation.cancel",
            actualValue: "preempt",
            revision: 0,
            spokenText: "已取消"
        )

        let order1 = [cellB, cellA, cellC, virtual]
        let order2 = [cellC, virtual, cellB, cellA]
        let order3 = [cellA, cellB, cellC]

        let d1 = RuntimeTurnReceiptAssembler.touchedCellCanonicalSnapshotDigest(from: order1)
        let d2 = RuntimeTurnReceiptAssembler.touchedCellCanonicalSnapshotDigest(from: order2)
        let d3 = RuntimeTurnReceiptAssembler.touchedCellCanonicalSnapshotDigest(from: order3)
        XCTAssertEqual(d1, d2)
        XCTAssertEqual(d1, d3)

        let independent = independentTouchedCellDigest(from: [cellA, cellB, cellC])
        XCTAssertEqual(d1, independent)

        let withVirtualOnlyExtra = independentTouchedCellDigest(from: [cellA, cellB, cellC, virtual])
        XCTAssertEqual(d1, withVirtualOnlyExtra, "presentation.* must not affect business touched-cell digest")
    }

    func testAssemblerTouchedCellDigestMatchesFactRecalcForMultiCellCommit() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let configuration = try foreignConfiguration(runID: "digest-commit", runDirectory: root)
        let session = FrontstageVoiceSession(sessionID: "session-commit")
        let turn = try session.submitContainment(utterance: "打开空调")

        let unsortedReadbacks = [
            DemoActionReadback(key: "ac.temp_setpoint", actualValue: "24", revision: 7, spokenText: "24度"),
            DemoActionReadback(key: "ac.power", actualValue: "on", revision: 6, spokenText: "已打开")
        ]
        let routeResult = try commitRouteResult(
            utterance: "打开空调",
            turnID: turn.turnID,
            readbacks: unsortedReadbacks
        )
        let receipt = try RuntimeTurnReceiptAssembler.assemble(
            turn: turn,
            routeResult: routeResult,
            configuration: configuration
        )
        XCTAssertTrue(receipt.stateMutation)
        XCTAssertEqual(receipt.readbackCount, 2)
        XCTAssertEqual(
            receipt.touchedCellCanonicalSnapshotDigest,
            independentTouchedCellDigest(from: unsortedReadbacks)
        )
        XCTAssertEqual(
            receipt.touchedCellCanonicalSnapshotDigest,
            RuntimeTurnReceiptAssembler.touchedCellCanonicalSnapshotDigest(from: unsortedReadbacks.reversed())
        )
    }

    func testLinkedCommitThenPrecommitCancelPreservesChainAndDigests() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let configuration = try foreignConfiguration(runID: "digest-linked", runDirectory: root)
        let session = FrontstageVoiceSession(sessionID: "session-linked")

        // Turn 1: Commit (mutation + multi-cell business readbacks).
        let turn1 = try session.submitContainment(utterance: "打开空调")
        let commitReadbacks = [
            DemoActionReadback(key: "ac.temp_setpoint", actualValue: "22", revision: 2, spokenText: "22度"),
            DemoActionReadback(key: "ac.power", actualValue: "on", revision: 1, spokenText: "已打开")
        ]
        let commitRoute = try commitRouteResult(
            utterance: "打开空调",
            turnID: turn1.turnID,
            readbacks: commitReadbacks
        )
        let url1 = try XCTUnwrap(
            RuntimeTurnReceiptAssembler.assembleAndWrite(
                turn: turn1,
                routeResult: commitRoute,
                configuration: configuration,
                isCurrent: { true },
                mountReceiptBodySHA256: RuntimeTurnReceiptAssembler.mountReceiptBodySHA256(
                    from: Data("linked-mount-body".utf8)
                )
            )
        )
        let receipt1 = try RuntimeTurnReceipt.decode(from: url1)
        XCTAssertNil(receipt1.linkedPreviousTurnID)
        XCTAssertEqual(receipt1.finalOutcome, .acceptedToolCall)
        XCTAssertTrue(receipt1.stateMutation)
        XCTAssertEqual(
            receipt1.touchedCellCanonicalSnapshotDigest,
            independentTouchedCellDigest(from: commitReadbacks)
        )
        XCTAssertEqual(
            receipt1.mountedCatalogDigest,
            independentCatalogDigest(DemoSliceAdmissionCatalog())
        )
        XCTAssertEqual(
            receipt1.mountReceiptBodySHA256,
            RuntimeTurnReceiptAssembler.mountReceiptBodySHA256(from: Data("linked-mount-body".utf8))
        )

        // Turn 2: Pre-commit Cancel (virtual presentation.* only; linked to turn1).
        let turn2 = try session.submitContainment(utterance: "算了")
        let cancelReadOnly = DemoSliceReadOnlyOutcome(
            classification: .cancel(target: nil),
            payload: RuntimePresentationPayload(
                traceID: "trace-cancel-linked",
                turnID: turn2.turnID,
                eventID: "cancel-preempt:\(turn1.turnID)",
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
        let cancelRoute = DemoSliceRouteResult(classification: .cancel(target: nil), readOnly: cancelReadOnly)
        let url2 = try XCTUnwrap(
            RuntimeTurnReceiptAssembler.assembleAndWrite(
                turn: turn2,
                routeResult: cancelRoute,
                configuration: configuration,
                isCurrent: { true },
                linkedPreviousTurnID: receipt1.turnID,
                mountReceiptBodySHA256: receipt1.mountReceiptBodySHA256
            )
        )
        let receipt2 = try RuntimeTurnReceipt.decode(from: url2)
        XCTAssertEqual(receipt2.linkedPreviousTurnID, receipt1.turnID)
        XCTAssertEqual(receipt2.finalOutcome, .cancelled)
        XCTAssertFalse(receipt2.stateMutation)
        XCTAssertEqual(receipt2.readbackCount, 0)
        XCTAssertTrue(receipt2.actions[0].isVirtualReadback)
        XCTAssertEqual(
            receipt2.touchedCellCanonicalSnapshotDigest,
            independentTouchedCellDigest(from: [])
        )
        XCTAssertEqual(receipt2.mountedCatalogDigest, receipt1.mountedCatalogDigest)
        XCTAssertEqual(receipt2.mountReceiptBodySHA256, receipt1.mountReceiptBodySHA256)
        XCTAssertNotEqual(receipt2.turnID, receipt1.turnID)

        // Disk overwrite is latest-turn; chain identity remains on receipt2 payload.
        XCTAssertEqual(url2.path, configuration.receiptURL.path)
        XCTAssertEqual(try RuntimeTurnReceipt.decode(from: url2).linkedPreviousTurnID, receipt1.turnID)
    }

    // MARK: - Independent fact recalculation (does not call Assembler helpers under test for catalog/touched)

    private func independentCatalogDigest(_ catalog: DemoSliceAdmissionCatalog) -> String {
        let canonical = catalog.entries
            .map { "\($0.matrixID)|\($0.contractRowID)|\($0.stateBase)" }
            .joined(separator: "\n") + "\n"
        return C6Hash.sha256Hex(Data(canonical.utf8))
    }

    private func independentTouchedCellDigest(from readbacks: [DemoActionReadback]) -> String {
        let lines = readbacks
            .filter { !$0.key.hasPrefix(RuntimeTurnReceiptAssembler.virtualReadbackKeyPrefix) }
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.actualValue)@\($0.revision)" }
            .joined(separator: "\n")
        return C6Hash.sha256Hex(Data((lines + "\n").utf8))
    }

    private func commitRouteResult(
        utterance: String,
        turnID: String,
        readbacks: [DemoActionReadback]
    ) throws -> DemoSliceRouteResult {
        let admission = try XCTUnwrap(DemoSliceAdmissionCatalog().admission(for: utterance))
        let payload = RuntimePresentationPayload(
            traceID: "trace-commit-\(turnID)",
            turnID: turnID,
            eventID: "commit:\(turnID)",
            isTerminal: true,
            outcome: DemoRuntimeOutcome(result: .acceptedToolCall, reason: nil),
            cards: [],
            readbacks: readbacks,
            reconciliation: PresentationReconciliation(status: .verified, safeReason: nil),
            mutationCount: readbacks.filter { !$0.key.hasPrefix("presentation.") }.count
        )
        let execution = DemoSliceExecution(admission: admission, payload: payload, runnerCallCount: 1)
        return DemoSliceRouteResult(classification: .command(admission), execution: execution)
    }

    private func foreignConfiguration(runID: String, runDirectory: URL) throws -> FrontstageRouteReceiptConfiguration {
        try FrontstageRouteReceiptConfiguration.environment(
            [
                "C1_FRONTSTAGE_RECEIPT_EMIT": "1",
                "C1_FRONTSTAGE_RUN_ID": runID,
                "C1_FRONTSTAGE_RUN_NONCE": "0123456789abcdef0123456789abcdef",
                "C1_RUN_DIR": runDirectory.path,
                "C1_FRONTSTAGE_SOURCE_HEAD_SHA": String(repeating: "e", count: 40)
            ],
            currentDirectory: runDirectory
        )
    }

    private func temporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
