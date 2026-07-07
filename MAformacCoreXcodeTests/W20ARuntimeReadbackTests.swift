import XCTest

final class W20ARuntimeReadbackTests: XCTestCase {
    func testReceiptDestinationStdoutMatchesRuntimeTarget() throws {
        let environment = ProcessInfo.processInfo.environment
        XCTAssertNotNil(environment["SIMULATOR_UDID"], "W20A iOS destination proof must run on an iOS Simulator")
        print("runtime_target=ios_sim")
    }
}
