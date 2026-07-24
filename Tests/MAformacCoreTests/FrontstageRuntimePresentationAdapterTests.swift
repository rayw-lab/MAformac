import XCTest
@testable import MAformacCore

final class FrontstageRuntimePresentationAdapterTests: XCTestCase {
    func testContainmentPresentationPreservesExistingStateAndAddsOnlyTypedDenial() throws {
        let previous = StagePresentationSnapshot(
            traceId: "trace-1",
            storeCells: [DemoVehicleStateCell(key: "ac.power", actualValue: "off", revision: 4, visualState: .normal)],
            readbacks: [DemoActionReadback(key: "ac.power", actualValue: "off", revision: 4, spokenText: "旧读回")],
            proofClass: .simulatorMock
        )
        let turn = try FrontstageVoiceSession(sessionID: "session-1").submitContainment(utterance: "打开空调")

        let update = FrontstageRuntimePresentationAdapter.containmentUpdate(turn, preserving: previous)

        XCTAssertEqual(update.snapshot.storeCells, previous.storeCells)
        XCTAssertEqual(update.snapshot.readbacks, previous.readbacks)
        XCTAssertEqual(update.snapshot.resultKind, .refusalNoAvailableTool)
        XCTAssertEqual(update.snapshot.proofClass, previous.proofClass)
        XCTAssertEqual(update.dialogueTurns.map(\.role), [.user, .assistant])
        XCTAssertEqual(update.proofClass, .localUnit)
    }

    func testFixtureConsumerDelegatesSnapshotConstructionToTypedAdapter() throws {
        let source = try String(contentsOf: repoRoot.appendingPathComponent("Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift"), encoding: .utf8)
        XCTAssertTrue(source.contains("FrontstageRuntimePresentationAdapter.fixtureSnapshot("))
    }

    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
