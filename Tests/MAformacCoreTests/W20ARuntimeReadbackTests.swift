import XCTest
@testable import MAformacCore

final class W20ARuntimeReadbackTests: XCTestCase {
    @MainActor
    func testDirectValueTemperatureReadbackWritesIOSSimReceipt() async throws {
        let output = try await runReadbackAndWriteReceipt(
            observation: RuntimeDestinationProbe.Observation(runtimeTarget: .iosSim, stdoutMarker: "runtime_target=ios_sim")
        )

        XCTAssertEqual(output.receipt.runtimeTarget, "ios_sim")
        XCTAssertEqual(output.payload.outcome.result, .acceptedToolCall)
        XCTAssertTrue(output.payload.readbacks.contains { $0.key == "ac.temp_setpoint[主驾]" && $0.actualValue == "26" })
        XCTAssertTrue(FileManager.default.fileExists(atPath: output.receiptURL.path))
    }

    @MainActor
    func testReceiptDestinationStdoutMatchesRuntimeTarget() async throws {
        let output = try await runReadbackAndWriteReceipt(
            observation: RuntimeDestinationProbe.Observation(runtimeTarget: .iosSim, stdoutMarker: "runtime_target=ios_sim")
        )

        let stdout = try String(contentsOf: output.destinationStdoutURL, encoding: .utf8)

        XCTAssertTrue(stdout.contains("runtime_target=ios_sim"))
        try RuntimeDestinationProbe.validate(stdoutArtifact: output.destinationStdoutURL, receipt: output.receipt)
    }

    @MainActor
    func testReceiptHeadAdapterIRMapAndMountedCatalogMatchLiveRun() async throws {
        let output = try await runReadbackAndWriteReceipt(
            observation: RuntimeDestinationProbe.Observation(runtimeTarget: .iosSim, stdoutMarker: "runtime_target=ios_sim")
        )

        XCTAssertEqual(output.receipt.codeHeadSha, try Self.gitHead())
        XCTAssertEqual(output.receipt.adapterSha, Self.adapterSha)
        XCTAssertEqual(output.receipt.trainpackSha, Self.trainpackSha)
        XCTAssertEqual(output.receipt.irMapFingerprint, ToolContractNormalizer.compiledIRMapFingerprint())
        XCTAssertEqual(output.receipt.mountedToolCatalogSha, DDomainMountedToolCatalog.mountedDemoCatalogSha)
        XCTAssertEqual(output.receipt.nonClaims.adapterLearnedQA, false)
        XCTAssertEqual(output.receipt.nonClaims.candidateStatus, .unsigned)
    }

    @MainActor
    private func runReadbackAndWriteReceipt(
        observation: RuntimeDestinationProbe.Observation
    ) async throws -> W20AReadbackReceiptOutput {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine()
        let completion = #"<tool_call>{"name":"adjust_ac_temperature_to_number","arguments":{"temperature":"26"}}</tool_call>"#
        let runner = try DemoRuntimeSessionRunner.defaultRunner(
            store: store,
            traceLogger: trace,
            speech: speech,
            modelBackend: DDomainToolPlanBackend(completionProvider: { _ in completion })
        )

        let payload = try await runner.run(text: "空调调到26度")
        let receipt = try Self.receipt(observation: observation)
        try RuntimeDestinationProbe.validate(receipt: receipt, against: observation)
        return try Self.writeArtifacts(receipt: receipt, payload: payload, observation: observation)
    }

    private static func receipt(observation: RuntimeDestinationProbe.Observation) throws -> RuntimeAdapterMountReceipt {
        var builder = RuntimeAdapterMountReceiptBuilder()
        builder.mountVerdict = .pass
        builder.runtimeTarget = observation.runtimeTarget.rawValue
        builder.adapterSha = adapterSha
        builder.adapterConfigSha = "adapter-config-local-runtime"
        builder.baseModelID = "Qwen/Qwen3-1.7B"
        builder.baseModelDigest = "qwen3-1.7b-local-fixture"
        builder.tokenizerDigest = "qwen3-tokenizer-local-fixture"
        builder.codeHeadSha = try gitHead()
        builder.trainpackSha = trainpackSha
        builder.decodeContractID = "qwen-tool-call-format.v1"
        builder.irMapFingerprint = ToolContractNormalizer.compiledIRMapFingerprint()
        builder.mountedToolCatalogSha = DDomainMountedToolCatalog.mountedDemoCatalogSha
        builder.caseLedgerRef = "W20A direct-value readback XCTest"
        builder.provenance = .firstExecution
        builder.mountedAt = ISO8601DateFormatter().string(from: Date())
        return try builder.build()
    }

    private static func writeArtifacts(
        receipt: RuntimeAdapterMountReceipt,
        payload: RuntimePresentationPayload,
        observation: RuntimeDestinationProbe.Observation
    ) throws -> W20AReadbackReceiptOutput {
        let directory = artifactDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let receiptURL = directory.appendingPathComponent("runtime-adapter-mount-receipt.v2.json")
        let payloadURL = directory.appendingPathComponent("runtime-readback-payload.json")
        let stdoutURL = directory.appendingPathComponent("ios-destination-stdout.log")
        try RuntimeAdapterMountReceipt.jsonEncoder().encode(receipt).write(to: receiptURL)
        try JSONEncoder().encode(payload).write(to: payloadURL)
        try "\(observation.stdoutMarker)\n".write(to: stdoutURL, atomically: true, encoding: .utf8)
        return W20AReadbackReceiptOutput(
            receipt: receipt,
            payload: payload,
            receiptURL: receiptURL,
            destinationStdoutURL: stdoutURL
        )
    }

    private static func artifactDirectory() -> URL {
        if let override = ProcessInfo.processInfo.environment["W20A_CLOSEOUT_ARTIFACT_DIR"], !override.isEmpty {
            return URL(fileURLWithPath: override, isDirectory: true)
        }
        return URL(fileURLWithPath: "/tmp/w20a-closeout-artifact", isDirectory: true)
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

    private static let adapterSha = "9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6"
    private static let trainpackSha = "fa5690400f67db9ef237dabdb489f58d1ab69961f14d6733d79f9bd7cad33823"
}

private struct W20AReadbackReceiptOutput {
    var receipt: RuntimeAdapterMountReceipt
    var payload: RuntimePresentationPayload
    var receiptURL: URL
    var destinationStdoutURL: URL
}
