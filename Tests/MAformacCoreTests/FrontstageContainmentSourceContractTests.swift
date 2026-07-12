import XCTest

final class FrontstageContainmentSourceContractTests: XCTestCase {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    func testCustomerMicDockCallbacksUseCompositionSessionAndNeverMockPlanner() throws {
        let source = try String(contentsOf: repoRoot.appendingPathComponent("App/ContentView.swift"), encoding: .utf8)

        XCTAssertEqual(occurrences(of: "onMockVoiceSubmit: submitCustomerMicDock", in: source), 2)
        XCTAssertFalse(source.contains("onMockVoiceSubmit: applyMockVoiceColdIntent"))
        let submission = try section(in: source, from: "private func submitCustomerMicDock", until: "private func applyMockVoiceColdIntent")
        XCTAssertTrue(submission.contains("frontstageRuntimeComposition.session"))
        XCTAssertTrue(submission.contains("frontstageRuntimeComposition.routeDemoSlice"))
        XCTAssertTrue(submission.contains("applyDemoSliceExecution"))
        XCTAssertTrue(submission.contains("FrontstageRouteReceiptWriter.writeCurrent"))
        XCTAssertTrue(submission.contains("frontstageRuntimeComposition.isCurrentTurn"))
        XCTAssertTrue(submission.contains("FRONTSTAGE_ROUTE_RECEIPT_CONFIGURATION_REJECTED"))
        XCTAssertTrue(submission.contains("FRONTSTAGE_ROUTE_RECEIPT_WRITE_FAILED"))
        XCTAssertFalse(submission.contains("try? FrontstageRouteReceiptConfiguration.environment"))
        XCTAssertFalse(submission.contains("_ = try? FrontstageRouteReceiptWriter.writeCurrent"))
        XCTAssertFalse(submission.contains("MockVoicePresetPlanner"))
        XCTAssertFalse(submission.contains("applyMockVoiceColdIntent"))
    }

    func testCompositionBindsOnlyOneNarrowDemoSliceRouteAndKeepsMockPlannerOut() throws {
        let source = try String(contentsOf: repoRoot.appendingPathComponent("App/FrontstageRuntimeComposition.swift"), encoding: .utf8)

        XCTAssertTrue(source.contains("let session: FrontstageVoiceSession"))
        XCTAssertTrue(source.contains("private var demoSliceRoute: DemoSliceRoute?"))
        XCTAssertTrue(source.contains("func routeDemoSlice"))
        XCTAssertEqual(occurrences(of: "DemoSliceRoute(", in: source), 1)
        XCTAssertFalse(source.contains("DemoRuntimePartialPlan"))
        XCTAssertFalse(source.contains("MockVoicePresetPlanner"))
    }

    private func occurrences(of needle: String, in source: String) -> Int {
        var count = 0
        var search = source.startIndex..<source.endIndex
        while let range = source.range(of: needle, range: search) {
            count += 1
            search = range.upperBound..<source.endIndex
        }
        return count
    }

    private func section(in source: String, from start: String, until end: String) throws -> String {
        guard let startRange = source.range(of: start) else {
            throw NSError(domain: "FrontstageContainmentSourceContractTests", code: 1)
        }
        let tail = source[startRange.lowerBound...]
        guard let endRange = tail.range(of: end) else { return String(tail) }
        return String(tail[..<endRange.lowerBound])
    }
}
