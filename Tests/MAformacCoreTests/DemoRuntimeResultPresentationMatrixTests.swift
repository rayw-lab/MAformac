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

    func testSixRuntimeErrorClassesMapToPresentationStates() {
        let expected: [(RuntimePresentationErrorClass, DemoRuntimeResultKind, DemoVisualState, PresentationMotionKind, String)] = [
            (.unsupported, .refusalNoAvailableTool, .blocked_hard, .refusalShake, "unsupported"),
            (.unmounted, .refusalNoAvailableTool, .blocked_hard, .refusalShake, "unmounted"),
            (.safety, .refusalSafetyOrPolicy, .unsafe, .safetyPulse, "safety"),
            (.clarify, .clarifyMissingSlot, .blocked_with_alternative, .clarificationPulse, "clarify"),
            (.crash, .runtimeError, .unknown, .staticError, "crash"),
            (.noMatch, .refusalNoAvailableTool, .blocked_hard, .refusalShake, "no_match")
        ]

        XCTAssertEqual(DemoRuntimeResultPresentationMatrix.allErrorEntries.map(\.errorClass), RuntimePresentationErrorClass.allCases)

        for (errorClass, resultKind, visualState, motionKind, receiptKind) in expected {
            let entry = DemoRuntimeResultPresentationMatrix.errorEntry(for: errorClass)

            XCTAssertEqual(entry.resultKind, resultKind, errorClass.rawValue)
            XCTAssertEqual(entry.visualState, visualState, errorClass.rawValue)
            XCTAssertEqual(entry.motionKind, motionKind, errorClass.rawValue)
            XCTAssertEqual(entry.receiptKind, receiptKind, errorClass.rawValue)
            XCTAssertFalse(entry.dialogText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
