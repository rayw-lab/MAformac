import XCTest
@testable import MAformacCore

final class U16HapticPolicyTests: XCTestCase {
    private let allVisualStates: [DemoVisualState] = [
        .normal,
        .satisfied,
        .changing,
        .blocked_with_alternative,
        .blocked_hard,
        .unsafe,
        .unknown
    ]

    func testUserTouchOnIOSCanEmitSelectionSuccessAndSoftImpact() {
        XCTAssertEqual(
            PresentationHapticPolicy.intent(for: .userTouch, visualState: .normal, platform: .iOS),
            .selection
        )
        XCTAssertEqual(
            PresentationHapticPolicy.intent(for: .userTouch, visualState: .satisfied, platform: .iOS),
            .success
        )
        XCTAssertEqual(
            PresentationHapticPolicy.intent(for: .userTouch, visualState: .blocked_hard, platform: .iOS),
            .impactSoft
        )
    }

    func testNonUserTouchSourcesNeverEmitHaptics() {
        let nonUserSources = PresentationInteractionSource.allCases.filter { $0 != .userTouch }

        for source in nonUserSources {
            for state in allVisualStates {
                XCTAssertEqual(
                    PresentationHapticPolicy.intent(for: source, visualState: state, platform: .iOS),
                    .none,
                    "\(source.rawValue) \(state.rawValue)"
                )
            }
        }
    }

    func testMacOSAlwaysReturnsNone() {
        for source in PresentationInteractionSource.allCases {
            for state in allVisualStates {
                XCTAssertEqual(
                    PresentationHapticPolicy.intent(for: source, visualState: state, platform: .macOS),
                    .none,
                    "\(source.rawValue) \(state.rawValue)"
                )
            }
        }
    }

    func testEveryNonNoneIntentRequiresUserTouchOnIOS() {
        for platform in PresentationHapticPlatform.allCases {
            for source in PresentationInteractionSource.allCases {
                for state in allVisualStates {
                    let intent = PresentationHapticPolicy.intent(for: source, visualState: state, platform: platform)
                    if intent != .none {
                        XCTAssertEqual(platform, .iOS)
                        XCTAssertEqual(source, .userTouch)
                        XCTAssertTrue([.selection, .success, .impactSoft].contains(intent))
                    }
                }
            }
        }
    }

    func testPolicySourceDoesNotUseDefaultSwitchFallback() throws {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("Core/Presentation/PresentationHapticPolicy.swift"),
            encoding: .utf8
        )

        XCTAssertFalse(source.contains("default:"))
        XCTAssertFalse(source.contains("@unknown default"))
    }
}
