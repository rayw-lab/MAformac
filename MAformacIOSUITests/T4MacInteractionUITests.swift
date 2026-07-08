import XCTest

final class T4MacInteractionUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMacCardKeyboardAndMicShortcutPaths() throws {
        #if os(macOS)
        let app = XCUIApplication()
        app.launchArguments = ["-mockSnapshot", "cooling", "-mockTheme", "ivory"]
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 12))
        let firstCard = app.descendants(matching: .any)["vehicle-card-family.ac"]
        XCTAssertTrue(firstCard.waitForExistence(timeout: 12))

        firstCard.typeKey(.return, modifierFlags: [])
        XCTAssertTrue(app.descendants(matching: .any)["expanded-ac"].waitForExistence(timeout: 4))
        app.typeKey(.escape, modifierFlags: [])

        app.typeKey(.space, modifierFlags: [.option])
        XCTAssertTrue(app.descendants(matching: .any)["mic-dock"].exists)
        #else
        throw XCTSkip("T4 macOS interaction XCUITest is authored here but runs only under a macOS UI test host.")
        #endif
    }
}
