import XCTest
@testable import MAformacCore

final class T7ECMotionBudgetLaunchBehaviorTests: XCTestCase {
    func testMotionBudgetLaunchArgumentMapsThreePublicValues() {
        XCTAssertEqual(
            MotionBudgetLaunchArgumentSelector.requestedBudget(arguments: ["MAformac", "-motionBudget", "full"]).level,
            .fullShowcase
        )
        XCTAssertEqual(
            MotionBudgetLaunchArgumentSelector.requestedBudget(arguments: ["MAformac", "-motionBudget", "balanced"]).level,
            .balancedDemo
        )
        XCTAssertEqual(
            MotionBudgetLaunchArgumentSelector.requestedBudget(arguments: ["MAformac", "-motionBudget", "static"]).level,
            .trainSafeStatic
        )
    }

    func testMotionBudgetLaunchArgumentDefaultsToFullForMissingOrInvalidValues() {
        XCTAssertEqual(
            MotionBudgetLaunchArgumentSelector.requestedBudget(arguments: ["MAformac"]).level,
            .fullShowcase
        )
        XCTAssertEqual(
            MotionBudgetLaunchArgumentSelector.requestedBudget(arguments: ["MAformac", "-motionBudget"]).level,
            .fullShowcase
        )
        XCTAssertEqual(
            MotionBudgetLaunchArgumentSelector.requestedBudget(arguments: ["MAformac", "-motionBudget", "auto"]).level,
            .fullShowcase
        )
    }

    func testReduceMotionStillOverridesLaunchArgumentSelectionToStatic() {
        let requested = MotionBudgetLaunchArgumentSelector.requestedBudget(
            arguments: ["MAformac", "-motionBudget", "balanced"]
        )

        let effective = PresentationReducedMotionPolicy.effectiveBudget(reduceMotion: true, requested: requested)

        XCTAssertEqual(requested.level, .balancedDemo)
        XCTAssertEqual(effective.level, .trainSafeStatic)
        XCTAssertEqual(effective.reason, .reduceMotion)
    }

    func testSelectedBudgetFeedsBehavioralParticleAndFramePolicy() {
        let requested = MotionBudgetLaunchArgumentSelector.requestedBudget(
            arguments: ["MAformac", "-motionBudget", "static"]
        )

        XCTAssertFalse(PresentationReducedMotionPolicy.allowsContinuousAnimation(reduceMotion: false, budget: requested))
        XCTAssertEqual(PresentationReducedMotionPolicy.particleCount(kind: .stage, reduceMotion: false, budget: requested), 0)
        XCTAssertEqual(PresentationReducedMotionPolicy.frameInterval(reduceMotion: false, budget: requested), 1.0 / 15.0, accuracy: 1e-9)
    }
}
