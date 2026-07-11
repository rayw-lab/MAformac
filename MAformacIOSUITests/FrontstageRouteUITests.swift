import XCTest

final class FrontstageRouteUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testReleaseCustomerTwoTurnRunIdentityContract() throws {
        #if os(macOS)
        let configuration = try FrontstageRouteUITestRunConfiguration(
            formalEnvironment: ProcessInfo.processInfo.environment
        )
        let runDirectory = configuration.runDirectory
        let runID = configuration.runID
        let nonce = configuration.runNonce
        let sourceHead = configuration.sourceHeadSHA
        let app = XCUIApplication()
        app.launchEnvironment = configuration.appLaunchEnvironment
        app.launch()
        defer { app.terminate() }

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 12))
        let mic = app.descendants(matching: .any)["mic-dock"]
        XCTAssertTrue(mic.waitForExistence(timeout: 12))
        let receiptURL = runDirectory.appendingPathComponent("receipts/c1/frontstage-route-receipt.v1.json")

        mic.press(forDuration: 0.25)
        XCTAssertTrue(waitForReceipt(receiptURL))
        let first = try preserveReceipt(from: receiptURL, sequence: 1)

        mic.press(forDuration: 0.25)
        XCTAssertTrue(waitForReceipt(receiptURL, sequence: 2))
        let second = try preserveReceipt(from: receiptURL, sequence: 2)

        XCTAssertEqual(first["run_id"] as? String, runID)
        XCTAssertEqual(second["run_id"] as? String, runID)
        XCTAssertEqual(first["run_nonce"] as? String, nonce)
        XCTAssertEqual(second["run_nonce"] as? String, nonce)
        XCTAssertEqual(first["session_id"] as? String, second["session_id"] as? String)
        XCTAssertEqual(first["sequence"] as? Int, 1)
        XCTAssertEqual(second["sequence"] as? Int, 2)
        XCTAssertNotEqual(first["turn_id"] as? String, second["turn_id"] as? String)
        XCTAssertNotEqual(first["event_id"] as? String, second["event_id"] as? String)
        XCTAssertEqual(first["source_head_sha"] as? String, sourceHead)
        XCTAssertEqual(first["tested_checkout_sha"] as? String, sourceHead)
        XCTAssertEqual(second["source_head_sha"] as? String, sourceHead)
        XCTAssertEqual(second["tested_checkout_sha"] as? String, sourceHead)
        XCTAssertEqual(first["matrix_source_sha256"] as? String, second["matrix_source_sha256"] as? String)
        XCTAssertEqual(first["runtime_contract_bundle_digest"] as? String, second["runtime_contract_bundle_digest"] as? String)
        XCTAssertEqual(first["app_executable_sha256"] as? String, second["app_executable_sha256"] as? String)
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

    private func preserveReceipt(from url: URL, sequence: Int) throws -> [String: Any] {
        let data = try Data(contentsOf: url)
        let body = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        XCTAssertEqual(body["sequence"] as? Int, sequence)
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.json")
        attachment.name = String(format: "frontstage-route-turn-%04d.json", sequence)
        attachment.lifetime = .keepAlways
        add(attachment)
        return body
    }
    #endif
}
