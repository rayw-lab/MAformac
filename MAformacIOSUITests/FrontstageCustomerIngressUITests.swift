import XCTest
#if os(macOS)
import AppKit
#endif

final class FrontstageCustomerIngressUITests: XCTestCase {
    @MainActor
    func testDemoSliceP1OpenACExecutesWithAppVisibleProof() {
        withFreshApp(caseName: "P1-open-ac") { app in
            submit("打开空调", in: app)

            assertStatus(contains: "空调已打开", in: app)
            assertVisibleACCard(contains: "开", in: app)
            assertVisibleDialogue(user: "打开空调", assistant: "空调已打开", in: app)
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
            assertVisibleACCard(contains: "22", in: app)
            assertVisibleDialogue(user: "把空调调到22度", assistant: "22", in: app)
            assertProof(contains: [
                "status=executed",
                "runner=1",
                "mutation=2",
                "matrix_id=4",
                "contract_row_id=c1_airControl_000164",
                "ac.power=on",
                "ac.temp_setpoint[主驾]=22",
            ], in: app)
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
    func testDemoSliceN2UnreviewedWindowShorthandFailsClosed() {
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
            let attachment = XCTAttachment(string: textContent(of: proof))
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
        XCTAssertTrue(field.isHittable, "customer text field must be hittable in the safe area")
        XCTAssertGreaterThan(field.frame.maxY, field.frame.minY)
        XCTAssertLessThanOrEqual(field.frame.maxY, app.frame.maxY)
        field.tap()
#if os(macOS)
        let pasteboard = NSPasteboard.general
        let previousPasteboardString = pasteboard.string(forType: .string)
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        field.typeKey("v", modifierFlags: .command)
        pasteboard.clearContents()
        if let previousPasteboardString {
            pasteboard.setString(previousPasteboardString, forType: .string)
        }
#else
        field.typeText(text)
#endif
        let submit = app.buttons["frontstage-customer-text-submit"]
        XCTAssertTrue(submit.waitForExistence(timeout: 5))
        XCTAssertTrue(submit.isHittable, "customer submit button must be hittable above the keyboard")
        XCTAssertGreaterThan(submit.frame.maxY, submit.frame.minY)
        XCTAssertLessThanOrEqual(submit.frame.maxY, app.frame.maxY)
        let geometry = XCTAttachment(string: "field.frame=\(field.frame);field.exists=\(field.exists);field.hittable=\(field.isHittable);submit.frame=\(submit.frame);submit.exists=\(submit.exists);submit.hittable=\(submit.isHittable);app.frame=\(app.frame)")
        geometry.name = "customer-ingress-geometry.txt"
        geometry.lifetime = .keepAlways
        add(geometry)
        submit.tap()
    }

    @MainActor
    private func assertVisibleACCard(contains text: String, in app: XCUIApplication) {
        let cards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'vehicle-card-'"))
        let deadline = Date().addingTimeInterval(8)
        while Date() < deadline {
            if let card = cards.allElementsBoundByIndex.first(where: { $0.label.contains("空调") && $0.label.contains(text) }),
               card.exists,
               card.isHittable {
                return
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        let labels = cards.allElementsBoundByIndex.map(\.label).joined(separator: " | ")
        XCTFail("visible AC card did not contain '\(text)': \(labels)")
    }

    @MainActor
    private func assertVisibleDialogue(user: String, assistant: String, in app: XCUIApplication) {
        let stream = app.descendants(matching: .any)["dialogue-stream"]
        XCTAssertTrue(stream.waitForExistence(timeout: 8))
        XCTAssertGreaterThan(stream.frame.width * stream.frame.height, 0)
        let deadline = Date().addingTimeInterval(8)
        while Date() < deadline {
            let users = app.staticTexts.matching(identifier: "dialogue-bubble-user").allElementsBoundByIndex
            let assistants = app.staticTexts.matching(identifier: "dialogue-bubble-assistant").allElementsBoundByIndex
            if let userBubble = users.first(where: { $0.label.contains(user) }),
               let assistantBubble = assistants.first(where: { $0.label.contains(assistant) }),
               userBubble.exists, assistantBubble.exists,
               userBubble.frame.width > 0, userBubble.frame.height > 0,
               assistantBubble.frame.width > 0, assistantBubble.frame.height > 0 {
                let userIntersection = userBubble.frame.intersection(stream.frame)
                let assistantIntersection = assistantBubble.frame.intersection(stream.frame)
                if userIntersection.width > 0, userIntersection.height > 0,
                   assistantIntersection.width > 0, assistantIntersection.height > 0 {
                    return
                }
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        let users = app.staticTexts.matching(identifier: "dialogue-bubble-user").allElementsBoundByIndex.map(\.label).joined(separator: " | ")
        let assistants = app.staticTexts.matching(identifier: "dialogue-bubble-assistant").allElementsBoundByIndex.map(\.label).joined(separator: " | ")
        XCTFail("dialogue viewport assertion failed; users=\(users); assistants=\(assistants); stream.frame=\(stream.frame)")
    }

    @MainActor
    private func assertStatus(contains text: String, in app: XCUIApplication) {
        let status = app.staticTexts["frontstage-customer-ingress-status"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        XCTAssertTrue(waitForText(containing: text, on: status, timeout: 8), "status=\(textContent(of: status))")
    }

    @MainActor
    private func assertProof(contains fragments: [String], in app: XCUIApplication) {
        let proof = app.staticTexts["frontstage-demo-slice-proof"]
        XCTAssertTrue(proof.waitForExistence(timeout: 5))
        for fragment in fragments {
            XCTAssertTrue(waitForText(containing: fragment, on: proof, timeout: 8), "fragment=\(fragment), proof=\(textContent(of: proof))")
        }
    }

    private func waitForText(containing text: String, on element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@ OR value CONTAINS %@", text, text)
        return XCTWaiter.wait(
            for: [XCTNSPredicateExpectation(predicate: predicate, object: element)],
            timeout: timeout
        ) == .completed
    }

    @MainActor
    private func textContent(of element: XCUIElement) -> String {
        if !element.label.isEmpty {
            return element.label
        }
        return element.value as? String ?? ""
    }
}
