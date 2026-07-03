import Foundation

public enum Gate7Vendor: String, Codable, CaseIterable, Equatable, Sendable {
    case anthropic
    case openai
    case volcTwofish = "volc_twofish"
}

public enum Gate7PipelineStatus: String, Codable, Equatable, Sendable {
    case pass = "PASS"
    case blockedR7 = "blocked_r7"
    case blocked = "blocked"
    case timeout = "timeout"
    case parseError = "parse_error"
    case retryExhausted = "retry_exhausted"
}

public enum Gate7GenerationStage: String, Codable, Equatable, Sendable {
    case generator
    case label
    case judge
    case diversity
    case dedupe
    case decontamination
    case redaction
}

public struct Gate7ProviderRequest: Equatable, Sendable {
    public var stage: Gate7GenerationStage
    public var groupID: String
    public var prompt: String

    public init(stage: Gate7GenerationStage, groupID: String, prompt: String) {
        self.stage = stage
        self.groupID = groupID
        self.prompt = prompt
    }
}

public struct Gate7ProviderResponse: Equatable, Sendable {
    public var status: Gate7PipelineStatus
    public var utterances: [String]
    public var errorCode: String?
    public var rawPayload: String?

    public init(
        status: Gate7PipelineStatus,
        utterances: [String] = [],
        errorCode: String? = nil,
        rawPayload: String? = nil
    ) {
        self.status = status
        self.utterances = utterances
        self.errorCode = errorCode
        self.rawPayload = rawPayload
    }
}

public protocol Gate7LLMProvider: Sendable {
    var vendor: Gate7Vendor { get }
    var isStubbed: Bool { get }
    func complete(_ request: Gate7ProviderRequest) -> Gate7ProviderResponse
}

public struct Gate7MockLLMProvider: Gate7LLMProvider {
    public var vendor: Gate7Vendor
    public var responsesByStage: [Gate7GenerationStage: Gate7ProviderResponse]

    public var isStubbed: Bool { true }

    public init(vendor: Gate7Vendor, responsesByStage: [Gate7GenerationStage: Gate7ProviderResponse]) {
        self.vendor = vendor
        self.responsesByStage = responsesByStage
    }

    public func complete(_ request: Gate7ProviderRequest) -> Gate7ProviderResponse {
        responsesByStage[request.stage] ?? Gate7ProviderResponse(status: .pass)
    }
}

public struct Gate7BlockedLiveLLMProvider: Gate7LLMProvider {
    public var vendor: Gate7Vendor
    public var isStubbed: Bool { false }

    public init(vendor: Gate7Vendor) {
        self.vendor = vendor
    }

    public func complete(_ request: Gate7ProviderRequest) -> Gate7ProviderResponse {
        Gate7ProviderResponse(
            status: .blockedR7,
            errorCode: "blocked_r7_live_provider_path",
            rawPayload: request.prompt
        )
    }
}

public struct Gate7ExecutionContract: Equatable, Sendable {
    public var maxAttempts: Int
    public var timeoutMilliseconds: Int

    public init(maxAttempts: Int = 2, timeoutMilliseconds: Int = 30_000) {
        self.maxAttempts = max(1, maxAttempts)
        self.timeoutMilliseconds = max(1, timeoutMilliseconds)
    }
}

public struct Gate7AttemptReceipt: Codable, Equatable, Sendable {
    public var stage: String
    public var vendor: String
    public var attempt: Int
    public var status: String
    public var errorCode: String?
    public var timeoutPolicyMilliseconds: Int
    public var elapsedMilliseconds: Int
    public var timedOut: Bool
    public var rawPayloadSHA256: String?
    public var rawPayloadBytes: Int?

    enum CodingKeys: String, CodingKey {
        case stage
        case vendor
        case attempt
        case status
        case errorCode = "error_code"
        case timeoutPolicyMilliseconds = "timeout_policy_ms"
        case elapsedMilliseconds = "elapsed_ms"
        case timedOut = "timed_out"
        case rawPayloadSHA256 = "raw_payload_sha256"
        case rawPayloadBytes = "raw_payload_bytes"
    }
}

public struct Gate7SubsetManifest: Decodable, Equatable, Sendable {
    public var meta: Meta
    public var entries: [Entry]

    public struct Meta: Decodable, Equatable, Sendable {
        public var subsetPolicyID: String
        public var groupingContractDigest: String
        public var toolCount: Int
        public var entryCounts: [String: Int]

        enum CodingKeys: String, CodingKey {
            case subsetPolicyID = "subset_policy_id"
            case groupingContractDigest = "grouping_contract_digest"
            case toolCount = "tool_count"
            case entryCounts = "entry_counts"
        }
    }

    public struct Entry: Decodable, Equatable, Sendable {
        public var subsetPolicyID: String
        public var groupID: String
        public var mountMode: String
        public var toolIDsOrdered: [String]
        public var toolTokens: Int
        public var toolTokensCap: Int
        public var budgetStatus: String
        public var grammarArtifactDigest: String
        public var toolSchemaDigest: String

