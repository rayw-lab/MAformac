import XCTest

final class FrontstageCustomerIngressUITests: XCTestCase {
    @MainActor
    func testVisibleTextSubmitAndMicDockUnavailableWithoutASR() {
        let app = XCUIApplication()
        app.launch()
        defer { app.terminate() }

        let field = app.textFields["frontstage-customer-text-field"]
        XCTAssertTrue(field.waitForExistence(timeout: 12))
        let status = app.staticTexts["frontstage-customer-ingress-status"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("打开空调\n")
        let submit = app.buttons["frontstage-customer-text-submit"]
        XCTAssertTrue(submit.exists)
        XCTAssertTrue(waitForLabel("打开空调", on: status, timeout: 5))

        let mic = app.descendants(matching: .any)["mic-dock"]
        XCTAssertTrue(mic.exists)
        mic.press(forDuration: 0.25)
        XCTAssertTrue(waitForLabel("语音输入当前不可用", on: status, timeout: 5))
    }

    private func waitForLabel(_ label: String, on element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "label == %@", label)
        return XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: predicate, object: element)], timeout: timeout) == .completed
    }
}
