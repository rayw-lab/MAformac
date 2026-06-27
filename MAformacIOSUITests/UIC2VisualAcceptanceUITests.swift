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
    func testAmbientColorPickerSelectsEightColorWithoutCrash() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-mockSnapshot", "cooling", "-mockTheme", "ivory"]
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 16))
        let ambientCard = app.descendants(matching: .any)["vehicle-card-family.ambient"]
        XCTAssertTrue(ambientCard.waitForExistence(timeout: 12))
        ambientCard.tap()

        let expandedAmbient = app.descendants(matching: .any)["expanded-ambient"]
        XCTAssertTrue(expandedAmbient.waitForExistence(timeout: 12))
        XCTAssertTrue(app.buttons["氛围灯红"].waitForExistence(timeout: 6))
        app.buttons["氛围灯红"].tap()

        XCTAssertEqual(app.state, .runningForeground)
        let tree = app.debugDescription
        XCTAssertTrue(tree.contains("expanded-ambient"))
        XCTAssertTrue(tree.contains("氛围灯红"))
    }

    @MainActor
    func testAcModePickerSwitchesHeatingWithoutCrash() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-mockSnapshot", "cooling", "-mockTheme", "ivory"]
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 16))
        let acCard = app.descendants(matching: .any)["vehicle-card-family.ac"]
        XCTAssertTrue(acCard.waitForExistence(timeout: 12))
        acCard.tap()

        let expandedAC = app.descendants(matching: .any)["expanded-ac"]
        XCTAssertTrue(expandedAC.waitForExistence(timeout: 12))
        XCTAssertTrue(app.buttons["模式制热"].waitForExistence(timeout: 6))
        app.buttons["模式制热"].tap()

        XCTAssertEqual(app.state, .runningForeground)
        let tree = app.debugDescription
        XCTAssertTrue(tree.contains("expanded-ac"))
        XCTAssertTrue(tree.contains("模式制热"))
        XCTAssertTrue(tree.contains("制热"))
        XCTAssertTrue(waitForTreeText("制热 · 自动", in: app), "外层空调卡必须跟随 ac.mode 写回切到制热语义")
    }

    @MainActor
    func testSeatMassageModePickerUsesContractOptionsWithoutCrash() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-mockSnapshot", "cooling", "-mockTheme", "ivory"]
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 16))
        let seatCard = app.descendants(matching: .any)["vehicle-card-family.seat"]
        XCTAssertTrue(seatCard.waitForExistence(timeout: 12))
        seatCard.tap()

        let expandedSeat = app.descendants(matching: .any)["expanded-seat"]
        XCTAssertTrue(expandedSeat.waitForExistence(timeout: 12))
        XCTAssertTrue(app.buttons["模式蛇形模式"].waitForExistence(timeout: 6))
        app.buttons["模式蛇形模式"].tap()

        XCTAssertEqual(app.state, .runningForeground)
        let tree = app.debugDescription
        XCTAssertTrue(tree.contains("expanded-seat"))
        XCTAssertTrue(tree.contains("模式蛇形模式"))
        XCTAssertFalse(tree.contains("模式活力模式"))
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

    @MainActor
    private func waitForTreeText(_ text: String, in app: XCUIApplication, timeout: TimeInterval = 8) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if app.debugDescription.contains(text) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        } while Date() < deadline

        return false
    }
}
