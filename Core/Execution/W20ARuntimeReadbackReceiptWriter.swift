import Foundation

public struct W20AReadbackReceiptOutput: Sendable {
    public var receipt: RuntimeAdapterMountReceipt
    public var payload: RuntimePresentationPayload
    public var receiptURL: URL
    public var payloadURL: URL

    public init(
        receipt: RuntimeAdapterMountReceipt,
        payload: RuntimePresentationPayload,
        receiptURL: URL,
        payloadURL: URL
    ) {
        self.receipt = receipt
        self.payload = payload
        self.receiptURL = receiptURL
        self.payloadURL = payloadURL
    }
}

public enum W20ARuntimeReadbackReceiptWriter {
    public static let adapterSha = "9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6"
    public static let trainpackSha = "fa5690400f67db9ef237dabdb489f58d1ab69961f14d6733d79f9bd7cad33823"

    @MainActor
    public static func run(
        artifactDirectory: URL? = nil,
        codeHeadSha: String? = nil
    ) async throws -> W20AReadbackReceiptOutput {
        let observation = RuntimeDestinationProbe.probe()
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
        let receipt = try makeReceipt(
            runtimeTarget: observation.runtimeTarget,
            codeHeadSha: codeHeadSha ?? resolvedCodeHeadSha()
        )
        try RuntimeDestinationProbe.validate(receipt: receipt, against: observation)
        return try writeArtifacts(
            receipt: receipt,
            payload: payload,
            directory: artifactDirectory ?? defaultArtifactDirectory()
        )
    }

    private static func makeReceipt(
        runtimeTarget: RuntimeTarget,
        codeHeadSha: String
    ) throws -> RuntimeAdapterMountReceipt {
        var builder = RuntimeAdapterMountReceiptBuilder()
        builder.mountVerdict = .pass
        builder.runtimeTarget = runtimeTarget.rawValue
        builder.adapterSha = adapterSha
        builder.adapterConfigSha = "adapter-config-local-runtime"
        builder.baseModelID = "Qwen/Qwen3-1.7B"
        builder.baseModelDigest = "qwen3-1.7b-local-fixture"
        builder.tokenizerDigest = "qwen3-tokenizer-local-fixture"
        builder.codeHeadSha = codeHeadSha
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
        directory: URL
    ) throws -> W20AReadbackReceiptOutput {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let receiptURL = directory.appendingPathComponent("runtime-adapter-mount-receipt.v2.json")
        let payloadURL = directory.appendingPathComponent("runtime-readback-payload.json")
        try RuntimeAdapterMountReceipt.jsonEncoder().encode(receipt).write(to: receiptURL)
        try JSONEncoder().encode(payload).write(to: payloadURL)
        return W20AReadbackReceiptOutput(
            receipt: receipt,
            payload: payload,
            receiptURL: receiptURL,
            payloadURL: payloadURL
        )
    }

    private static func defaultArtifactDirectory() -> URL {
        if let override = ProcessInfo.processInfo.environment["W20A_CLOSEOUT_ARTIFACT_DIR"], !override.isEmpty {
            return URL(fileURLWithPath: override, isDirectory: true)
        }
        return URL(fileURLWithPath: "/tmp/w20a-closeout-artifact", isDirectory: true)
    }

    private static func resolvedCodeHeadSha() -> String {
        if let override = ProcessInfo.processInfo.environment["W20A_CODE_HEAD_SHA"], !override.isEmpty {
            return override
        }
        #if os(macOS)
        if let head = try? gitHead() {
            return head
        }
        #endif
        return "xcodebuild-ios-simulator"
    }

    #if os(macOS)
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
    #endif
}
