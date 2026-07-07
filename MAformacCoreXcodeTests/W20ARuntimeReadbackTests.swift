import XCTest
import Foundation
@testable import MAformacIOS

final class W20ARuntimeReadbackTests: XCTestCase {
    @MainActor
    func testReceiptDestinationStdoutMatchesRuntimeTarget() async throws {
        let output = try await W20ARuntimeReadbackReceiptWriter.run()

        XCTAssertEqual(output.receipt.runtimeTarget, "ios_sim")
        XCTAssertTrue(output.payload.readbacks.contains { $0.key == "ac.temp_setpoint[主驾]" && $0.actualValue == "26" })
        XCTAssertTrue(FileManager.default.fileExists(atPath: output.receiptURL.path))
        print("runtime_target=\(output.receipt.runtimeTarget)")
        let receiptData = try RuntimeAdapterMountReceipt.jsonEncoder().encode(output.receipt)
        print("W20A_RUNTIME_RECEIPT_JSON_BASE64=\(receiptData.base64EncodedString())")
    }
}
