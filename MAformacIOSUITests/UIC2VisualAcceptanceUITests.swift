import XCTest

final class UIC2VisualAcceptanceUITests: XCTestCase {
    private struct VisualCase {
        let id: String
        let launchArguments: [String]
        let expectedIdentifiers: [String]
        let expectedTreeText: [String]
    }

    private struct FamilyTouchCase {
        let familyID: String
        let displayName: String

        var cardIdentifier: String { "vehicle-card-family.\(familyID)" }
        var expandedIdentifier: String { "expanded-\(familyID)" }
    }

    private struct RepresentativeControlTouchCase {
        let familyID: String
        let displayName: String
        let controlIdentifier: String
        let beforeText: String
        let afterText: String
        let afterSummaryText: String

        var cardIdentifier: String { "vehicle-card-family.\(familyID)" }
        var expandedIdentifier: String { "expanded-\(familyID)" }
        var closeIdentifier: String { "expanded-\(familyID)-close" }
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

    private let familyTouchCases: [FamilyTouchCase] = [
        FamilyTouchCase(familyID: "seat", displayName: "座椅"),
        FamilyTouchCase(familyID: "ambient", displayName: "氛围灯"),
        FamilyTouchCase(familyID: "ac", displayName: "空调"),
        FamilyTouchCase(familyID: "screen", displayName: "屏幕"),
        FamilyTouchCase(familyID: "volume", displayName: "音量"),
        FamilyTouchCase(familyID: "door", displayName: "车门"),
        FamilyTouchCase(familyID: "sunroofShade", displayName: "天窗遮阳"),
        FamilyTouchCase(familyID: "window", displayName: "车窗"),
        FamilyTouchCase(familyID: "wiper", displayName: "雨刮"),
        FamilyTouchCase(familyID: "fragrance", displayName: "香氛")
    ]

    private let representativeControlTouchCases: [RepresentativeControlTouchCase] = [
        RepresentativeControlTouchCase(
            familyID: "ac",
            displayName: "空调",
            controlIdentifier: "value-control-ac-temp_setpoint-primary",
            beforeText: "26℃",
            afterText: "27℃",
            afterSummaryText: "空调 27℃"
        ),
        RepresentativeControlTouchCase(
            familyID: "seat",
            displayName: "座椅",
            controlIdentifier: "value-control-seat-heat_level-primary",
            beforeText: "2挡",
            afterText: "3挡",
            afterSummaryText: "座椅 3挡"
        ),
        RepresentativeControlTouchCase(
            familyID: "window",
            displayName: "车窗",
            controlIdentifier: "value-control-window-position-primary",
            beforeText: "60%",
            afterText: "61%",
            afterSummaryText: "车窗 61%"
        ),
        RepresentativeControlTouchCase(
            familyID: "screen",
            displayName: "屏幕",
            controlIdentifier: "value-control-screen-brightness-primary",
            beforeText: "65%",
            afterText: "66%",
            afterSummaryText: "屏幕 66%"
        ),
        RepresentativeControlTouchCase(
            familyID: "ambient",
            displayName: "氛围灯",
            controlIdentifier: "value-control-ambient-brightness-primary",
            beforeText: "62%",
            afterText: "63%",
            afterSummaryText: "氛围灯 63%"
        ),
        RepresentativeControlTouchCase(
            familyID: "volume",
            displayName: "音量",
            controlIdentifier: "value-control-volume-level-primary",
            beforeText: "38%",
            afterText: "39%",
            afterSummaryText: "音量 39%"
        ),
        RepresentativeControlTouchCase(
            familyID: "wiper",
            displayName: "雨刮",
            controlIdentifier: "value-control-wiper-speed-primary",
            beforeText: "1挡",
            afterText: "2挡",
            afterSummaryText: "雨刮 2挡"
        ),
        RepresentativeControlTouchCase(
            familyID: "door",
            displayName: "车门",
            controlIdentifier: "value-control-door-central_lock-primary",
            beforeText: "关",
            afterText: "开",
            afterSummaryText: "车门 开"
        ),
        RepresentativeControlTouchCase(
            familyID: "sunroofShade",
            displayName: "天窗遮阳",
            controlIdentifier: "value-control-sunroof-position-primary",
            beforeText: "0%",
            afterText: "1%",
            afterSummaryText: "天窗遮阳 1%"
        ),
        RepresentativeControlTouchCase(
            familyID: "fragrance",
            displayName: "香氛",
            controlIdentifier: "value-control-fragrance-power-primary",
            beforeText: "关",
            afterText: "开",
            afterSummaryText: "香氛 开"
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
    func testAmbientBrightnessGaugeCircleWritesBackOnTouch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-mockSnapshot", "cooling", "-mockTheme", "ivory"]
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 16))
        let ambientCard = app.descendants(matching: .any)["vehicle-card-family.ambient"]
        XCTAssertTrue(ambientCard.waitForExistence(timeout: 12))
        ambientCard.tap()

