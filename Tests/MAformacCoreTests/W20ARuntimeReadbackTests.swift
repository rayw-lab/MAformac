import XCTest
@testable import MAformacCore

final class W20ARuntimeReadbackTests: XCTestCase {
    @MainActor
    func testDirectValueTemperatureReadbackWritesIOSSimReceipt() async throws {
        let output = try await W20ARuntimeReadbackReceiptWriter.run(
            artifactDirectory: temporaryArtifactDirectory("direct-value")
        )
        let probedTarget = RuntimeDestinationProbe.probe().runtimeTarget.rawValue

        XCTAssertEqual(output.receipt.runtimeTarget, probedTarget)
        XCTAssertTrue(output.payload.readbacks.contains { $0.key == "ac.temp_setpoint[主驾]" && $0.actualValue == "26" })
        XCTAssertTrue(FileManager.default.fileExists(atPath: output.receiptURL.path))
    }

    @MainActor
    func testMacEnvironmentCannotForgeIOSSimReceiptWithSameWriter() async throws {
        let output = try await W20ARuntimeReadbackReceiptWriter.run(
            artifactDirectory: temporaryArtifactDirectory("mac-negative")
        )

        guard RuntimeDestinationProbe.probe().runtimeTarget == .mac else {
            throw XCTSkip("Mac negative runs only outside iOS Simulator")
        }

        XCTAssertEqual(output.receipt.runtimeTarget, "mac")
        XCTAssertNotEqual(output.receipt.runtimeTarget, "ios_sim")
    }

    @MainActor
    func testReceiptDestinationStdoutMatchesRuntimeTarget() async throws {
        let output = try await W20ARuntimeReadbackReceiptWriter.run(
            artifactDirectory: temporaryArtifactDirectory("stdout-negative")
        )
        let fakeStdout = output.receiptURL.deletingLastPathComponent().appendingPathComponent("ios-destination-stdout.log")
        try "runtime_target=ios_sim\n".write(to: fakeStdout, atomically: true, encoding: .utf8)

        XCTAssertThrowsError(try RuntimeDestinationProbe.validate(stdoutArtifact: fakeStdout, receipt: output.receipt))
    }

    @MainActor
    func testReceiptHeadAdapterIRMapAndMountedCatalogMatchLiveRun() async throws {
        let output = try await W20ARuntimeReadbackReceiptWriter.run(
            artifactDirectory: temporaryArtifactDirectory("head-catalog")
        )

        XCTAssertEqual(output.receipt.codeHeadSha, try Self.gitHead())
        XCTAssertEqual(output.receipt.adapterSha, W20ARuntimeReadbackReceiptWriter.adapterSha)
        XCTAssertEqual(output.receipt.trainpackSha, W20ARuntimeReadbackReceiptWriter.trainpackSha)
        XCTAssertEqual(output.receipt.irMapFingerprint, ToolContractNormalizer.compiledIRMapFingerprint())
        XCTAssertEqual(output.receipt.mountedToolCatalogSha, DDomainMountedToolCatalog.mountedDemoCatalogSha)
        XCTAssertEqual(output.receipt.nonClaims.adapterLearnedQA, false)
        XCTAssertEqual(output.receipt.nonClaims.candidateStatus, .unsigned)
    }

    private func temporaryArtifactDirectory(_ name: String) -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("w20a-readback-\(name)-\(UUID().uuidString)", isDirectory: true)
    }

    private static func gitHead() throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["rev-parse", "HEAD"]
        process.currentDirectoryURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
