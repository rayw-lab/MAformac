import XCTest
@testable import MAformacCore

final class DemoRuntimeResultPresentationMatrixTests: XCTestCase {
    func testMatrixCoversEveryRuntimeResultKindExactlyOnce() {
        let entries = DemoRuntimeResultPresentationMatrix.allEntries

        XCTAssertEqual(entries.map(\.resultKind), DemoRuntimeResultKind.allCases)
        XCTAssertEqual(Set(entries.map(\.resultKind)), Set(DemoRuntimeResultKind.allCases))
        XCTAssertEqual(entries.count, 12)
    }

    func testEachRuntimeResultKindHasVUIAndProofOutputs() {
        for entry in DemoRuntimeResultPresentationMatrix.allEntries {
            if entry.resultKind == .noAction {
                XCTAssertTrue(entry.dialogText.isEmpty)
                XCTAssertEqual(entry.ttsState, .idle)
            } else {
                XCTAssertFalse(entry.dialogText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                XCTAssertEqual(entry.ttsState, .speaking)
            }
            XCTAssertTrue(PresentationMotionKind.allCases.contains(entry.motionKind))
            XCTAssertEqual(entry.proofClass, .localMock)
        }
    }

    func testRuntimeResultKindsMapToExpectedVisualAndMotionStates() {
        let expected: [(DemoRuntimeResultKind, DemoVisualState, PresentationMotionKind)] = [
            (.acceptedToolCall, .satisfied, .stateCommit),
            (.noAction, .normal, .noAction),
            (.clarifyMissingSlot, .blocked_with_alternative, .clarificationPulse),
            (.refusalNoAvailableTool, .blocked_hard, .refusalShake),
            (.refusalSafetyOrPolicy, .unsafe, .safetyPulse),
            (.alreadyStateNoop, .satisfied, .steadyAcknowledge),
            (.runtimeError, .unknown, .staticError),
            (.cancelled, .normal, .cancellationFade),
            (.partialAcceptPartialRefuse, .blocked_with_alternative, .partialResult),
            (.stateQuery, .normal, .steadyAcknowledge),
            (.capabilityQuery, .normal, .steadyAcknowledge),
            (.refusalContractViolation, .blocked_hard, .refusalShake)
        ]

        for (kind, visualState, motionKind) in expected {
            let entry = DemoRuntimeResultPresentationMatrix.entry(for: kind)

            XCTAssertEqual(entry.visualState, visualState, "\(kind.rawValue) visualState")
            XCTAssertEqual(entry.motionKind, motionKind, "\(kind.rawValue) motionKind")
        }
    }

    func testKnife1_allCasesHavePresentationEntry() {
        for kind in DemoRuntimeResultKind.allCases {
            let entry = DemoRuntimeResultPresentationMatrix.entry(for: kind)
            XCTAssertEqual(entry.resultKind, kind)
            XCTAssertEqual(entry.proofClass, .localMock)
        }
        XCTAssertNotEqual(
            DemoRuntimeResultPresentationMatrix.entry(for: .refusalContractViolation).dialogText,
            DemoRuntimeResultPresentationMatrix.entry(for: .refusalSafetyOrPolicy).dialogText
        )
        XCTAssertNotEqual(
            DemoRuntimeResultPresentationMatrix.entry(for: .stateQuery).motionKind,
            PresentationMotionKind.stateCommit
        )
    }

    func testSixRuntimeErrorClassesMapToPresentationStates() {
        let expected: [(RuntimePresentationErrorClass, DemoRuntimeResultKind, DemoVisualState, PresentationMotionKind, String)] = [
            (.unsupported, .refusalNoAvailableTool, .blocked_hard, .refusalShake, "unsupported"),
            (.unmounted, .refusalNoAvailableTool, .blocked_hard, .refusalShake, "unmounted"),
            (.safety, .refusalSafetyOrPolicy, .unsafe, .safetyPulse, "safety_related_card_only"),
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

    func testRuntimeErrorClassProjectionUsesT5MapperAsSingleSource() {
        for errorClass in RuntimePresentationErrorClass.allCases {
            let matrixEntry = DemoRuntimeResultPresentationMatrix.errorEntry(for: errorClass)
            let t5Row = T5RuntimeErrorVisualMapper.map(errorClass.t5Fault)

            XCTAssertEqual(matrixEntry.visualState, t5Row.visualState, errorClass.rawValue)
            XCTAssertEqual(matrixEntry.receiptKind, t5Row.receiptKind, errorClass.rawValue)
            switch t5Row.scope {
            case .globalRetryableCrash:
                XCTAssertEqual(matrixEntry.resultKind, .runtimeError, errorClass.rawValue)
                XCTAssertEqual(matrixEntry.motionKind, .staticError, errorClass.rawValue)
            case .unsupportedLocked:
                XCTAssertEqual(matrixEntry.resultKind, .refusalNoAvailableTool, errorClass.rawValue)
                XCTAssertEqual(matrixEntry.motionKind, .refusalShake, errorClass.rawValue)
            case .clarify:
                XCTAssertEqual(matrixEntry.resultKind, .clarifyMissingSlot, errorClass.rawValue)
                XCTAssertEqual(matrixEntry.motionKind, .clarificationPulse, errorClass.rawValue)
            case .relatedCardOnly:
                XCTAssertEqual(matrixEntry.resultKind, .refusalSafetyOrPolicy, errorClass.rawValue)
                XCTAssertEqual(matrixEntry.motionKind, .safetyPulse, errorClass.rawValue)
            case .ttsDegraded:
                XCTAssertEqual(matrixEntry.resultKind, .partialAcceptPartialRefuse, errorClass.rawValue)
                XCTAssertEqual(matrixEntry.motionKind, .partialResult, errorClass.rawValue)
            }
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