        enum CodingKeys: String, CodingKey {
            case subsetPolicyID = "subset_policy_id"
            case groupID = "group_id"
            case mountMode = "mount_mode"
            case toolIDsOrdered = "tool_ids_ordered"
            case toolTokens = "tool_tokens"
            case toolTokensCap = "tool_tokens_cap"
            case budgetStatus = "budget_status"
            case grammarArtifactDigest = "grammar_artifact_digest"
            case toolSchemaDigest = "tool_schema_digest"
        }

        public func subsetContext() throws -> C6SubsetContext {
            C6SubsetContext(
                subsetPolicyID: subsetPolicyID,
                subsetGroupID: groupID,
                mountMode: mountMode,
                mountedToolIDsDigest: try C6SubsetDigestReceiptWriter.digest(toolIDsOrdered),
                grammarToolsDigest: grammarArtifactDigest
            )
        }
    }
}

public struct Gate7SampleMetadata: Codable, Equatable, Sendable {
    public var subsetPolicyID: String
    public var subsetPolicyDigest: String
    public var groupID: String
    public var mountMode: String
    public var mountedToolCount: Int
    public var tokenCount: Int
    public var generatorVendor: Gate7Vendor
    public var judgeVendor: Gate7Vendor
    public var subsetContext: C6SubsetContext

    enum CodingKeys: String, CodingKey {
        case subsetPolicyID = "subset_policy_id"
        case subsetPolicyDigest = "subset_policy_digest"
        case groupID = "group_id"
        case mountMode = "mount_mode"
        case mountedToolCount = "mounted_tool_count"
        case tokenCount = "token_count"
        case generatorVendor = "generator_vendor"
        case judgeVendor = "judge_vendor"
        case subsetContext = "subset_context"
    }
}

public struct Gate7GeneratedSample: Equatable, Sendable {
    public var sampleID: String
    public var utterance: String
    public var tools: [[String: JSONValue]]
    public var expectedToolCalls: [C6ToolCall]
    public var metadata: Gate7SampleMetadata

    public init(
        sampleID: String,
        utterance: String,
        tools: [[String: JSONValue]] = [],
        expectedToolCalls: [C6ToolCall],
        metadata: Gate7SampleMetadata
    ) {
        self.sampleID = sampleID
        self.utterance = utterance
        self.tools = tools
        self.expectedToolCalls = expectedToolCalls
        self.metadata = metadata
    }
}

public struct Gate7PipelineRequest: Sendable {
    public var manifestMeta: Gate7SubsetManifest.Meta
    public var manifestEntry: Gate7SubsetManifest.Entry
    public var prompt: String
    public var targetToolName: String
    public var targetSemanticSeed: C5SemanticSeed?
    public var targetToolEntry: DDomainToolEntry?
    public var mountedTools: [[String: JSONValue]]
    public var variantOffset: Int
    public var device: String
    public var valueType: String
    public var templateFamily: String
    public var parentSemanticIDPrefix: String
    public var heldOutCandidates: [C5DataGateCandidate]

    public init(
        manifestMeta: Gate7SubsetManifest.Meta,
        manifestEntry: Gate7SubsetManifest.Entry,
        prompt: String,
        targetToolName: String,
        targetSemanticSeed: C5SemanticSeed? = nil,
        targetToolEntry: DDomainToolEntry? = nil,
        mountedTools: [[String: JSONValue]] = [],
        variantOffset: Int = 0,
        device: String,
        valueType: String,
        templateFamily: String,
        parentSemanticIDPrefix: String,
        heldOutCandidates: [C5DataGateCandidate] = []
    ) {
        self.manifestMeta = manifestMeta
        self.manifestEntry = manifestEntry
        self.prompt = prompt
        self.targetToolName = targetToolName
        self.targetSemanticSeed = targetSemanticSeed
        self.targetToolEntry = targetToolEntry
        self.mountedTools = mountedTools
        self.variantOffset = variantOffset
        self.device = device
        self.valueType = valueType
        self.templateFamily = templateFamily
        self.parentSemanticIDPrefix = parentSemanticIDPrefix
        self.heldOutCandidates = heldOutCandidates
    }
}

public struct Gate7PipelineReceipt: Equatable, Sendable {
    public var status: Gate7PipelineStatus
    public var reasons: [String]
    public var attempts: [Gate7AttemptReceipt]
    public var samples: [Gate7GeneratedSample]
    public var dataGateReceipt: C5DataGateReceipt?

    public init(
        status: Gate7PipelineStatus,
        reasons: [String],
        attempts: [Gate7AttemptReceipt] = [],
        samples: [Gate7GeneratedSample] = [],
        dataGateReceipt: C5DataGateReceipt? = nil
    ) {
        self.status = status
        self.reasons = reasons
        self.attempts = attempts
        self.samples = samples
        self.dataGateReceipt = dataGateReceipt
    }
}

