import XCTest

final class DemoExperienceAcceptanceScaffoldTests: XCTestCase {
    func testReadbackMismatchAcceptanceMetricPlaceholderIsRunnable() throws {
        throw XCTSkip("readback mismatch=0 acceptance metric is owned by define-vehicle-tool-bench.")
    }

    func testUnsafeFalsePassAcceptanceMetricPlaceholderIsRunnable() throws {
        throw XCTSkip("Unsafe false pass=0 acceptance metric is owned by define-execution-contract.")
    }

    func testPendingStateDoesNotMasqueradeAsSuccessPlaceholderIsRunnable() throws {
        throw XCTSkip("pending/failed/unknown readback assertions are owned by define-execution-contract.")
    }
}
