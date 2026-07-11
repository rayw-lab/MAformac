import XCTest

#if os(macOS)
import AppKit
#endif

final class FrontstageRouteUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testReleaseCustomerTwoTurnRunIdentityContract() throws {
        #if os(macOS)
        let suppliedEnvironment = ProcessInfo.processInfo.environment
        let ownsRunDirectory = suppliedEnvironment["C1_RUN_DIR"] == nil
        let runDirectory = suppliedEnvironment["C1_RUN_DIR"].map { URL(fileURLWithPath: $0) }
            ?? FileManager.default.temporaryDirectory
                .appendingPathComponent("frontstage-ui-\(UUID().uuidString)", isDirectory: true)
        if ownsRunDirectory {
            defer { try? FileManager.default.removeItem(at: runDirectory) }
        }

        let runID = suppliedEnvironment["C1_FRONTSTAGE_RUN_ID"] ?? "frontstage-ui-run"
        let nonce = suppliedEnvironment["C1_FRONTSTAGE_RUN_NONCE"] ?? "0123456789abcdef0123456789abcdef"
        let sourceHead: String
        if let suppliedSourceHead = suppliedEnvironment["C1_FRONTSTAGE_SOURCE_HEAD_SHA"] {
            sourceHead = suppliedSourceHead
        } else {
            sourceHead = try gitHead()
        }
        let receiptEmit = suppliedEnvironment["C1_FRONTSTAGE_RECEIPT_EMIT"] ?? "1"
        let app = XCUIApplication()
        app.launchEnvironment = [
            "C1_FRONTSTAGE_RECEIPT_EMIT": receiptEmit,
            "C1_FRONTSTAGE_RUN_ID": runID,
            "C1_FRONTSTAGE_RUN_NONCE": nonce,
            "C1_RUN_DIR": runDirectory.path,
            "C1_FRONTSTAGE_SOURCE_HEAD_SHA": sourceHead
        ]
        app.launch()
        defer { app.terminate() }

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 12))
        let mic = app.descendants(matching: .any)["mic-dock"]
        XCTAssertTrue(mic.waitForExistence(timeout: 12))
        let receiptURL = runDirectory.appendingPathComponent("receipts/c1/frontstage-route-receipt.v1.json")
        let copiesDirectory = runDirectory.appendingPathComponent("copies", isDirectory: true)
        try FileManager.default.createDirectory(at: copiesDirectory, withIntermediateDirectories: true)
        let appExecutable = try releaseAppExecutable()

        mic.press(forDuration: 0.25)
        XCTAssertTrue(waitForReceipt(receiptURL))
        let firstCopy = copiesDirectory.appendingPathComponent("turn-0001.json")
        let first = try copyReceipt(from: receiptURL, to: firstCopy)
        try assertOwnerChecker(
            receiptURL: firstCopy,
            appExecutable: appExecutable,
            sourceHead: sourceHead,
            runID: runID,
            nonce: nonce
        )

        mic.press(forDuration: 0.25)
        XCTAssertTrue(waitForReceipt(receiptURL, sequence: 2))
        let secondCopy = copiesDirectory.appendingPathComponent("turn-0002.json")
        let second = try copyReceipt(from: receiptURL, to: secondCopy)
        try assertOwnerChecker(
            receiptURL: secondCopy,
            appExecutable: appExecutable,
            sourceHead: sourceHead,
            runID: runID,
            nonce: nonce
        )

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

    private func copyReceipt(from source: URL, to destination: URL) throws -> [String: Any] {
        try FileManager.default.copyItem(at: source, to: destination)
        return try receipt(at: destination)
    }

    private func assertOwnerChecker(
        receiptURL: URL,
        appExecutable: URL,
        sourceHead: String,
        runID: String,
        nonce: String
    ) throws {
        let root = repositoryRoot()
        let process = Process()
        process.executableURL = root.appendingPathComponent(".venv/bin/python")
        process.arguments = [
            "Tools/checks/check_frontstage_route_receipt.py",
            "--receipt", receiptURL.path,
            "--schema", root.appendingPathComponent("contracts/schemas/frontstage-route-receipt.schema.json").path,
            "--matrix", root.appendingPathComponent("contracts/demo-capability-matrix.json").path,
            "--runtime-bundle-manifest", root.appendingPathComponent("generated/demo-runtime-contract-bundle.manifest.json").path,
            "--app-executable", appExecutable.path,
            "--expected-head", sourceHead,
            "--expected-run-id", runID,
            "--expected-run-nonce", nonce
        ]
        process.currentDirectoryURL = root
        let output = Pipe()
        process.standardOutput = output
        process.standardError = output
        try process.run()
        process.waitUntilExit()
        let text = String(decoding: output.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        XCTAssertEqual(process.terminationStatus, 0, text)
    }

    private func releaseAppExecutable() throws -> URL {
        let applications = NSRunningApplication.runningApplications(withBundleIdentifier: "lab.rayw.MAformac.mac")
        let bundleURL = try XCTUnwrap(applications.first?.bundleURL)
        let executable = bundleURL.appendingPathComponent("Contents/MacOS/MAformacMac")
        XCTAssertTrue(FileManager.default.isExecutableFile(atPath: executable.path))
        return executable
    }

    private func gitHead() throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["rev-parse", "HEAD"]
        process.currentDirectoryURL = repositoryRoot()
        let output = Pipe()
        process.standardOutput = output
        try process.run()
        process.waitUntilExit()
        return String(decoding: output.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
    #endif
}