public struct Gate7GeneratorPipeline: Sendable {
    public var generator: Gate7LLMProvider
    public var judge: Gate7LLMProvider
    public var executionContract: Gate7ExecutionContract

    public init(
        generator: Gate7LLMProvider,
        judge: Gate7LLMProvider,
        executionContract: Gate7ExecutionContract = Gate7ExecutionContract()
    ) {
        self.generator = generator
        self.judge = judge
        self.executionContract = executionContract
    }

    public func run(_ request: Gate7PipelineRequest) throws -> Gate7PipelineReceipt {
        if generator.vendor == judge.vendor {
            return Gate7PipelineReceipt(
                status: .blocked,
                reasons: ["same_vendor_generator_judge"]
            )
        }
        if !generator.isStubbed || !judge.isStubbed {
            return Gate7PipelineReceipt(
                status: .blockedR7,
                reasons: ["blocked_r7_live_llm_provider_path"]
            )
        }

        let generated = runStage(.generator, provider: generator, request: request)
        guard generated.response.status == .pass else {
            return Gate7PipelineReceipt(
                status: generated.terminalStatus,
                reasons: [generated.response.errorCode ?? generated.response.status.rawValue],
                attempts: generated.attempts
            )
        }

        let samples = try Gate7DeterministicLabeler.samples(
            utterances: generated.response.utterances,
            request: request,
            generatorVendor: generator.vendor,
            judgeVendor: judge.vendor
        )

        let judgeResult = runStage(.judge, provider: judge, request: request)
        guard judgeResult.response.status == .pass else {
            return Gate7PipelineReceipt(
                status: judgeResult.terminalStatus,
                reasons: [judgeResult.response.errorCode ?? judgeResult.response.status.rawValue],
                attempts: generated.attempts + judgeResult.attempts,
                samples: samples
            )
        }

        let deterministic = Gate7DeterministicGateSuite.evaluate(samples: samples, request: request)
        let attempts = generated.attempts + judgeResult.attempts
        guard deterministic.status == .pass else {
            return Gate7PipelineReceipt(
                status: deterministic.status,
                reasons: deterministic.reasons,
                attempts: attempts,
                samples: samples,
                dataGateReceipt: deterministic.dataGateReceipt
            )
        }

        return Gate7PipelineReceipt(
            status: .pass,
            reasons: [],
            attempts: attempts,
            samples: samples,
            dataGateReceipt: deterministic.dataGateReceipt
        )
    }

    private func runStage(
        _ stage: Gate7GenerationStage,
        provider: Gate7LLMProvider,
        request: Gate7PipelineRequest
    ) -> (response: Gate7ProviderResponse, attempts: [Gate7AttemptReceipt], terminalStatus: Gate7PipelineStatus) {
        var attempts: [Gate7AttemptReceipt] = []
        var last = Gate7ProviderResponse(status: .retryExhausted, errorCode: "retry_exhausted")
        for index in 1...executionContract.maxAttempts {
            let startedAt = Date()
            let response = provider.complete(Gate7ProviderRequest(stage: stage, groupID: request.manifestEntry.groupID, prompt: request.prompt))
            let elapsedMilliseconds = max(0, Int(Date().timeIntervalSince(startedAt) * 1000))
            let didTimeout = elapsedMilliseconds > executionContract.timeoutMilliseconds || response.status == .timeout
            last = didTimeout
                ? Gate7ProviderResponse(
                    status: .timeout,
                    utterances: response.utterances,
                    errorCode: response.errorCode ?? "timeout_exceeded",
                    rawPayload: response.rawPayload
                )
                : response
            attempts.append(Gate7AttemptReceipt(
                stage: stage.rawValue,
                vendor: provider.vendor.rawValue,
                attempt: index,
                status: last.status.rawValue,
                errorCode: last.errorCode,
                timeoutPolicyMilliseconds: executionContract.timeoutMilliseconds,
                elapsedMilliseconds: elapsedMilliseconds,
                timedOut: didTimeout,
                rawPayloadSHA256: last.rawPayload.map { C6Hash.sha256Hex(Data($0.utf8)) },
                rawPayloadBytes: last.rawPayload.map { Data($0.utf8).count }
            ))
            if last.status == .pass || last.status == .blockedR7 {
                return (last, attempts, last.status)
            }
            if last.status == .parseError || last.status == .timeout {
                continue
            }
            return (last, attempts, last.status)
        }
        return (last, attempts, last.status == .pass ? .pass : .retryExhausted)
    }
}

