import XCTest

final class FrontstageRouteUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCustomerContainmentTwoTurnPreservesForeignRunIdentity() throws {
        #if os(macOS)
        let runDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("frontstage-ui-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: runDirectory) }

        let runID = "frontstage-ui-run"
        let nonce = "0123456789abcdef0123456789abcdef"
        let sourceHead = try gitHead()
        let app = XCUIApplication()
        app.launchEnvironment = [
            "C1_FRONTSTAGE_RECEIPT_EMIT": "1",
            "C1_FRONTSTAGE_RUN_ID": runID,
            "C1_FRONTSTAGE_RUN_NONCE": nonce,
            "C1_RUN_DIR": runDirectory.path,
            "C1_FRONTSTAGE_SOURCE_HEAD_SHA": sourceHead
        ]
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 12))
        let mic = app.descendants(matching: .any)["mic-dock"]
        XCTAssertTrue(mic.waitForExistence(timeout: 12))
        mic.press(forDuration: 0.25)
        let receiptURL = runDirectory.appendingPathComponent("receipts/c1/frontstage-route-receipt.v1.json")
        XCTAssertTrue(waitForReceipt(receiptURL))
        let first = try receipt(at: receiptURL)

        mic.press(forDuration: 0.25)
        XCTAssertTrue(waitForReceipt(receiptURL, sequence: 2))
        let second = try receipt(at: receiptURL)

        XCTAssertEqual(first["run_id"] as? String, runID)
        XCTAssertEqual(second["run_id"] as? String, runID)
        XCTAssertEqual(first["run_nonce"] as? String, nonce)
        XCTAssertEqual(second["run_nonce"] as? String, nonce)
        XCTAssertEqual(first["session_id"] as? String, second["session_id"] as? String)
        XCTAssertEqual(first["sequence"] as? Int, 1)
        XCTAssertEqual(second["sequence"] as? Int, 2)
        XCTAssertNotEqual(first["turn_id"] as? String, second["turn_id"] as? String)
        XCTAssertNotEqual(first["event_id"] as? String, second["event_id"] as? String)
        XCTAssertEqual(second["result"] as? String, "refusal_no_available_tool")
        XCTAssertEqual(second["state_mutation"] as? Bool, false)
        XCTAssertEqual(second["readback_count"] as? Int, 0)
        #else
        throw XCTSkip("frontstage route UI proof is a macOS desktop-operator-equivalent test")
        #endif
    }

    #if os(macOS)
    private func waitForReceipt(_ url: URL, sequence: Int? = nil) -> Bool {
        let deadline = Date().addingTimeInterval(12)
        repeat {
            if let receipt = try? receipt(at: url), sequence == nil || receipt["sequence"] as? Int == sequence {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        } while Date() < deadline
        return false
    }

    private func receipt(at url: URL) throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any] ?? [:]
    }

    private func gitHead() throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["rev-parse", "HEAD"]
        process.currentDirectoryURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let output = Pipe()
        process.standardOutput = output
        try process.run()
        process.waitUntilExit()
        return String(decoding: output.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    #endif
}
