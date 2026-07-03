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
        XCTAssertEqual(sample.tools.count, request.manifestEntry.toolIDsOrdered.count)
        XCTAssertEqual(toolNames(sample.tools), request.manifestEntry.toolIDsOrdered)
        XCTAssertEqual(receipt.dataGateReceipt?.status, "data_gate_ready")
    }

    func testGate7SurfaceFieldsSurviveGeneratedSampleProjectionAndCandidateJSONRoundTrip() throws {
        let manifest = try loadManifest()
        let seed = try loadSeed(contractRowID: "c1_airControl_000167")
        let entry = try loadCatalogEntry(named: seed.intent)
        let request = try makeRequest(
            manifest: manifest,
            seed: seed,
            toolEntry: entry,
            valueType: "SPOT",
            templateFamily: "gate7_surface_projection"
        )
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
        let sample = try XCTUnwrap(receipt.samples.first)
        let candidate = try XCTUnwrap(Gate7DecontaminationGate.candidates(samples: receipt.samples, request: request).first)

        XCTAssertEqual(receipt.status, .pass)
        XCTAssertEqual(sample.tools, request.mountedTools)
        XCTAssertEqual(candidate.tools, sample.tools)
        XCTAssertEqual(candidate.mountedToolCount, request.manifestEntry.toolIDsOrdered.count)
        XCTAssertEqual(candidate.subsetPolicyID, request.manifestEntry.subsetPolicyID)
        XCTAssertEqual(candidate.subsetGroupID, request.manifestEntry.groupID)
        XCTAssertEqual(candidate.subsetPolicyDigest, manifest.meta.groupingContractDigest)
        XCTAssertTrue(toolNames(candidate.tools).contains(entry.function.name))
        XCTAssertEqual(candidate.promptHash, C5DerivedHashRecipe.promptHash(utterance: sample.utterance))
        let renderedToolCall = try XCTUnwrap(candidate.renderedToolCall)
        XCTAssertEqual(candidate.expectedToolCallSignature, C5DerivedHashRecipe.expectedToolCallSignature(renderedToolCall: renderedToolCall))
        XCTAssertEqual(candidate.hashRecipeRef, C5DerivedHashRecipe.hashRecipeRef)
        XCTAssertEqual(candidate.hashRecomputedByPipeline, true)

        let roundTrip = try JSONDecoder().decode(C5DataGateCandidate.self, from: JSONEncoder().encode(candidate))
        XCTAssertEqual(roundTrip.tools, candidate.tools)
        XCTAssertEqual(roundTrip.mountedToolCount, candidate.mountedToolCount)
        XCTAssertEqual(roundTrip.subsetPolicyID, candidate.subsetPolicyID)
        XCTAssertEqual(roundTrip.subsetGroupID, candidate.subsetGroupID)
        XCTAssertEqual(roundTrip.subsetPolicyDigest, candidate.subsetPolicyDigest)
        XCTAssertEqual(roundTrip.promptHash, candidate.promptHash)
        XCTAssertEqual(roundTrip.expectedToolCallSignature, candidate.expectedToolCallSignature)
        XCTAssertEqual(roundTrip.hashRecipeRef, candidate.hashRecipeRef)
        XCTAssertEqual(roundTrip.hashRecomputedByPipeline, candidate.hashRecomputedByPipeline)
    }

    func testWave1WarmupBatchManifestBuilderUsesLockedQuotaAndRefusalZero() {
        let manifest = Wave1BatchManifestBuilder.warmup(
            batchID: "wave1-warmup-0001",
            mainPinSHA: Wave1BatchManifestBuilder.defaultMainPinSHA,
            laneID: "lane-a"
        )
        let receipt = Wave1BatchManifestBuilder.validateDryRun(manifest)

        XCTAssertEqual(manifest.manifestVersion, "wave1-batch-manifest.v1")
        XCTAssertEqual(manifest.contractStatus, "rev2.1_locked_aligned")
        XCTAssertEqual(manifest.batchType, "standard_generation")
        XCTAssertEqual(manifest.targetCount, 50)
        XCTAssertTrue(manifest.warmupPhase)
        XCTAssertEqual(manifest.mainPinSHA, "b33d8eba152e5326f69bbe85fc356b73419ee9c3")
        XCTAssertEqual(manifest.quotaConfigSource, "Gate7RecipeQuotaConfig.wave1ConstructionAnchors")
        XCTAssertEqual(manifest.quotaConfig, .wave1ConstructionAnchors)
        XCTAssertFalse(manifest.quotaManualOverride)
        XCTAssertEqual(manifest.refusalRatioTarget, 0)
        XCTAssertEqual(manifest.refusalRatioHardCap, 0)
        XCTAssertTrue(manifest.allowedStates.contains("paused_diversity"))
        XCTAssertEqual(manifest.recoveryBatchTypes, ["recovery_projection", "recovery_rejudge_datagate"])
        XCTAssertEqual(manifest.quotaAllocation.quotaSource, Gate7RecipeQuotaConfig.wave1ConstructionAnchors.quotaSource)
        XCTAssertEqual(manifest.quotaAllocation.quota, 50)
        XCTAssertEqual(receipt.status, "pass")
        XCTAssertTrue(receipt.failureReasons.isEmpty)
    }

    func testDeterministicLabelerBridgesC1SlotsAndValuesIntoDdomainArguments() throws {
        let manifest = try loadManifest()
        let seed = try loadSeed(contractRowID: "c1_airControl_000167")
        let entry = try loadCatalogEntry(named: seed.intent)
        let request = try makeRequest(
            manifest: manifest,
            seed: seed,
            toolEntry: entry,
            valueType: "SPOT",
            templateFamily: "gate7_c1_bridge"
        )
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
        let firstCall = try XCTUnwrap(receipt.samples.first?.expectedToolCalls.first)
        XCTAssertEqual(firstCall.name, "adjust_ac_temperature_to_number")
        XCTAssertEqual(firstCall.arguments["adjustment_mode"], "摄氏度")
        XCTAssertEqual(firstCall.arguments["direction"], "主驾")
        XCTAssertEqual(firstCall.arguments["mode"], "制冷")
        XCTAssertEqual(firstCall.arguments["temperature"], "22")
        XCTAssertEqual(receipt.dataGateReceipt?.status, "data_gate_ready")
    }

    func testC1BridgeHandlesModeValueAndExpValueSlots() throws {
        let modeSeed = try loadSeed(contractRowID: "c1_airControl_000021")
        let modeEntry = try loadCatalogEntry(named: modeSeed.intent)
        let modeArguments = Gate7C1ToolCallBridge.arguments(seed: modeSeed, toolEntry: modeEntry, variant: 0)

        XCTAssertEqual(modeArguments["direction"], "主驾")
        XCTAssertEqual(modeArguments["modeValue"], "快速")

        let windowSeed = try loadSeed(contractRowID: "c1_carControl_000027")
        let windowEntry = try loadCatalogEntry(named: windowSeed.intent)
        let windowArguments = Gate7C1ToolCallBridge.arguments(seed: windowSeed, toolEntry: windowEntry, variant: 0)

        XCTAssertEqual(windowArguments["position"], "主驾")
        XCTAssertEqual(windowArguments["value"], "LITTLE")
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

    func testQuotaAndPrecisionSkeletonsAreDeterministic() throws {
        let allocations = Gate7QuotaCalculator.allocate([
            Gate7QuotaInput(
                familyID: "wiper",
                intentBaseline: 3,
                bugPressure: 2,
                demoFloor: 4,
                safetyFloor: 6,
                sparseFamilyFloor: 12,
                recipeQuota: .wave1ConstructionAnchors
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
        let wiper = try XCTUnwrap(allocations.first { $0.familyID == "wiper" })
        XCTAssertEqual(wiper.quotaSource, "intent_bug_scene_recovery")
        XCTAssertEqual(wiper.negativeQuotaActivation, "deferred_refusal_ratio_zero_conflict")
        XCTAssertEqual(wiper.components["open_close_polarity_floor"], 2)
        XCTAssertEqual(wiper.components["active_negative_quota"], 0)
        XCTAssertEqual(wiper.components["multi_call_pairing_minimum"], 2)
        XCTAssertEqual(Gate7PrecisionGate.humanReviewSampleSize(candidateCount: 3), 20)
        XCTAssertEqual(Gate7PrecisionGate.humanReviewSampleSize(candidateCount: 600), 50)
        XCTAssertFalse(Gate7PrecisionGate.shouldStopFamily(reviewed: 10, accepted: 8))
        XCTAssertTrue(Gate7PrecisionGate.shouldStopFamily(reviewed: 10, accepted: 7))
    }

    func testRecipeQuotaMismatchBlocksDryRunStatus() {
        let pass = Gate7QuotaEnforcer.enforce(
            status: .pass,
            reasons: [],
            allocatedQuota: 2,
            actualGeneratedCount: 2
        )
        XCTAssertEqual(pass.status, .pass)
        XCTAssertTrue(pass.reasons.isEmpty)

        let mismatch = Gate7QuotaEnforcer.enforce(
            status: .pass,
            reasons: ["diversity_length_distribution_too_narrow"],
            allocatedQuota: 2,
            actualGeneratedCount: 1
        )
        XCTAssertEqual(mismatch.status, .blocked)
        XCTAssertTrue(mismatch.reasons.contains("quota_mismatch"))
        XCTAssertTrue(mismatch.reasons.contains("diversity_length_distribution_too_narrow"))
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
            mountedTools: try mountedToolSchemas(entry: entry),
            device: "ac",
            valueType: "EXP",
            templateFamily: "gate7_fixture",
            parentSemanticIDPrefix: "gate7.ac"
        )
    }

    private func makeRequest(
        manifest: Gate7SubsetManifest,
        seed: C5SemanticSeed,
        toolEntry: DDomainToolEntry,
        valueType: String,
        templateFamily: String
    ) throws -> Gate7PipelineRequest {
        let manifestEntry = try XCTUnwrap(manifest.entries.first { $0.toolIDsOrdered.contains(toolEntry.function.name) })
        return Gate7PipelineRequest(
            manifestMeta: manifest.meta,
            manifestEntry: manifestEntry,
            prompt: "construction-only C1 bridge prompt",
            targetToolName: toolEntry.function.name,
            targetSemanticSeed: seed,
            targetToolEntry: toolEntry,
            mountedTools: try mountedToolSchemas(entry: manifestEntry),
            device: seed.device,
            valueType: valueType,
            templateFamily: templateFamily,
            parentSemanticIDPrefix: "gate7.\(seed.device)"
        )
    }

    private func loadSeed(contractRowID: String) throws -> C5SemanticSeed {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("contracts/semantic-function-contract.jsonl")
        let decoder = JSONDecoder()
        for line in try String(contentsOf: url, encoding: .utf8).split(whereSeparator: \.isNewline) {
            let seed = try decoder.decode(C5SemanticSeed.self, from: Data(String(line).utf8))
            if seed.contractRowID == contractRowID {
                return seed
            }
        }
        throw XCTSkip("missing C1 seed \(contractRowID)")
    }

    private func loadCatalogEntry(named name: String) throws -> DDomainToolEntry {
        let entries = try loadCatalog()
        return try XCTUnwrap(entries.first { $0.function.name == name })
    }

    private func loadCatalog() throws -> [DDomainToolEntry] {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("generated/D_domain.tools.demo.json")
        return try JSONDecoder().decode([DDomainToolEntry].self, from: Data(contentsOf: url))
    }

    private func mountedToolSchemas(entry: Gate7SubsetManifest.Entry) throws -> [[String: JSONValue]] {
        let catalog = try loadCatalog()
        let catalogByName = Dictionary(catalog.map { ($0.function.name, $0) }, uniquingKeysWith: { first, _ in first })
        return try entry.toolIDsOrdered.map { toolID in
            let entry = try XCTUnwrap(catalogByName[toolID], "missing mounted tool \(toolID)")
            return C5TrainingRenderer.dDomainToolSchema(entry)
        }
    }

    private func toolNames(_ tools: [[String: JSONValue]]) -> [String] {
        tools.compactMap { tool in
            guard case let .object(function)? = tool["function"],
                  case let .string(name)? = function["name"] else {
                return nil
            }
            return name
        }
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
