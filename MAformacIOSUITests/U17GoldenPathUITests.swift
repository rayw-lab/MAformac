import XCTest

final class U17GoldenPathUITests: XCTestCase {
    private let goldenPathArguments = [
        "-goldenPathID",
        "uiue_g9b_ac_success_deep_space"
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testGoldenPathLaunchesAndCapturesCoreUI() throws {
        let evidenceDirectory = try makeEvidenceDirectory()
        let app = XCUIApplication()
        app.launchArguments = goldenPathArguments
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 12))
        XCTAssertTrue(waitForElement("context-band", in: app))
        XCTAssertTrue(waitForElement("demo-orb", in: app))
        XCTAssertTrue(waitForElement("dialogue-stream", in: app))
        try writeUITree(for: app, to: evidenceDirectory)
        XCTAssertTrue(waitForAnyElement(["mic-dock", "mic-dock-safe-area"], in: app))
        XCTAssertTrue(waitForAnyElement(["vehicle-cards", "vehicle-cards-mac-panorama"], in: app))

        let tree = try writeUITree(for: app, to: evidenceDirectory)
        XCTAssertTrue(tree.contains("context-band"))
        XCTAssertTrue(tree.contains("mic-dock-safe-area"))
        XCTAssertTrue(tree.contains("vehicle-card-family."))
    }

    @MainActor
    private func waitForElement(_ identifier: String, in app: XCUIApplication) -> Bool {
        app.descendants(matching: .any)[identifier].waitForExistence(timeout: 12)
    }

    @MainActor
    private func waitForAnyElement(_ identifiers: [String], in app: XCUIApplication) -> Bool {
        let deadline = Date().addingTimeInterval(12)
        repeat {
            if identifiers.contains(where: { app.descendants(matching: .any)[$0].exists }) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        } while Date() < deadline

        return false
    }

    private func makeEvidenceDirectory() throws -> URL {
        let environment = ProcessInfo.processInfo.environment
        let directory: URL
        if let rawPath = environment["U17_L0_EVIDENCE_DIR"], !rawPath.isEmpty {
            directory = URL(fileURLWithPath: rawPath, isDirectory: true)
        } else {
            directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent("maformac-u17-l0", isDirectory: true)
        }

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    @discardableResult
    @MainActor
    private func writeUITree(for app: XCUIApplication, to evidenceDirectory: URL) throws -> String {
        let tree = app.debugDescription
        let treeURL = evidenceDirectory.appendingPathComponent("u17-ui-tree.txt")
        try tree.write(to: treeURL, atomically: true, encoding: .utf8)
        print("U17_UI_TREE_BEGIN")
        print(tree)
        print("U17_UI_TREE_END")
        return tree
    }
}
