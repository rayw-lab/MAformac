import XCTest
@testable import MAformacCore

final class DemoRuntimeResultPresentationMatrixTests: XCTestCase {
    func testMatrixCoversEveryRuntimeResultKindExactlyOnce() {
        let entries = DemoRuntimeResultPresentationMatrix.allEntries

        XCTAssertEqual(entries.map(\.resultKind), DemoRuntimeResultKind.allCases)
        XCTAssertEqual(Set(entries.map(\.resultKind)), Set(DemoRuntimeResultKind.allCases))
        XCTAssertEqual(entries.count, 8)
    }

    func testEachRuntimeResultKindHasVUIAndProofOutputs() {
        for entry in DemoRuntimeResultPresentationMatrix.allEntries {
            XCTAssertFalse(entry.dialogText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            XCTAssertTrue(PresentationMotionKind.allCases.contains(entry.motionKind))
            XCTAssertEqual(entry.ttsState, .speaking)
            XCTAssertEqual(entry.proofClass, .localMock)
        }
    }

    func testRuntimeResultKindsMapToExpectedVisualAndMotionStates() {
        let expected: [(DemoRuntimeResultKind, DemoVisualState, PresentationMotionKind)] = [
            (.acceptedToolCall, .satisfied, .stateCommit),
            (.clarifyMissingSlot, .blocked_with_alternative, .clarificationPulse),
            (.refusalNoAvailableTool, .blocked_hard, .refusalShake),
            (.refusalSafetyOrPolicy, .unsafe, .safetyPulse),
            (.alreadyStateNoop, .satisfied, .steadyAcknowledge),
            (.runtimeError, .unknown, .staticError),
            (.cancelled, .normal, .cancellationFade),
            (.partialAcceptPartialRefuse, .blocked_with_alternative, .partialResult)
        ]

        for (kind, visualState, motionKind) in expected {
            let entry = DemoRuntimeResultPresentationMatrix.entry(for: kind)

            XCTAssertEqual(entry.visualState, visualState, "\(kind.rawValue) visualState")
            XCTAssertEqual(entry.motionKind, motionKind, "\(kind.rawValue) motionKind")
        }
    }

    func testMatrixSourceDoesNotUseDefaultSwitchFallback() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Core/Presentation/DemoRuntimeResultPresentationMatrix.swift")
        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        XCTAssertFalse(source.contains("default:"))
        XCTAssertFalse(source.contains("@unknown default"))
    }
}
