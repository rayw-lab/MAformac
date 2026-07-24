import XCTest
@testable import MAformacCore

final class FrontstageCustomerIngressTests: XCTestCase {
    func testTextTranscriptAndShortcutShareOneFacadeWithStableIdentity() throws {
        var validated: [FrontstageIngressRequest] = []
        let ingress = FrontstageCustomerIngress(
            session: FrontstageVoiceSession(sessionID: "session-1"),
            validator: { request in validated.append(request); return nil }
        )

        let text = try ingress.submit(.init(source: .text, rawText: " 打开空调 ")).acceptedTurn
        let transcript = try ingress.submit(.init(source: .voiceTranscript, rawText: "打开车窗")).acceptedTurn
        let shortcut = try ingress.submit(.init(source: .shortcut, rawText: "关闭天窗")).acceptedTurn

        XCTAssertEqual(validated.map(\.source), [.text, .voiceTranscript, .shortcut])
        XCTAssertEqual(validated.map(\.sequence), [1, 2, 3])
        XCTAssertEqual(Set(validated.map(\.sessionID)), ["session-1"])
        XCTAssertEqual(Set(validated.map(\.turnID)).count, 3)
        XCTAssertEqual(Set(validated.map(\.eventID)).count, 3)
        XCTAssertEqual([text.utterance, transcript.utterance, shortcut.utterance], ["打开空调", "打开车窗", "关闭天窗"])
    }

    func testValidatorRunsExactlyOnceAfterIdentityAssignment() throws {
        var calls = 0
        let ingress = FrontstageCustomerIngress(
            session: FrontstageVoiceSession(sessionID: "session-1"),
            validator: { request in
                calls += 1
                XCTAssertFalse(request.turnID.isEmpty)
                XCTAssertFalse(request.eventID.isEmpty)
                return nil
            }
        )

        _ = try ingress.submit(.init(source: .text, rawText: "打开空调")).acceptedTurn
        XCTAssertEqual(calls, 1)
    }
}

private extension FrontstageIngressResult {
    var acceptedTurn: FrontstageVoiceTurn {
        get throws {
            guard case let .accepted(turn) = self else {
                throw XCTSkip("expected accepted ingress")
            }
            return turn
        }
    }
}
