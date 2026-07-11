import XCTest
@testable import MAformacCore

final class FrontstageIngressValidationTests: XCTestCase {
    func testNilBlankAndOversizeInputsReturnTypedSideEffectFreeRejections() {
        let ingress = FrontstageCustomerIngress(
            session: FrontstageVoiceSession(sessionID: "session-1"),
            maximumUTF8Bytes: 8
        )

        assertRejected(ingress.submit(.init(source: .voiceTranscript, rawText: nil)), as: .unavailable)
        assertRejected(ingress.submit(.init(source: .text, rawText: "  \n")), as: .blank)
        assertRejected(ingress.submit(.init(source: .text, rawText: "123456789")), as: .oversize(maximumUTF8Bytes: 8))
    }

    private func assertRejected(
        _ result: FrontstageIngressResult,
        as expected: FrontstageIngressRejection,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case let .rejected(rejection) = result else {
            return XCTFail("expected rejection", file: file, line: line)
        }
        XCTAssertEqual(rejection.reason, expected, file: file, line: line)
        XCTAssertFalse(rejection.stateMutation, file: file, line: line)
        XCTAssertTrue(rejection.readbacks.isEmpty, file: file, line: line)
        XCTAssertFalse(rejection.request.turnID.isEmpty, file: file, line: line)
        XCTAssertFalse(rejection.request.eventID.isEmpty, file: file, line: line)
    }
}
