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
        try skipIfS8TrainingWindow()
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
    func testU32ThroughU37DemoFastestPathSkeleton() throws {
        try skipIfS8TrainingWindow()
        let app = XCUIApplication()
        let forceBadPath = ProcessInfo.processInfo.environment["D1H_U32_U37_FORCE_BAD_PATH"] == "1"
            || FileManager.default.fileExists(atPath: Self.badPathFlagURL.path)
        if forceBadPath {
            print("D1H_U32_U37_FORCE_BAD_PATH=true flag=\(Self.badPathFlagURL.path)")
        }
        if forceBadPath {
            app.launchArguments = ["-mockSnapshot", "safetyRefusal", "-mockTheme", "deepSpace"]
        } else {
            app.launchArguments = ["-mockSnapshot", "coldStart", "-mockTheme", "deepSpace", "-forceReduceMotion"]
        }
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 12))
        XCTAssertTrue(waitForAnyElement(["vehicle-cards", "vehicle-cards-mac-panorama"], in: app))

        let micDock = try firstExistingElement(["mic-dock", "mic-dock-safe-area"], in: app)
        micDock.press(forDuration: 0.25)

        XCTAssertTrue(waitForTreeText("我有点冷了", in: app), "mock voice trigger should append user utterance")
        let expectedReadback = forceBadPath ? "D1H_BAD_SAMPLE_SHOULD_NOT_RENDER" : "已为您升到"
        XCTAssertTrue(waitForTreeText(expectedReadback, in: app), "mock readback should appear after voice trigger")
        XCTAssertTrue(waitForAnyElement(["vehicle-card-family.ac", "vehicle-card-ac"], in: app))
    }

    func testU32ThroughU37NegativeSwitchIsAuthored() throws {
        let source = try String(contentsOf: URL(fileURLWithPath: #filePath), encoding: .utf8)
        XCTAssertTrue(source.contains("D1H_U32_U37_FORCE_BAD_PATH"))
        XCTAssertTrue(source.contains(Self.badPathFlagURL.lastPathComponent))
        XCTAssertTrue(source.contains("safetyRefusal"))
    }

    private static let badPathFlagURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent(".maformac-d1h-u32-u37-force-bad-path.flag")

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

    @MainActor
    private func firstExistingElement(_ identifiers: [String], in app: XCUIApplication) throws -> XCUIElement {
        let deadline = Date().addingTimeInterval(12)
        repeat {
            for identifier in identifiers {
                let element = app.descendants(matching: .any)[identifier]
                if element.exists {
                    return element
                }
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        } while Date() < deadline

        let joined = identifiers.joined(separator: ",")
        XCTFail("missing any element: \(joined)")
        throw XCTSkip("required UI element missing")
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

    private func skipIfS8TrainingWindow() throws {
        let environment = ProcessInfo.processInfo.environment
        let skipKeys = ["S8_TRAINING_ACTIVE", "MAFORMAC_S8_TRAINING_ACTIVE", "D1H_SKIP_XCUITESTS"]
        if skipKeys.contains(where: { environment[$0] == "1" || environment[$0] == "true" }) {
            throw XCTSkip("S8 training window active; D1H XCUITest skeleton is authored_pending_run")
        }
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