public enum Gate7C1ToolCallBridge {
    public static func arguments(
        seed: C5SemanticSeed,
        toolEntry: DDomainToolEntry,
        variant: Int,
        scopeCandidatesBySlot: [String: [String]] = [:],
        scopeCandidatesByDeviceSlot: [String: [String: [String]]] = [:]
    ) -> [String: String] {
        let valueAugmentation = C5TrainingRenderer.augmentValue(seed: seed, variant: variant)
        let slotAssignments = C5TrainingRenderer.slotAssignments(
            seed: seed,
            variant: variant,
            value: valueAugmentation.value,
            scopeCandidatesBySlot: scopeCandidatesBySlot,
            scopeCandidatesByDeviceSlot: scopeCandidatesByDeviceSlot
        )
        let jsonArguments = C5TrainingRenderer.dDomainToolCallArguments(
            seed: seed,
            value: valueAugmentation.value,
            slotAssignments: slotAssignments,
            toolEntry: toolEntry,
            variant: variant
        )
        return jsonArguments.compactMapValues(\.gate7ToolArgumentString)
    }

    public static func toolCall(
        seed: C5SemanticSeed,
        toolEntry: DDomainToolEntry,
        variant: Int
    ) -> C6ToolCall {
        C6ToolCall(
            name: toolEntry.function.name,
            arguments: arguments(seed: seed, toolEntry: toolEntry, variant: variant)
        )
    }
}

public enum Gate7DeterministicLabeler {
    public static func samples(
        utterances: [String],
        request: Gate7PipelineRequest,
        generatorVendor: Gate7Vendor,
        judgeVendor: Gate7Vendor
    ) throws -> [Gate7GeneratedSample] {
        let subsetContext = try request.manifestEntry.subsetContext()
        let metadata = Gate7SampleMetadata(
            subsetPolicyID: request.manifestEntry.subsetPolicyID,
            subsetPolicyDigest: request.manifestMeta.groupingContractDigest,
            groupID: request.manifestEntry.groupID,
            mountMode: request.manifestEntry.mountMode,
            mountedToolCount: request.manifestEntry.toolIDsOrdered.count,
            tokenCount: request.manifestEntry.toolTokens,
            generatorVendor: generatorVendor,
            judgeVendor: judgeVendor,
            subsetContext: subsetContext
        )
        return utterances.enumerated().map { offset, utterance in
            let expectedToolCall = expectedToolCall(request: request, variant: request.variantOffset + offset)
            return Gate7GeneratedSample(
                sampleID: "G7C-\(request.manifestEntry.groupID)-\(offset + 1)",
                utterance: utterance,
                tools: request.mountedTools,
                expectedToolCalls: [expectedToolCall],
                metadata: metadata
            )
        }
    }

    private static func expectedToolCall(request: Gate7PipelineRequest, variant: Int) -> C6ToolCall {
        guard let seed = request.targetSemanticSeed,
              let toolEntry = request.targetToolEntry else {
            return C6ToolCall(name: request.targetToolName, arguments: [:])
        }
        return Gate7C1ToolCallBridge.toolCall(seed: seed, toolEntry: toolEntry, variant: variant)
    }
}

private extension JSONValue {
    var gate7ToolArgumentString: String? {
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            if value.rounded() == value {
                return String(Int(value))
            }
            return String(value)
        case .bool(let value):
            return value ? "true" : "false"
        case .object, .array, .null:
            return nil
        }
    }
}

public struct Gate7DiversityConfig: Equatable, Sendable {
    public var minimumDistinctRate: Double
    public var minimumLengthBucketCount: Int

    public init(minimumDistinctRate: Double = 0.67, minimumLengthBucketCount: Int = 2) {
        self.minimumDistinctRate = minimumDistinctRate
        self.minimumLengthBucketCount = minimumLengthBucketCount
    }
}

public struct Gate7DiversityResult: Equatable, Sendable {
    public var passed: Bool
    public var distinctRate: Double
    public var lengthBuckets: Set<String>
    public var reasons: [String]
}

public enum Gate7DiversityGate {
    public static func evaluate(utterances: [String], config: Gate7DiversityConfig = Gate7DiversityConfig()) -> Gate7DiversityResult {
        guard !utterances.isEmpty else {
            return Gate7DiversityResult(passed: false, distinctRate: 0, lengthBuckets: [], reasons: ["empty_generation_batch"])
        }
        let normalized = utterances.map { normalize($0) }
        let distinctRate = Double(Set(normalized).count) / Double(normalized.count)
        let buckets = Set(normalized.map(lengthBucket(_:)))
        var reasons: [String] = []
        if distinctRate < config.minimumDistinctRate {
            reasons.append("diversity_distinct_rate_below_floor")
        }
        if buckets.count < config.minimumLengthBucketCount {
            reasons.append("diversity_length_distribution_too_narrow")
        }
        return Gate7DiversityResult(
            passed: reasons.isEmpty,
            distinctRate: distinctRate,
            lengthBuckets: buckets,
            reasons: reasons
        )
    }

