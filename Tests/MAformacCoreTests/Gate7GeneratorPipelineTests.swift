import Foundation
import XCTest
@testable import MAformacCore

final class Gate7GeneratorPipelineTests: XCTestCase {
    func testVendorEnumG1FailsClosedWhenGeneratorAndJudgeShareVendor() throws {
        let manifest = try loadManifest()
        let request = try makeRequest(manifest: manifest)
        let provider = Gate7MockLLMProvider(
            vendor: .openai,
            responsesByStage: [.generator: Gate7ProviderResponse(status: .pass, utterances: diverseUtterances())]
        )
        let pipeline = Gate7GeneratorPipeline(generator: provider, judge: provider)

        let receipt = try pipeline.run(request)

        XCTAssertEqual(receipt.status, .blocked)
        XCTAssertEqual(receipt.reasons, ["same_vendor_generator_judge"])
    }

    func testLiveProviderPathIsBlockedR7WithoutCallingCloud() throws {
        let manifest = try loadManifest()
        let request = try makeRequest(manifest: manifest)
        let pipeline = Gate7GeneratorPipeline(
            generator: Gate7BlockedLiveLLMProvider(vendor: .openai),
            judge: Gate7MockLLMProvider(vendor: .anthropic, responsesByStage: [:])
        )

        let receipt = try pipeline.run(request)

        XCTAssertEqual(receipt.status, .blockedR7)
        XCTAssertEqual(receipt.reasons, ["blocked_r7_live_llm_provider_path"])
        XCTAssertTrue(receipt.attempts.isEmpty)
    }

    func testPipelineConsumesRealSubsetManifestAndAttachesC6SubsetMetadata() throws {
        let manifest = try loadManifest()
        let request = try makeRequest(manifest: manifest)
        let pipeline = Gate7GeneratorPipeline(
            generator: Gate7MockLLMProvider(
                vendor: .openai,
                responsesByStage: [.generator: Gate7ProviderResponse(status: .pass, utterances: diverseUtterances())]
            ),
            judge: Gate7MockLLMProvider(
                vendor: .anthropic,
                responsesByStage: [.judge: Gate7ProviderResponse(status: .pass)]
            )
        )

        let receipt = try pipeline.run(request)

        XCTAssertEqual(receipt.status, .pass)
        XCTAssertEqual(receipt.samples.count, 3)
        let sample = try XCTUnwrap(receipt.samples.first)
        XCTAssertEqual(sample.expectedToolCalls.map(\.name), [request.targetToolName])
        XCTAssertEqual(sample.metadata.subsetPolicyDigest, manifest.meta.groupingContractDigest)
        XCTAssertEqual(sample.metadata.groupID, request.manifestEntry.groupID)
        XCTAssertEqual(sample.metadata.mountedToolCount, request.manifestEntry.toolIDsOrdered.count)
        XCTAssertEqual(sample.metadata.tokenCount, request.manifestEntry.toolTokens)
        XCTAssertEqual(sample.metadata.subsetContext.subsetGroupID, request.manifestEntry.groupID)
        XCTAssertEqual(sample.metadata.subsetContext.subsetPolicyID, request.manifestEntry.subsetPolicyID)
        XCTAssertEqual(receipt.dataGateReceipt?.status, "data_gate_ready")
    }

    func testExecutionContractRecordsParseErrorRetries() throws {
        let manifest = try loadManifest()
        let request = try makeRequest(manifest: manifest)
        let pipeline = Gate7GeneratorPipeline(
            generator: Gate7MockLLMProvider(
                vendor: .openai,
                responsesByStage: [
                    .generator: Gate7ProviderResponse(status: .parseError, errorCode: "json_parse_error")
                ]
            ),
            judge: Gate7MockLLMProvider(vendor: .anthropic, responsesByStage: [:]),
            executionContract: Gate7ExecutionContract(maxAttempts: 2, timeoutMilliseconds: 10)
        )

        let receipt = try pipeline.run(request)

        XCTAssertEqual(receipt.status, .retryExhausted)
        XCTAssertEqual(receipt.attempts.count, 2)
        XCTAssertEqual(Set(receipt.attempts.map(\.errorCode)), ["json_parse_error"])
    }

