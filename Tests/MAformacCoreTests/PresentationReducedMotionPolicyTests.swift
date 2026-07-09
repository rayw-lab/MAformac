import XCTest
@testable import MAformacCore

final class PresentationReducedMotionPolicyTests: XCTestCase {
    func testOrbStatesAllHaveReducedMotionFeedback() {
        for state in PresentationOrbState.allCases {
            let feedback = PresentationReducedMotionPolicy.feedback(for: state)

            XCTAssertTrue(PresentationReducedMotionFeedback.allCases.contains(feedback), "\(state.rawValue) feedback")
        }
    }

    func testThinkOrbUsesStaticThinkingFeedback() {
        XCTAssertEqual(PresentationReducedMotionPolicy.feedback(for: PresentationOrbState.think), .staticThinking)
    }

    func testMotionKindsAllHaveReducedMotionFeedback() {
        for motionKind in PresentationMotionKind.allCases {
            let feedback = PresentationReducedMotionPolicy.feedback(for: motionKind)

            XCTAssertTrue(PresentationReducedMotionFeedback.allCases.contains(feedback), "\(motionKind.rawValue) feedback")
        }
    }

    func testRuntimeResultMatrixMotionKindsAreReducible() {
        for entry in DemoRuntimeResultPresentationMatrix.allEntries {
            let feedback = PresentationReducedMotionPolicy.feedback(for: entry.motionKind)

            XCTAssertTrue(PresentationReducedMotionFeedback.allCases.contains(feedback), "\(entry.resultKind.rawValue) feedback")
        }
    }

    func testReduceMotionDisablesContinuousAnimationAndParticles() {
        XCTAssertFalse(PresentationReducedMotionPolicy.allowsContinuousAnimation(reduceMotion: true))
        XCTAssertFalse(PresentationReducedMotionPolicy.allowsDiscreteAnimation(reduceMotion: true))
        XCTAssertFalse(PresentationReducedMotionPolicy.allowsParticles(reduceMotion: true))
    }

    func testNormalMotionAllowsContinuousAnimationAndParticles() {
        XCTAssertTrue(PresentationReducedMotionPolicy.allowsContinuousAnimation(reduceMotion: false))
        XCTAssertTrue(PresentationReducedMotionPolicy.allowsDiscreteAnimation(reduceMotion: false))
        XCTAssertTrue(PresentationReducedMotionPolicy.allowsParticles(reduceMotion: false))
    }

    func testPolicySourceDoesNotUseDefaultSwitchFallback() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Core/Presentation/PresentationReducedMotionPolicy.swift")
        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        XCTAssertFalse(source.contains("default:"))
        XCTAssertFalse(source.contains("@unknown default"))
    }
}