    private static func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func lengthBucket(_ value: String) -> String {
        if value.count <= 6 {
            return "short"
        }
        if value.count <= 14 {
            return "medium"
        }
        return "long"
    }
}

public struct Gate7DedupeResult: Equatable, Sendable {
    public var passed: Bool
    public var duplicateCount: Int
}

public enum Gate7DedupeGate {
    public static func evaluate(utterances: [String]) -> Gate7DedupeResult {
        var seen = Set<String>()
        var duplicates = 0
        for utterance in utterances.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }) {
            if !seen.insert(utterance).inserted {
                duplicates += 1
            }
        }
        return Gate7DedupeResult(passed: duplicates == 0, duplicateCount: duplicates)
    }
}

public struct Gate7RedactionResult: Equatable, Sendable {
    public var passed: Bool
    public var blockedTokens: [String]
}

public enum Gate7RedactionGate {
    public static let prohibitedTokens = ["AH8", "T19", "E0Y", "iFlytek", "Chery", "禁止外传", "对内"]

    public static func evaluate(utterances: [String]) -> Gate7RedactionResult {
        let joined = utterances.joined(separator: "\n")
        var blocked = prohibitedTokens.filter {
            joined.range(of: $0, options: [.caseInsensitive, .widthInsensitive]) != nil
        }
        if joined.range(of: #"\b1[3-9]\d{9}\b"#, options: .regularExpression) != nil {
            blocked.append("phone_like_pii")
        }
        return Gate7RedactionResult(passed: blocked.isEmpty, blockedTokens: blocked.sorted())
    }
}

public enum Gate7DecontaminationGate {
    public static func candidates(
        samples: [Gate7GeneratedSample],
        request: Gate7PipelineRequest
    ) -> [C5DataGateCandidate] {
        samples.enumerated().map { offset, sample in
            let renderedToolCall = sample.expectedToolCalls.first.map(Self.renderedToolCall)
            return C5DataGateCandidate(
                sampleID: sample.sampleID,
                split: "train",
                bucket: "gate7_candidate",
                caseID: sample.sampleID,
                parentSemanticID: "\(request.parentSemanticIDPrefix).\(offset + 1)",
                candidateParentSemanticID: nil,
                device: request.device,
                toolName: sample.expectedToolCalls.first?.name,
                valueType: request.valueType,
                templateFamily: request.templateFamily,
                generatorSource: sample.metadata.generatorVendor.rawValue,
                generatorModelID: nil,
                generatorSourceVendor: sample.metadata.generatorVendor.rawValue,
                mustNotTrain: false,
                sourceAuthorization: "authorized_fixture",
                inputText: sample.utterance,
                assistantText: renderedToolCall ?? "\n\nNO_TOOL",
                hasActionToolCall: renderedToolCall != nil,
                hasSharedWrapper: renderedToolCall != nil,
                masking: C5MaskingFlags(functionName: true, argumentName: true, argumentValue: true, trainOnTurn: true),
                tools: sample.tools,
                mountedToolCount: sample.metadata.mountedToolCount,
                subsetPolicyID: sample.metadata.subsetPolicyID,
                subsetGroupID: sample.metadata.groupID,
                subsetPolicyDigest: sample.metadata.subsetPolicyDigest,
                promptHash: C5DerivedHashRecipe.promptHash(utterance: sample.utterance),
                expectedToolCallSignature: renderedToolCall.map(C5DerivedHashRecipe.expectedToolCallSignature(renderedToolCall:)),
                hashRecipeRef: C5DerivedHashRecipe.hashRecipeRef,
                hashRecomputedByPipeline: true,
                renderedToolCall: renderedToolCall
            )
        }
    }

    private static func renderedToolCall(_ call: C6ToolCall) -> String {
        C5DerivedHashRecipe.renderToolCall(
            name: call.name,
            arguments: call.arguments.mapValues { .string($0) }
        )
    }

    public static func evaluate(
        samples: [Gate7GeneratedSample],
        request: Gate7PipelineRequest
    ) -> C5DataGateReceipt {
        let train = candidates(samples: samples, request: request)
        let context = C5DataGateRunContext(
            sourceSnapshotDigest: request.manifestMeta.groupingContractDigest,
            sourceAuthorizationStatus: "authorized_fixture",
            formatContractVersion: request.manifestEntry.grammarArtifactDigest,
            generatedAt: "construction_only"
        )
        return C5DataGateValidator().receipt(
            candidates: train + request.heldOutCandidates,
            c6Cases: [],
            context: context
        )
    }
}

public struct Gate7DeterministicGateResult: Equatable, Sendable {
    public var status: Gate7PipelineStatus
    public var reasons: [String]
    public var dataGateReceipt: C5DataGateReceipt?
}