    func testExecutionContractRecordsTimeoutPolicyOnAttemptReceipt() throws {
        let manifest = try loadManifest()
        let request = try makeRequest(manifest: manifest)
        let pipeline = Gate7GeneratorPipeline(
            generator: SlowGate7Provider(
                vendor: .openai,
                response: Gate7ProviderResponse(status: .pass, utterances: diverseUtterances()),
                delaySeconds: 0.02
            ),
            judge: Gate7MockLLMProvider(vendor: .anthropic, responsesByStage: [:]),
            executionContract: Gate7ExecutionContract(maxAttempts: 1, timeoutMilliseconds: 1)
        )

        let receipt = try pipeline.run(request)

        XCTAssertEqual(receipt.status, .retryExhausted)
        let attempt = try XCTUnwrap(receipt.attempts.first)
        XCTAssertEqual(attempt.status, Gate7PipelineStatus.timeout.rawValue)
        XCTAssertEqual(attempt.errorCode, "timeout_exceeded")
        XCTAssertEqual(attempt.timeoutPolicyMilliseconds, 1)
        XCTAssertGreaterThanOrEqual(attempt.elapsedMilliseconds, 1)
        XCTAssertTrue(attempt.timedOut)
    }

    func testAttemptReceiptCarriesRawPayloadDigestWithoutRawBody() throws {
        let manifest = try loadManifest()
        let request = try makeRequest(manifest: manifest)
        let rawPayload = "{\"debug\":\"generator-payload\"}"
        let pipeline = Gate7GeneratorPipeline(
            generator: Gate7MockLLMProvider(
                vendor: .openai,
                responsesByStage: [
                    .generator: Gate7ProviderResponse(
                        status: .parseError,
                        errorCode: "json_parse_error",
                        rawPayload: rawPayload
                    )
                ]
            ),
            judge: Gate7MockLLMProvider(vendor: .anthropic, responsesByStage: [:]),
            executionContract: Gate7ExecutionContract(maxAttempts: 1, timeoutMilliseconds: 30_000)
        )

        let receipt = try pipeline.run(request)

        let attempt = try XCTUnwrap(receipt.attempts.first)
        XCTAssertEqual(attempt.rawPayloadSHA256, C6Hash.sha256Hex(Data(rawPayload.utf8)))
        XCTAssertEqual(attempt.rawPayloadBytes, Data(rawPayload.utf8).count)
        let encoded = String(data: try JSONEncoder().encode(attempt), encoding: .utf8) ?? ""
        XCTAssertFalse(encoded.contains(rawPayload), "attempt receipt keeps raw payload digest/size only, not the raw body")
    }

    func testFourDeterministicGatesBlockDiversityDedupeRedactionAndDecontamination() throws {
        let manifest = try loadManifest()
        var request = try makeRequest(manifest: manifest)
        request.heldOutCandidates = [
            C5DataGateCandidate(
                sampleID: "heldout-1",
                split: "heldout",
                bucket: "heldout_test",
                caseID: "heldout-1",
                parentSemanticID: "heldout.parent",
                device: request.device,
                toolName: "different_tool",
                valueType: "SPOT",
                templateFamily: "heldout_template",
                generatorSource: "anthropic",
                mustNotTrain: true,
                sourceAuthorization: "authorized_fixture",
                inputText: "空调打开",
                assistantText: "",
                hasActionToolCall: false,
                hasSharedWrapper: false,
                masking: C5MaskingFlags()
            )
        ]
        let metadata = try sampleMetadata(manifest: manifest, entry: request.manifestEntry)
        let samples = [
            Gate7GeneratedSample(
                sampleID: "sample-1",
                utterance: "AH8 打开空调",
                expectedToolCalls: [C6ToolCall(name: request.targetToolName, arguments: [:])],
                metadata: metadata
            ),
            Gate7GeneratedSample(
                sampleID: "sample-2",
                utterance: "AH8 打开空调",
                expectedToolCalls: [C6ToolCall(name: request.targetToolName, arguments: [:])],
                metadata: metadata
            )
        ]

        let result = Gate7DeterministicGateSuite.evaluate(samples: samples, request: request)

        XCTAssertEqual(result.status, .blocked)
        XCTAssertTrue(result.reasons.contains("diversity_distinct_rate_below_floor"))
        XCTAssertTrue(result.reasons.contains { $0.hasPrefix("dedupe_duplicate_count_") })
        XCTAssertTrue(result.reasons.contains { $0.hasPrefix("redaction_blocked:") })
        XCTAssertTrue(result.reasons.contains("decontamination_blocked"))
        XCTAssertEqual(result.dataGateReceipt?.status, "blocked")
        XCTAssertTrue(result.dataGateReceipt?.failureReceipt.contains { $0.reason == "train_device_overlap" } == true)
    }

