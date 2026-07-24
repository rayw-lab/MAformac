import XCTest
@testable import MAformacCore

final class FrontstageVoiceSessionTests: XCTestCase {
    func testContainmentIsStableTypedNoWriteAcrossTwoTurns() throws {
        let session = FrontstageVoiceSession(sessionID: "frontstage-test-session")

        let first = try session.submitContainment(utterance: "打开空调")
        let second = try session.submitContainment(utterance: "打开车窗")

        XCTAssertEqual(first.sessionID, "frontstage-test-session")
        XCTAssertEqual(second.sessionID, first.sessionID)
        XCTAssertEqual([first.sequence, second.sequence], [1, 2])
        XCTAssertEqual(first.outcome.result, .refusalNoAvailableTool)
        XCTAssertEqual(second.outcome.result, .refusalNoAvailableTool)
        XCTAssertEqual(first.proofClass, .localUnit)
        XCTAssertEqual(second.proofClass, .localUnit)
        XCTAssertFalse(first.stateMutation)
        XCTAssertFalse(second.stateMutation)
        XCTAssertTrue(first.readbacks.isEmpty)
        XCTAssertTrue(second.readbacks.isEmpty)
        XCTAssertNotEqual(first.turnID, second.turnID)
        XCTAssertNotEqual(first.eventID, second.eventID)
    }
}