public enum Gate7DeterministicGateSuite {
    public static func evaluate(
        samples: [Gate7GeneratedSample],
        request: Gate7PipelineRequest
    ) -> Gate7DeterministicGateResult {
        let utterances = samples.map(\.utterance)
        let diversity = Gate7DiversityGate.evaluate(utterances: utterances)
        let dedupe = Gate7DedupeGate.evaluate(utterances: utterances)
        let redaction = Gate7RedactionGate.evaluate(utterances: utterances)
        let dataGate = Gate7DecontaminationGate.evaluate(samples: samples, request: request)
        var reasons = diversity.reasons
        if !dedupe.passed {
            reasons.append("dedupe_duplicate_count_\(dedupe.duplicateCount)")
        }
        if !redaction.passed {
            reasons.append("redaction_blocked:\(redaction.blockedTokens.joined(separator: ","))")
        }
        if dataGate.status == "blocked" || dataGate.hasHardFailure {
            reasons.append("decontamination_blocked")
        }
        return Gate7DeterministicGateResult(
            status: reasons.isEmpty ? .pass : .blocked,
            reasons: reasons,
            dataGateReceipt: dataGate
        )
    }
}

public struct Gate7QuotaInput: Equatable, Sendable {
    public var familyID: String
    public var intentBaseline: Int
    public var bugPressure: Int
    public var demoFloor: Int
    public var safetyFloor: Int
    public var sparseFamilyFloor: Int?
    public var recipeQuota: Gate7RecipeQuotaConfig

    public init(
        familyID: String,
        intentBaseline: Int,
        bugPressure: Int,
        demoFloor: Int,
        safetyFloor: Int,
        sparseFamilyFloor: Int? = nil,
        recipeQuota: Gate7RecipeQuotaConfig = Gate7RecipeQuotaConfig()
    ) {
        self.familyID = familyID
        self.intentBaseline = intentBaseline
        self.bugPressure = bugPressure
        self.demoFloor = demoFloor
        self.safetyFloor = safetyFloor
        self.sparseFamilyFloor = sparseFamilyFloor
        self.recipeQuota = recipeQuota
    }
}

public struct Gate7RecipeQuotaConfig: Codable, Equatable, Sendable {
    public var quotaSource: String
    public var openClosePolarityMinPerDirection: Int
    public var queryReadOnlyQuota: Int
    public var unsupportedRefusalQuota: Int
    public var safetyRefusalQuota: Int
    public var negativeQuotaActivation: String
    public var multiCallPairingMinimum: Int

    public init(
        quotaSource: String = "intent",
        openClosePolarityMinPerDirection: Int = 0,
        queryReadOnlyQuota: Int = 0,
        unsupportedRefusalQuota: Int = 0,
        safetyRefusalQuota: Int = 0,
        negativeQuotaActivation: String = "deferred_refusal_ratio_zero_conflict",
        multiCallPairingMinimum: Int = 0
    ) {
        self.quotaSource = quotaSource
        self.openClosePolarityMinPerDirection = max(0, openClosePolarityMinPerDirection)
        self.queryReadOnlyQuota = max(0, queryReadOnlyQuota)
        self.unsupportedRefusalQuota = max(0, unsupportedRefusalQuota)
        self.safetyRefusalQuota = max(0, safetyRefusalQuota)
        self.negativeQuotaActivation = negativeQuotaActivation
        self.multiCallPairingMinimum = max(0, multiCallPairingMinimum)
    }

    public static let wave1ConstructionAnchors = Gate7RecipeQuotaConfig(
        quotaSource: "intent_bug_scene_recovery",
        openClosePolarityMinPerDirection: 1,
        queryReadOnlyQuota: 0,
        unsupportedRefusalQuota: 0,
        safetyRefusalQuota: 0,
        negativeQuotaActivation: "deferred_refusal_ratio_zero_conflict",
        multiCallPairingMinimum: 2
    )

    public var activeNegativeQuota: Int {
        guard negativeQuotaActivation == "active" else {
            return 0
        }
        return queryReadOnlyQuota + unsupportedRefusalQuota + safetyRefusalQuota
    }
}

public struct Gate7QuotaAllocation: Codable, Equatable, Sendable {
    public var familyID: String
    public var quota: Int
    public var components: [String: Int]
    public var quotaSource: String
    public var negativeQuotaActivation: String
}