    func testQuotaAndPrecisionSkeletonsAreDeterministic() {
        let allocations = Gate7QuotaCalculator.allocate([
            Gate7QuotaInput(
                familyID: "wiper",
                intentBaseline: 3,
                bugPressure: 2,
                demoFloor: 4,
                safetyFloor: 6,
                sparseFamilyFloor: 12
            ),
            Gate7QuotaInput(
                familyID: "ac",
                intentBaseline: 30,
                bugPressure: 5,
                demoFloor: 10,
                safetyFloor: 10
            )
        ])

        XCTAssertEqual(allocations.first { $0.familyID == "wiper" }?.quota, 12)
        XCTAssertEqual(allocations.first { $0.familyID == "ac" }?.quota, 35)
        XCTAssertEqual(Gate7PrecisionGate.humanReviewSampleSize(candidateCount: 3), 20)
        XCTAssertEqual(Gate7PrecisionGate.humanReviewSampleSize(candidateCount: 600), 50)
        XCTAssertFalse(Gate7PrecisionGate.shouldStopFamily(reviewed: 10, accepted: 8))
        XCTAssertTrue(Gate7PrecisionGate.shouldStopFamily(reviewed: 10, accepted: 7))
    }

    private func loadManifest() throws -> Gate7SubsetManifest {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("generated/subset-policy-manifest.json")
        return try JSONDecoder().decode(Gate7SubsetManifest.self, from: Data(contentsOf: url))
    }

    private func makeRequest(manifest: Gate7SubsetManifest) throws -> Gate7PipelineRequest {
        let entry = try XCTUnwrap(manifest.entries.first { $0.groupID == "ac" })
        let target = try XCTUnwrap(entry.toolIDsOrdered.first)
        return Gate7PipelineRequest(
            manifestMeta: manifest.meta,
            manifestEntry: entry,
            prompt: "construction-only stub prompt",
            targetToolName: target,
            device: "ac",
            valueType: "EXP",
            templateFamily: "gate7_fixture",
            parentSemanticIDPrefix: "gate7.ac"
        )
    }

    private func diverseUtterances() -> [String] {
        [
            "开空调",
            "帮我把空调打开",
            "我有点热，麻烦打开车里空调"
        ]
    }

    private func sampleMetadata(
        manifest: Gate7SubsetManifest,
        entry: Gate7SubsetManifest.Entry
    ) throws -> Gate7SampleMetadata {
        Gate7SampleMetadata(
            subsetPolicyID: entry.subsetPolicyID,
            subsetPolicyDigest: manifest.meta.groupingContractDigest,
            groupID: entry.groupID,
            mountMode: entry.mountMode,
            mountedToolCount: entry.toolIDsOrdered.count,
            tokenCount: entry.toolTokens,
            generatorVendor: .openai,
            judgeVendor: .anthropic,
            subsetContext: try entry.subsetContext()
        )
    }

    private struct SlowGate7Provider: Gate7LLMProvider {
        var vendor: Gate7Vendor
        var response: Gate7ProviderResponse
        var delaySeconds: TimeInterval
        var isStubbed: Bool { true }

        func complete(_ request: Gate7ProviderRequest) -> Gate7ProviderResponse {
            Thread.sleep(forTimeInterval: delaySeconds)
            return response
        }
    }
}
