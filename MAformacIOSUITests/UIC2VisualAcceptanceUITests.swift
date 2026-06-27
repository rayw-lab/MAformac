import XCTest

final class UIC2VisualAcceptanceUITests: XCTestCase {
    private struct VisualCase {
        let id: String
        let launchArguments: [String]
        let expectedIdentifiers: [String]
        let expectedTreeText: [String]
    }

    private let cases: [String: VisualCase] = [
        "main_cooling_deep_space": VisualCase(
            id: "main_cooling_deep_space",
            launchArguments: ["-mockSnapshot", "cooling", "-mockTheme", "deepSpace"],
            expectedIdentifiers: ["context-band", "demo-orb", "dialogue-stream", "vehicle-cards"],
            expectedTreeText: ["空调", "26℃", "我有点冷"]
        ),
        "main_heating_ivory": VisualCase(
            id: "main_heating_ivory",
            launchArguments: ["-mockSnapshot", "heating", "-mockTheme", "ivory"],
            expectedIdentifiers: ["context-band", "demo-orb", "dialogue-stream", "vehicle-cards"],
            expectedTreeText: ["空调", "28℃", "我有点热"]
        ),
        "safety_refusal_ivory": VisualCase(
            id: "safety_refusal_ivory",
            launchArguments: ["-mockSnapshot", "safetyRefusal", "-mockTheme", "ivory"],
            expectedIdentifiers: ["context-band", "demo-orb", "dialogue-stream"],
            expectedTreeText: ["安全", "尾门", "行驶中"]
        ),
        "capsule_video_loop_deep_space": VisualCase(
            id: "capsule_video_loop_deep_space",
            launchArguments: [
                "-mockSnapshot", "cooling",
                "-mockTheme", "deepSpace",
                "-contextCapsuleRoute", "videoLoop"
            ],
            expectedIdentifiers: ["context-band", "demo-orb", "dialogue-stream", "vehicle-cards"],
            expectedTreeText: ["环境胶囊", "空调", "26℃"]
        ),
        "u17_golden_path_deep_space": VisualCase(
            id: "u17_golden_path_deep_space",
            launchArguments: ["-goldenPathID", "uiue_g9b_ac_success_deep_space"],
            expectedIdentifiers: ["context-band", "demo-orb", "dialogue-stream", "vehicle-cards"],
            expectedTreeText: ["空调", "26℃", "按住说话"]
        )
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMainCoolingDeepSpaceCapturesUITree() throws {
        try runVisualCase("main_cooling_deep_space")
    }

    @MainActor
    func testMainHeatingIvoryCapturesUITree() throws {
        try runVisualCase("main_heating_ivory")
    }

    @MainActor
    func testSafetyRefusalIvoryCapturesUITree() throws {
        try runVisualCase("safety_refusal_ivory")
    }

    @MainActor
    func testCapsuleVideoLoopDeepSpaceCapturesUITree() throws {
        try runVisualCase("capsule_video_loop_deep_space")
    }

    @MainActor
    func testU17GoldenPathDeepSpaceCapturesUITree() throws {
        try runVisualCase("u17_golden_path_deep_space")
    }

    @MainActor
    private func runVisualCase(_ caseID: String) throws {
        let visualCase = try visualCase(for: caseID)
        let app = XCUIApplication()
        app.launchArguments = visualCase.launchArguments
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 16))
        for identifier in visualCase.expectedIdentifiers {
            XCTAssertTrue(
                waitForAnyIdentifier([identifier, "\(identifier)-mac-panorama"], in: app),
                "Missing accessibility identifier: \(identifier)"
            )
        }
        XCTAssertTrue(waitForAnyIdentifier(["mic-dock", "mic-dock-safe-area"], in: app))

        let tree = app.debugDescription
        for expectedText in visualCase.expectedTreeText {
            XCTAssertTrue(tree.contains(expectedText), "UI tree missing expected text: \(expectedText)")
        }

        print("UIUE_8C2_CASE_BEGIN \(visualCase.id)")
        print(tree)
        print("UIUE_8C2_CASE_END \(visualCase.id)")
    }

    private func visualCase(for caseID: String) throws -> VisualCase {
        guard let visualCase = cases[caseID] else {
            throw XCTSkip("Unknown UIUE_8C2_CASE_ID: \(caseID)")
        }
        return visualCase
    }

    @MainActor
    private func waitForAnyIdentifier(_ identifiers: [String], in app: XCUIApplication) -> Bool {
        let deadline = Date().addingTimeInterval(16)
        repeat {
            if identifiers.contains(where: { app.descendants(matching: .any)[$0].exists }) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        } while Date() < deadline

        return false
    }
}