public enum Gate7QuotaCalculator {
    public static func allocate(_ inputs: [Gate7QuotaInput]) -> [Gate7QuotaAllocation] {
        inputs.map { input in
            let floor = max(input.demoFloor, input.safetyFloor, input.sparseFamilyFloor ?? 0)
            let polarityFloor = input.recipeQuota.openClosePolarityMinPerDirection * 2
            let quota = max(
                input.intentBaseline + input.bugPressure + input.recipeQuota.activeNegativeQuota,
                floor,
                polarityFloor,
                input.recipeQuota.multiCallPairingMinimum
            )
            return Gate7QuotaAllocation(
                familyID: input.familyID,
                quota: quota,
                components: [
                    "intent_baseline": input.intentBaseline,
                    "bug_pressure": input.bugPressure,
                    "demo_floor": input.demoFloor,
                    "safety_floor": input.safetyFloor,
                    "sparse_family_floor": input.sparseFamilyFloor ?? 0,
                    "open_close_polarity_floor": polarityFloor,
                    "query_read_only_quota": input.recipeQuota.queryReadOnlyQuota,
                    "unsupported_refusal_quota": input.recipeQuota.unsupportedRefusalQuota,
                    "safety_refusal_quota": input.recipeQuota.safetyRefusalQuota,
                    "active_negative_quota": input.recipeQuota.activeNegativeQuota,
                    "multi_call_pairing_minimum": input.recipeQuota.multiCallPairingMinimum
                ],
                quotaSource: input.recipeQuota.quotaSource,
                negativeQuotaActivation: input.recipeQuota.negativeQuotaActivation
            )
        }
    }
}

public struct Gate7QuotaEnforcementResult: Equatable, Sendable {
    public var status: Gate7PipelineStatus
    public var reasons: [String]

    public init(status: Gate7PipelineStatus, reasons: [String]) {
        self.status = status
        self.reasons = reasons
    }
}

public enum Gate7QuotaEnforcer {
    public static let mismatchReason = "quota_mismatch"

    public static func enforce(
        status: Gate7PipelineStatus,
        reasons: [String],
        allocatedQuota: Int,
        actualGeneratedCount: Int
    ) -> Gate7QuotaEnforcementResult {
        guard allocatedQuota > actualGeneratedCount else {
            return Gate7QuotaEnforcementResult(status: status, reasons: reasons)
        }
        var nextReasons = reasons
        if !nextReasons.contains(mismatchReason) {
            nextReasons.append(mismatchReason)
        }
        return Gate7QuotaEnforcementResult(status: .blocked, reasons: nextReasons)
    }
}

public struct Wave1BatchManifest: Codable, Equatable, Sendable {
    public var manifestVersion: String
    public var contractStatus: String
    public var batchID: String
    public var batchType: String
    public var status: String
    public var stateMachineState: String
    public var allowedStates: [String]
    public var proofClass: String
    public var mainPinSHA: String
    public var laneID: String
    public var laneVendor: String
    public var generatorSourceVendor: String
    public var judgeSourceVendorRequired: String
    public var targetCount: Int
    public var warmupPhase: Bool
    public var quotaConfigSource: String
    public var quotaSource: String
    public var quotaManualOverride: Bool
    public var quotaAllocation: Gate7QuotaAllocation
    public var quotaConfig: Gate7RecipeQuotaConfig
    public var refusalRatioTarget: Double
    public var refusalRatioHardCap: Double
    public var hashRecipeRef: String
    public var hashRecomputedByPipelineRequired: Bool
    public var recoveryBatchTypes: [String]

    enum CodingKeys: String, CodingKey {
        case manifestVersion = "manifest_version"
        case contractStatus = "contract_status"
        case batchID = "batch_id"
        case batchType = "batch_type"
        case status
        case stateMachineState = "state_machine_state"
        case allowedStates = "allowed_states"
        case proofClass = "proof_class"
        case mainPinSHA = "main_pin_sha"
        case laneID = "lane_id"
        case laneVendor = "lane_vendor"
        case generatorSourceVendor = "generator_source_vendor"
        case judgeSourceVendorRequired = "judge_source_vendor_required"
        case targetCount = "target_count"
        case warmupPhase = "warmup_phase"
        case quotaConfigSource = "quota_config_source"
        case quotaSource = "quota_source"
        case quotaManualOverride = "quota_manual_override"
        case quotaAllocation = "quota_allocation"
        case quotaConfig = "quota_config"
        case refusalRatioTarget = "refusal_ratio_target"
        case refusalRatioHardCap = "refusal_ratio_hard_cap"
        case hashRecipeRef = "hash_recipe_ref"
        case hashRecomputedByPipelineRequired = "hash_recomputed_by_pipeline_required"
        case recoveryBatchTypes = "recovery_batch_types"
    }
}

public struct Wave1BatchManifestDryRunReceipt: Codable, Equatable, Sendable {
    public var status: String
    public var manifestVersion: String
    public var batchID: String
    public var targetCount: Int
    public var quotaConfigSource: String
    public var quotaManualOverride: Bool
    public var refusalRatioTarget: Double
    public var refusalRatioHardCap: Double
    public var failureReasons: [String]

    enum CodingKeys: String, CodingKey {
        case status
        case manifestVersion = "manifest_version"
        case batchID = "batch_id"
        case targetCount = "target_count"
        case quotaConfigSource = "quota_config_source"
        case quotaManualOverride = "quota_manual_override"
        case refusalRatioTarget = "refusal_ratio_target"
        case refusalRatioHardCap = "refusal_ratio_hard_cap"
        case failureReasons = "failure_reasons"
    }
}

