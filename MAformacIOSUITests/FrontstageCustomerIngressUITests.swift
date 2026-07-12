import XCTest

final class FrontstageCustomerIngressUITests: XCTestCase {
    @MainActor
    func testDemoSliceP1OpenACExecutesWithAppVisibleProof() {
        withFreshApp(caseName: "P1-open-ac") { app in
            submit("打开空调", in: app)

            assertStatus(contains: "空调已打开", in: app)
            assertProof(contains: [
                "status=executed",
                "runner=1",
                "mutation=1",
                "matrix_id=1",
                "contract_row_id=c1_airControl_000006",
                "ac.power=on",
            ], in: app)
        }
    }

    @MainActor
    func testDemoSliceP2Temperature22ExecutesWithInputBoundReadbackAndCard() {
        withFreshApp(caseName: "P2-temp-22") { app in
            submit("把空调调到22度", in: app)

            assertStatus(contains: "22", in: app)
            assertProof(contains: [
                "status=executed",
                "runner=1",
                "mutation=1",
                "matrix_id=4",
                "contract_row_id=c1_airControl_000164",
                "ac.temp_setpoint[主驾]=22",
            ], in: app)
            XCTAssertTrue(app.staticTexts["22℃"].waitForExistence(timeout: 5), "22℃ family card must be visible")
        }
    }

    @MainActor
    func testDemoSliceN1BlankFailsClosedBeforeRunner() {
        withFreshApp(caseName: "N1-blank") { app in
            let submit = app.buttons["frontstage-customer-text-submit"]
            XCTAssertTrue(submit.waitForExistence(timeout: 12))
            submit.tap()

            assertStatus(contains: "请输入车控指令", in: app)
            assertProof(contains: ["status=ingress_rejected", "runner=0", "mutation=0", "readbacks=0"], in: app)
        }
    }

    @MainActor
    func testDemoSliceN2OutOfCatalogFailsClosed() {
        withFreshApp(caseName: "N2-window") { app in
            submit("打开车窗", in: app)

            assertStatus(contains: "这个功能当前演示环境暂不支持", in: app)
            assertProof(contains: ["status=contained", "runner=0", "mutation=0", "readbacks=0", "reason=not_in_catalog"], in: app)
        }
    }

    @MainActor
    func testDemoSliceN3BothTemperatureBoundsFailClosed() {
        for value in [17, 33] {
            withFreshApp(caseName: "N3-temp-\(value)") { app in
                submit("空调调到\(value)度", in: app)

                assertStatus(contains: "空调温度支持18到32度", in: app)
                assertProof(contains: ["status=contained", "runner=0", "mutation=0", "readbacks=0", "valueOutOfRange"], in: app)
            }
        }
    }

    @MainActor
    func testDemoSliceN4ClarifyWinsWithoutRunner() {
        withFreshApp(caseName: "N4-clarify") { app in
            submit("空调", in: app)

            assertStatus(contains: "请告诉我空调要打开，还是调到多少度", in: app)
            assertProof(contains: ["status=contained", "runner=0", "mutation=0", "readbacks=0", "clarifyMissingSlot"], in: app)
        }
    }

    @MainActor
    func testMicDockRemainsExplicitlyUnavailableAndOutsideTextSlice() {
        withFreshApp(caseName: "voice-deferred") { app in
            let mic = app.descendants(matching: .any)["mic-dock"]
            XCTAssertTrue(mic.waitForExistence(timeout: 12))
            mic.press(forDuration: 0.25)

            assertStatus(contains: "语音输入当前不可用", in: app)
            assertProof(contains: ["status=ingress_rejected", "runner=0", "mutation=0", "readbacks=0"], in: app)
        }
    }

    @MainActor
    private func withFreshApp(caseName: String, body: (XCUIApplication) -> Void) {
        let app = XCUIApplication()
        app.launch()
        defer { app.terminate() }
        body(app)

        let proof = app.staticTexts["frontstage-demo-slice-proof"]
        if proof.exists {
            let attachment = XCTAttachment(string: proof.label)
            attachment.name = "\(caseName)-proof.txt"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "\(caseName)-app.png"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    @MainActor
    private func submit(_ text: String, in app: XCUIApplication) {
        let field = app.textFields["frontstage-customer-text-field"]
        XCTAssertTrue(field.waitForExistence(timeout: 12))
        field.tap()
        field.typeText(text)
        let submit = app.buttons["frontstage-customer-text-submit"]
        XCTAssertTrue(submit.exists)
        submit.tap()
    }

    @MainActor
    private func assertStatus(contains text: String, in app: XCUIApplication) {
        let status = app.staticTexts["frontstage-customer-ingress-status"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        XCTAssertTrue(waitForLabel(containing: text, on: status, timeout: 8), "status=\(status.label)")
    }

    @MainActor
    private func assertProof(contains fragments: [String], in app: XCUIApplication) {
        let proof = app.staticTexts["frontstage-demo-slice-proof"]
        XCTAssertTrue(proof.waitForExistence(timeout: 5))
        for fragment in fragments {
            XCTAssertTrue(waitForLabel(containing: fragment, on: proof, timeout: 8), "fragment=\(fragment), proof=\(proof.label)")
        }
    }

    private func waitForLabel(containing text: String, on element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        return XCTWaiter.wait(
            for: [XCTNSPredicateExpectation(predicate: predicate, object: element)],
            timeout: timeout
        ) == .completed
    }
}