        let expandedAmbient = app.descendants(matching: .any)["expanded-ambient"]
        XCTAssertTrue(expandedAmbient.waitForExistence(timeout: 12))
        XCTAssertTrue(waitForTreeText("62%", in: app), "测试前置：cooling mock 的氛围灯亮度应为 62%")
        let brightnessCircle = app.descendants(matching: .any)["value-control-ambient-brightness-primary"]
        XCTAssertTrue(brightnessCircle.waitForExistence(timeout: 6))
        brightnessCircle.tap()

        XCTAssertEqual(app.state, .runningForeground)
        XCTAssertTrue(waitForTreeText("63%", in: app), "氛围灯亮度圆圈触摸必须真实写回并刷新读数")
    }

    @MainActor
    func testAllTenFamilyRepresentativeControlsWriteBackOnPrimaryTouch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-mockSnapshot", "cooling", "-mockTheme", "ivory"]
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 16))
        for item in representativeControlTouchCases {
            let card = app.descendants(matching: .any)[item.cardIdentifier]
            XCTAssertTrue(card.waitForExistence(timeout: 12), "Missing family card: \(item.displayName)")
            tapPossiblyOffscreen(card, in: app)

            let expanded = app.descendants(matching: .any)[item.expandedIdentifier]
            XCTAssertTrue(expanded.waitForExistence(timeout: 8), "Missing expanded card: \(item.displayName)")
            XCTAssertTrue(waitForTreeText(item.beforeText, in: app), "Missing pre-touch value \(item.beforeText) for \(item.displayName)")

            let control = app.descendants(matching: .any)[item.controlIdentifier]
            XCTAssertTrue(control.waitForExistence(timeout: 6), "Missing primary touch target: \(item.displayName)")
            control.tap()

            XCTAssertEqual(app.state, .runningForeground, "App left foreground after primary touch: \(item.displayName)")
            XCTAssertTrue(waitForTreeText(item.afterText, in: app), "Missing post-touch value \(item.afterText) for \(item.displayName)")

            let closeButton = app.buttons[item.closeIdentifier]
            XCTAssertTrue(closeButton.waitForExistence(timeout: 4), "Missing close button: \(item.displayName)")
            closeButton.tap()
            XCTAssertTrue(waitForTreeTextToDisappear(item.expandedIdentifier, in: app), "Expanded card did not dismiss: \(item.displayName)")
            XCTAssertTrue(waitForTreeText(item.afterSummaryText, in: app), "Outer summary did not reflect writeback: \(item.displayName)")
        }
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
    func testAllTenFamilyCardsExpandWithoutCrash() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-mockSnapshot", "cooling", "-mockTheme", "ivory"]
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 16))
        for family in familyTouchCases {
            let card = app.descendants(matching: .any)[family.cardIdentifier]
            XCTAssertTrue(card.waitForExistence(timeout: 12), "Missing family card: \(family.displayName)")
            tapPossiblyOffscreen(card, in: app)

            let expanded = app.descendants(matching: .any)[family.expandedIdentifier]
            XCTAssertTrue(expanded.waitForExistence(timeout: 8), "Missing expanded card after tapping: \(family.displayName)")
            XCTAssertEqual(app.state, .runningForeground, "App left foreground after tapping: \(family.displayName)")

            let closeButton = app.buttons["expanded-\(family.familyID)-close"]
            XCTAssertTrue(closeButton.waitForExistence(timeout: 4), "Missing close button for: \(family.displayName)")
            closeButton.tap()
            XCTAssertTrue(
                waitForTreeTextToDisappear(family.expandedIdentifier, in: app),
                "Expanded card did not dismiss: \(family.displayName)"
            )
        }
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

    @MainActor
    private func waitForTreeTextToDisappear(_ text: String, in app: XCUIApplication, timeout: TimeInterval = 4) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if !app.debugDescription.contains(text) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        } while Date() < deadline

        return false
    }

    @MainActor
    private func tapPossiblyOffscreen(_ element: XCUIElement, in app: XCUIApplication) {
        if element.isHittable {
            element.tap()
            return
        }
        let cards = app.descendants(matching: .any)["vehicle-cards"]
        for _ in 0..<4 where !element.isHittable {
            if cards.exists {
                cards.swipeUp()
            } else {
                app.swipeUp()
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        element.tap()
    }
}