public enum Wave1BatchManifestBuilder {
    public static let manifestVersion = "wave1-batch-manifest.v1"
    public static let contractStatus = "rev2.1_locked_aligned"
    public static let quotaConfigSource = "Gate7RecipeQuotaConfig.wave1ConstructionAnchors"
    public static let defaultMainPinSHA = "b33d8eba152e5326f69bbe85fc356b73419ee9c3"

    public static func warmup(
        batchID: String = "wave1-warmup-0001",
        mainPinSHA: String = defaultMainPinSHA,
        laneID: String = "lane-1",
        laneVendor: String = "anthropic",
        generatorSourceVendor: String = "anthropic",
        judgeSourceVendorRequired: String = "openai",
        targetCount: Int = 50,
        quotaConfig: Gate7RecipeQuotaConfig = .wave1ConstructionAnchors
    ) -> Wave1BatchManifest {
        let allocation = Gate7QuotaCalculator.allocate([
            Gate7QuotaInput(
                familyID: batchID,
                intentBaseline: max(0, targetCount),
                bugPressure: 0,
                demoFloor: 0,
                safetyFloor: 0,
                recipeQuota: quotaConfig
            )
        ]).first ?? Gate7QuotaAllocation(
            familyID: batchID,
            quota: max(0, targetCount),
            components: [:],
            quotaSource: quotaConfig.quotaSource,
            negativeQuotaActivation: quotaConfig.negativeQuotaActivation
        )
        return Wave1BatchManifest(
            manifestVersion: manifestVersion,
            contractStatus: contractStatus,
            batchID: batchID,
            batchType: "standard_generation",
            status: "gated",
            stateMachineState: "ready_for_generation",
            allowedStates: ["ready_for_generation", "paused_diversity", "blocked", "generated", "accepted"],
            proofClass: "local_mock",
            mainPinSHA: mainPinSHA,
            laneID: laneID,
            laneVendor: laneVendor,
            generatorSourceVendor: generatorSourceVendor,
            judgeSourceVendorRequired: judgeSourceVendorRequired,
            targetCount: max(0, targetCount),
            warmupPhase: true,
            quotaConfigSource: quotaConfigSource,
            quotaSource: allocation.quotaSource,
            quotaManualOverride: false,
            quotaAllocation: allocation,
            quotaConfig: quotaConfig,
            refusalRatioTarget: 0,
            refusalRatioHardCap: 0,
            hashRecipeRef: C5DerivedHashRecipe.hashRecipeRef,
            hashRecomputedByPipelineRequired: true,
            recoveryBatchTypes: ["recovery_projection", "recovery_rejudge_datagate"]
        )
    }

    public static func validateDryRun(_ manifest: Wave1BatchManifest) -> Wave1BatchManifestDryRunReceipt {
        var failures: [String] = []
        if manifest.manifestVersion != manifestVersion {
            failures.append("manifest_version_mismatch")
        }
        if manifest.contractStatus != contractStatus {
            failures.append("contract_status_mismatch")
        }
        if manifest.targetCount != 50 || !manifest.warmupPhase {
            failures.append("warmup_target_count_mismatch")
        }
        if manifest.mainPinSHA != defaultMainPinSHA {
            failures.append("main_pin_sha_mismatch")
        }
        if manifest.quotaConfigSource != quotaConfigSource || manifest.quotaManualOverride {
            failures.append("quota_not_derived_from_gate7_recipe_config")
        }
        if manifest.refusalRatioTarget != 0 || manifest.refusalRatioHardCap != 0 {
            failures.append("refusal_ratio_lock_mismatch")
        }
        if manifest.hashRecipeRef.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !manifest.hashRecomputedByPipelineRequired {
            failures.append("hash_recompute_contract_missing")
        }
        return Wave1BatchManifestDryRunReceipt(
            status: failures.isEmpty ? "pass" : "blocked",
            manifestVersion: manifest.manifestVersion,
            batchID: manifest.batchID,
            targetCount: manifest.targetCount,
            quotaConfigSource: manifest.quotaConfigSource,
            quotaManualOverride: manifest.quotaManualOverride,
            refusalRatioTarget: manifest.refusalRatioTarget,
            refusalRatioHardCap: manifest.refusalRatioHardCap,
            failureReasons: failures
        )
    }
}

public enum Gate7PrecisionGate {
    public static func humanReviewSampleSize(candidateCount: Int) -> Int {
        guard candidateCount > 0 else {
            return 0
        }
        return min(50, max(20, Int(ceil(Double(candidateCount) * 0.10))))
    }

    public static func shouldStopFamily(reviewed: Int, accepted: Int, threshold: Double = 0.8) -> Bool {
        guard reviewed > 0 else {
            return true
        }
        return Double(accepted) / Double(reviewed) < threshold
    }
}
