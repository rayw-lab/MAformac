import Foundation

public enum C5RouteTier: String, Codable, CaseIterable, Sendable {
    case ruleL1 = "rule_l1"
    case fcL2 = "fc_l2"
    case fcL3 = "fc_l3"

    public static func derive(fuzzy: Bool, free: Bool) -> C5RouteTier {
        if free {
            return .fcL3
        }
        if fuzzy {
            return .fcL2
        }
        return .ruleL1
    }
}

public enum C5UtteranceSource: String, Codable, Sendable {
    case singleTurnSeed = "semantic_protocol_seed"
    case llmAugmented = "llm_augmented"
    case followupSidecar = "followup_sidecar"
}

public enum C5ValueStrategy: String, Codable, CaseIterable, Sendable {
    case slotExtract = "slot_extract"
    case expInverseNormalize = "exp_inverse_normalize"
    case percentExtract = "percent_extract"

    public static func derive(valueType: String) -> C5ValueStrategy {
        switch valueType.uppercased() {
        case "EXP":
            return .expInverseNormalize
        case "PERCENT":
            return .percentExtract
        default:
            return .slotExtract
        }
    }
}

public enum C5MaskingStage: String, Codable, CaseIterable, Sendable {
    case smokeOnly = "smoke_only"
    case trainableV0 = "trainable_v0"
    case maskingCompleteV1 = "masking_complete_v1"

    public var trainEligible: Bool {
        switch self {
        case .smokeOnly:
            return false
        case .trainableV0, .maskingCompleteV1:
            return true
        }
    }
}

public enum C5AcceptanceStage: String, Codable, Sendable {
    case trainHealth = "train_health"
    case trainableV0 = "trainable_v0"
    case loraCandidate = "lora_candidate"
}

public struct C5FCFlags: Codable, Equatable, Sendable {
    public var fuzzy: Bool
    public var free: Bool

    public init(fuzzy: Bool, free: Bool) {
        self.fuzzy = fuzzy
        self.free = free
    }
}

public struct C5ContractValue: Codable, Equatable, Sendable {
    public var ref: String
    public var direct: String
    public var offset: String
    public var type: String

    public init(ref: String = "", direct: String = "", offset: String = "", type: String = "") {
        self.ref = ref
        self.direct = direct
        self.offset = offset
        self.type = type
    }
}

public struct C5DSSemantic: Decodable, Equatable, Sendable {
    public var slots: [String: JSONValue]

    enum CodingKeys: String, CodingKey {
        case slots
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        slots = try container.decodeIfPresent([String: JSONValue].self, forKey: .slots) ?? [:]
    }
}

public struct C5DSProtocol: Decodable, Equatable, Sendable {
    public var semantic: C5DSSemantic

    enum CodingKeys: String, CodingKey {
        case semantic
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        semantic = try container.decodeIfPresent(C5DSSemantic.self, forKey: .semantic) ?? C5DSSemantic(slots: [:])
    }

    public init(semantic: C5DSSemantic) {
        self.semantic = semantic
    }
}

extension C5DSSemantic {
    public init(slots: [String: JSONValue]) {
        self.slots = slots
    }
}

public struct C5SemanticSeed: Decodable, Equatable, Sendable {
    public var contractRowID: String
    public var canonicalSemanticID: String
    public var dedupeGroupID: String
    public var dedupeRole: String
    public var device: String
    public var actionPrimitive: String
    public var actionCode: String
    public var intent: String
    public var service: String
    public var execTier: String
    public var fcFlags: C5FCFlags
    public var slotKeys: [String]
    public var value: C5ContractValue
    public var sourceDomain: String
    public var sourceSheet: String
    public var sourceRowNo: Int
    public var range: String
    public var semanticSlots: [String: JSONValue]

    enum CodingKeys: String, CodingKey {
        case contractRowID = "contract_row_id"
        case canonicalSemanticID = "canonical_semantic_id"
        case dedupeGroupID = "dedupe_group_id"
        case dedupeRole = "dedupe_role"
        case device
        case actionPrimitive = "action_primitive"
        case actionCode = "action_code"
        case intent
        case service
        case execTier = "exec_tier"
        case fcFlags = "fc_flags"
        case slotKeys = "slot_keys"
        case value
        case sourceDomain = "source_domain"
        case sourceSheet = "source_sheet"
        case sourceRowNo = "source_row_no"
        case range
        case dsProtocol = "ds_protocol"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        contractRowID = try container.decode(String.self, forKey: .contractRowID)
        canonicalSemanticID = try container.decode(String.self, forKey: .canonicalSemanticID)
        dedupeGroupID = try container.decode(String.self, forKey: .dedupeGroupID)
        dedupeRole = try container.decode(String.self, forKey: .dedupeRole)
        device = try container.decode(String.self, forKey: .device)
        actionPrimitive = try container.decode(String.self, forKey: .actionPrimitive)
        actionCode = try container.decode(String.self, forKey: .actionCode)
        intent = try container.decode(String.self, forKey: .intent)
        service = try container.decode(String.self, forKey: .service)
        execTier = try container.decode(String.self, forKey: .execTier)
        fcFlags = try container.decode(C5FCFlags.self, forKey: .fcFlags)
        slotKeys = try container.decodeIfPresent([String].self, forKey: .slotKeys) ?? []
        value = try container.decode(C5ContractValue.self, forKey: .value)
        sourceDomain = try container.decode(String.self, forKey: .sourceDomain)
        sourceSheet = try container.decode(String.self, forKey: .sourceSheet)
        sourceRowNo = try container.decode(Int.self, forKey: .sourceRowNo)
        range = try container.decodeIfPresent(String.self, forKey: .range) ?? ""
        semanticSlots = try container.decodeIfPresent(C5DSProtocol.self, forKey: .dsProtocol)?.semantic.slots ?? [:]
    }

    public var routeTier: C5RouteTier {
        C5RouteTier.derive(fuzzy: fcFlags.fuzzy, free: fcFlags.free)
    }

    public var valueStrategy: C5ValueStrategy {
        C5ValueStrategy.derive(valueType: value.type)
    }
}

public struct C5TrainingMessage: Codable, Equatable, Sendable {
    public var role: String
    public var content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public struct C5TrainingToolCall: Codable, Equatable, Sendable {
    public var name: String
    public var arguments: [String: JSONValue]

    public init(name: String, arguments: [String: JSONValue]) {
        self.name = name
        self.arguments = arguments
    }
}

public struct C5NoCallMetadata: Codable, Equatable, Sendable {
    public var counterfactualPairID: String
    public var targetToolPresent: Bool
    public var removedToolID: String
    public var distractorToolIDs: [String]
    public var noCallReason: String

    enum CodingKeys: String, CodingKey {
        case counterfactualPairID = "counterfactual_pair_id"
        case targetToolPresent = "target_tool_present"
        case removedToolID = "removed_tool_id"
        case distractorToolIDs = "distractor_tool_ids"
        case noCallReason = "no_call_reason"
    }
}

public struct C5TrainingSample: Codable, Equatable, Sendable {
    public var sampleID: String
    public var split: String
    public var splitOrigin: String
    public var bucket: String
    public var augmentationParentID: String
    public var lineageGroupID: String
    public var parentSemanticID: String
    public var seedParentSemanticID: String
    public var candidateParentSemanticID: String
    public var candidateCanonicalSemanticID: String
    public var candidateDedupeGroupID: String
    public var expectedToolCallSignature: String
    public var routeTierSource: String
    public var routeTier: C5RouteTier
    public var executionTier: String
    public var utteranceSource: C5UtteranceSource
    public var valueStrategy: C5ValueStrategy
    public var maskingStage: C5MaskingStage
    public var trainEligible: Bool
    public var masking: C5MaskingFlags
    public var acceptanceStage: C5AcceptanceStage
    public var generatorModelID: String
    public var generatorCallID: String
    public var semanticJudgeModelID: String
    public var semanticJudgeCallID: String
    public var promptHash: String
    public var messages: [C5TrainingMessage]
    public var tools: [[String: JSONValue]]
    public var expectedToolCalls: [C5TrainingToolCall]
    public var noCall: C5NoCallMetadata?
    public var promptDistractorToolIDs: [String]

    enum CodingKeys: String, CodingKey {
        case sampleID = "sample_id"
        case split
        case splitOrigin = "split_origin"
        case bucket
        case augmentationParentID = "augmentation_parent_id"
        case lineageGroupID = "lineage_group_id"
        case parentSemanticID = "parent_semantic_id"
        case seedParentSemanticID = "seed_parent_semantic_id"
        case candidateParentSemanticID = "candidate_parent_semantic_id"
        case candidateCanonicalSemanticID = "candidate_canonical_semantic_id"
        case candidateDedupeGroupID = "candidate_dedupe_group_id"
        case expectedToolCallSignature = "expected_tool_call_signature"
        case routeTierSource = "route_tier_source"
        case routeTier = "route_tier"
        case executionTier = "execution_tier"
        case utteranceSource = "utterance_source"
        case valueStrategy = "value_strategy"
        case maskingStage = "masking_stage"
        case trainEligible = "train_eligible"
        case masking
        case acceptanceStage = "acceptance_stage"
        case generatorModelID = "generator_model_id"
        case generatorCallID = "generator_call_id"
        case semanticJudgeModelID = "semantic_judge_model_id"
        case semanticJudgeCallID = "semantic_judge_call_id"
        case promptHash = "prompt_hash"
        case messages
        case tools
        case expectedToolCalls = "expected_tool_calls"
        case noCall = "no_call"
        case promptDistractorToolIDs = "prompt_distractor_tool_ids"
    }

    public var assistantPayload: String {
        guard let assistant = messages.last(where: { $0.role == "assistant" }) else {
            return ""
        }
        return assistant.content
    }

    public var dataGateCandidate: C5DataGateCandidate {
        C5DataGateCandidate(
            sampleID: sampleID,
            split: split,
            bucket: bucket,
            caseID: sampleID,
            parentSemanticID: parentSemanticID,
            candidateParentSemanticID: candidateParentSemanticID,
            mustNotTrain: split != "train",
            sourceAuthorization: "authorized_c1_semantic_contract",
            inputText: messages.first(where: { $0.role == "user" })?.content ?? "",
            assistantText: assistantPayload,
            hasActionToolCall: !expectedToolCalls.isEmpty,
            hasSharedWrapper: assistantPayload.contains("<tool_call>"),
            masking: masking
        )
    }

    public var mlxRecord: C5MLXRecord {
        C5MLXRecord(messages: messages, tools: tools)
    }
}

public struct C5MLXRecord: Codable, Equatable, Sendable {
    public var messages: [C5TrainingMessage]
    public var tools: [[String: JSONValue]]
}

public struct C5ValueAugmentation: Equatable, Sendable {
    public var value: C5ContractValue
    public var utteranceValueText: String
    public var didAugment: Bool
}

public struct C5TrainingEnvironment: Codable, Equatable, Sendable {
    public var seed: Int
    public var mlxVersion: String
    public var mlxLMVersion: String
    public var transformersVersion: String
    public var hardware: String
    public var dtype: String
    public var baseModel: String
    public var baseModelCommitSHA: String
    public var repoCommitSHA: String
    public var trainingBackend: String
    public var gradientClipStatus: String

    enum CodingKeys: String, CodingKey {
        case seed
        case mlxVersion = "mlx_version"
        case mlxLMVersion = "mlx_lm_version"
        case transformersVersion = "transformers_version"
        case hardware
        case dtype
        case baseModel = "base_model"
        case baseModelCommitSHA = "base_model_commit_sha"
        case repoCommitSHA = "repo_commit_sha"
        case trainingBackend = "training_backend"
        case gradientClipStatus = "gradient_clip_status"
    }

    public init(
        seed: Int,
        mlxVersion: String,
        mlxLMVersion: String,
        transformersVersion: String,
        hardware: String,
        dtype: String,
        baseModel: String,
        baseModelCommitSHA: String,
        repoCommitSHA: String,
        trainingBackend: String,
        gradientClipStatus: String
    ) {
        self.seed = seed
        self.mlxVersion = mlxVersion
        self.mlxLMVersion = mlxLMVersion
        self.transformersVersion = transformersVersion
        self.hardware = hardware
        self.dtype = dtype
        self.baseModel = baseModel
        self.baseModelCommitSHA = baseModelCommitSHA
        self.repoCommitSHA = repoCommitSHA
        self.trainingBackend = trainingBackend
        self.gradientClipStatus = gradientClipStatus
    }

    public static func defaultPrepare(baseModel: String = "mlx-community/Qwen3-1.7B-4bit") -> C5TrainingEnvironment {
        C5TrainingEnvironment(
            seed: 0,
            mlxVersion: "unknown_at_prepare_time",
            mlxLMVersion: "unknown_at_prepare_time",
            transformersVersion: "unknown_at_prepare_time",
            hardware: "unknown_at_prepare_time",
            dtype: "bf16_lora_on_4bit_base",
            baseModel: baseModel,
            baseModelCommitSHA: "unknown_at_prepare_time",
            repoCommitSHA: "unknown_at_prepare_time",
            trainingBackend: "maformac_c5_repo_loop_mlx_lm_0_31_1",
            gradientClipStatus: "implemented_repo_loop_clip_grad_norm_max_1.0_nonfinite_stop_fallback_lr_5e-5"
        )
    }
}

public struct C5TrainingCurveReceipt: Codable, Equatable, Sendable {
    public var metricsJSONLRef: String
    public var trainingLogRef: String
    public var bestCheckpointPolicy: String
    public var bestCheckpointStep: Int?
    public var bestCheckpointValLoss: Double?
    public var note: String

    enum CodingKeys: String, CodingKey {
        case metricsJSONLRef = "metrics_jsonl_ref"
        case trainingLogRef = "training_log_ref"
        case bestCheckpointPolicy = "best_checkpoint_policy"
        case bestCheckpointStep = "best_checkpoint_step"
        case bestCheckpointValLoss = "best_checkpoint_val_loss"
        case note
    }

    public static let preparePlanned = C5TrainingCurveReceipt(
        metricsJSONLRef: "metrics.jsonl",
        trainingLogRef: "planned_maformac_c5_repo_loop_stdout_log",
        bestCheckpointPolicy: "dev_selection_val_loss_then_C6_final_only",
        bestCheckpointStep: nil,
        bestCheckpointValLoss: nil,
        note: "prepare receipt only; parse the MLX log after smoke/train to populate curve metrics"
    )
}

public struct C5TrainingBuildOptions: Equatable, Sendable {
    public var targetPositiveRows: Int
    public var devSelectionRows: Int
    public var refusalRatioTarget: Double
    public var refusalRatioHardCap: Double
    public var maxVariantsPerSeed: Int
    public var maskingStage: C5MaskingStage
    public var usesTrainingTokenizerPatch: Bool
    public var modelOverride: String?
    public var generatedAt: String
    public var environment: C5TrainingEnvironment
    public var trainingCurve: C5TrainingCurveReceipt
    public var endpointTokenizerParity: C5EndpointTokenizerParityGate
    public var offsetTokenArtifact: C5MaskOffsetTokenArtifact?
    public var generatedUtteranceRecords: [C5GeneratedUtteranceRecord]

    public init(
        targetPositiveRows: Int = 4_500,
        devSelectionRows: Int = 400,
        refusalRatioTarget: Double = 0.10,
        refusalRatioHardCap: Double = 0.20,
        maxVariantsPerSeed: Int = 8,
        maskingStage: C5MaskingStage = .trainableV0,
        usesTrainingTokenizerPatch: Bool = false,
        modelOverride: String? = nil,
        generatedAt: String = "1970-01-01T00:00:00Z",
        environment: C5TrainingEnvironment = .defaultPrepare(),
        trainingCurve: C5TrainingCurveReceipt = .preparePlanned,
        endpointTokenizerParity: C5EndpointTokenizerParityGate = .blockedMissingEndpointRender(),
        offsetTokenArtifact: C5MaskOffsetTokenArtifact? = nil,
        generatedUtteranceRecords: [C5GeneratedUtteranceRecord] = []
    ) {
        self.targetPositiveRows = targetPositiveRows
        self.devSelectionRows = devSelectionRows
        self.refusalRatioTarget = refusalRatioTarget
        self.refusalRatioHardCap = refusalRatioHardCap
        self.maxVariantsPerSeed = maxVariantsPerSeed
        self.maskingStage = maskingStage
        self.usesTrainingTokenizerPatch = usesTrainingTokenizerPatch
        self.modelOverride = modelOverride
        self.generatedAt = generatedAt
        self.environment = environment
        self.trainingCurve = trainingCurve
        self.endpointTokenizerParity = endpointTokenizerParity
        self.offsetTokenArtifact = offsetTokenArtifact
        self.generatedUtteranceRecords = generatedUtteranceRecords
    }
}

public struct C5GeneratedUtteranceRecord: Codable, Equatable, Sendable {
    public var contractRowID: String
    public var variant: Int
    public var utterance: String
    public var generatorModelID: String
    public var generatorCallID: String
    public var semanticJudgeModelID: String
    public var semanticJudgeCallID: String
    public var promptHash: String
    public var candidateParentSemanticID: String

    enum CodingKeys: String, CodingKey {
        case contractRowID = "contract_row_id"
        case variant
        case utterance
        case generatorModelID = "generator_model_id"
        case generatorCallID = "generator_call_id"
        case semanticJudgeModelID = "semantic_judge_model_id"
        case semanticJudgeCallID = "semantic_judge_call_id"
        case promptHash = "prompt_hash"
        case candidateParentSemanticID = "candidate_parent_semantic_id"
    }
}

public struct C5MaskOffsetTokenProbe: Codable, Equatable, Sendable {
    public var sampleID: String
    public var assistantPayloadDigest: String
    public var expectedStart: String
    public var offset: Int
    public var length: Int
    public var trainedTokenCount: Int
    public var trainedSpanDigest: String
    public var trainedSpanStartsWithExpected: Bool
    public var trainedSpanContainsUserMarker: Bool
    public var trainedSpanContainsSystemMarker: Bool
    public var trainedSpanContainsThinkMarker: Bool
    public var status: String
    public var failureReceipt: [String]

    enum CodingKeys: String, CodingKey {
        case sampleID = "sample_id"
        case assistantPayloadDigest = "assistant_payload_digest"
        case expectedStart = "expected_start"
        case offset
        case length
        case trainedTokenCount = "trained_token_count"
        case trainedSpanDigest = "trained_span_digest"
        case trainedSpanStartsWithExpected = "trained_span_starts_with_expected"
        case trainedSpanContainsUserMarker = "trained_span_contains_user_marker"
        case trainedSpanContainsSystemMarker = "trained_span_contains_system_marker"
        case trainedSpanContainsThinkMarker = "trained_span_contains_think_marker"
        case status
        case failureReceipt = "failure_receipt"
    }
}

public struct C5MaskOffsetTokenArtifact: Codable, Equatable, Sendable {
    public var status: String
    public var artifactPath: String
    public var artifactSHA256: String
    public var tokenizerModelID: String
    public var mlxLMVersion: String
    public var transformersVersion: String
    public var generatedAt: String
    public var sampleCount: Int
    public var classCoverage: [String]
    public var probes: [C5MaskOffsetTokenProbe]
    public var failureReceipt: [String]

    enum CodingKeys: String, CodingKey {
        case status
        case artifactPath = "artifact_path"
        case artifactSHA256 = "artifact_sha256"
        case tokenizerModelID = "tokenizer_model_id"
        case mlxLMVersion = "mlx_lm_version"
        case transformersVersion = "transformers_version"
        case generatedAt = "generated_at"
        case sampleCount = "sample_count"
        case classCoverage = "class_coverage"
        case probes
        case failureReceipt = "failure_receipt"
    }
}

public struct C5MaskOffsetFixture: Codable, Equatable, Sendable {
    public var status: String
    public var assistantContentHasPrefix: Bool
    public var trainedSpanEqualsToolCall: Bool
    public var assistantPrefixBytes: Int
    public var assistantPayloadDigest: String
    public var tokenArtifact: C5MaskOffsetTokenArtifact?
    public var failureReceipt: [String]

    enum CodingKeys: String, CodingKey {
        case status
        case assistantContentHasPrefix = "assistant_content_has_prefix"
        case trainedSpanEqualsToolCall = "trained_span_equals_tool_call"
        case assistantPrefixBytes = "assistant_prefix_bytes"
        case assistantPayloadDigest = "assistant_payload_digest"
        case tokenArtifact = "token_artifact"
        case failureReceipt = "failure_receipt"
    }

    public static func validate(
        samples: [C5TrainingSample],
        usesTrainingTokenizerPatch: Bool = false,
        tokenArtifact: C5MaskOffsetTokenArtifact? = nil,
        expectedTokenizerModelID: String? = nil
    ) -> C5MaskOffsetFixture {
        guard let actionSample = samples.first(where: { $0.split == "train" && !$0.expectedToolCalls.isEmpty })
            ?? samples.first(where: { !$0.expectedToolCalls.isEmpty }) else {
            return C5MaskOffsetFixture(
                status: "fail",
                assistantContentHasPrefix: false,
                trainedSpanEqualsToolCall: false,
                assistantPrefixBytes: 2,
                assistantPayloadDigest: "",
                tokenArtifact: tokenArtifact,
                failureReceipt: ["missing_action_sample"]
            )
        }

        let noCallSample = samples.first(where: { $0.split == "train" && $0.expectedToolCalls.isEmpty && $0.noCall != nil })
            ?? samples.first(where: { $0.expectedToolCalls.isEmpty && $0.noCall != nil })
        let content = actionSample.assistantPayload
        let hasPrefix = content.hasPrefix("\n\n")
        let trainedSpan = hasPrefix ? String(content.dropFirst(2)) : content
        let expected = actionSample.expectedToolCalls.first.map(C5TrainingRenderer.renderToolCall) ?? "NO_TOOL"
        let spanMatches = trainedSpan == expected
        var failures: [String] = []
        if !hasPrefix {
            failures.append("assistant_content_missing_double_newline_prefix")
        }
        if !spanMatches {
            failures.append("trained_span_after_prefix_does_not_equal_expected_tool_call")
        }
        if !usesTrainingTokenizerPatch {
            failures.append("training_tokenizer_patch_not_declared")
        }
        guard let artifact = tokenArtifact else {
            failures.append("mlx_apply_chat_template_token_artifact_missing")
            let requiredOnly: Set<String> = ["training_tokenizer_patch_not_declared", "mlx_apply_chat_template_token_artifact_missing"]
            let status = failures.allSatisfy(requiredOnly.contains) ? "external_mlx_fixture_required" : "fail"
            return C5MaskOffsetFixture(
                status: status,
                assistantContentHasPrefix: hasPrefix,
                trainedSpanEqualsToolCall: spanMatches,
                assistantPrefixBytes: "\n\n".utf8.count,
                assistantPayloadDigest: C6Hash.sha256Hex(Data(content.utf8)),
                tokenArtifact: nil,
                failureReceipt: failures
            )
        }

        if artifact.status != "pass" {
            failures.append("mlx_apply_chat_template_token_artifact_status_\(artifact.status)")
        }
        if artifact.artifactSHA256.isEmpty {
            failures.append("mlx_apply_chat_template_token_artifact_digest_missing")
        }
        if let expectedTokenizerModelID, artifact.tokenizerModelID != expectedTokenizerModelID {
            failures.append("mlx_apply_chat_template_token_artifact_tokenizer_mismatch")
        }
        if !artifact.classCoverage.contains("tool_call") {
            failures.append("mlx_apply_chat_template_token_artifact_missing_tool_call_probe")
        }
        if noCallSample != nil && !artifact.classCoverage.contains("no_call") {
            failures.append("mlx_apply_chat_template_token_artifact_missing_no_call_probe")
        }

        validateProbe(for: actionSample, expectedStart: "<tool_call>", artifact: artifact, failures: &failures)
        if let noCallSample {
            validateProbe(for: noCallSample, expectedStart: "NO_TOOL", artifact: artifact, failures: &failures)
        }

        return C5MaskOffsetFixture(
            status: failures.isEmpty ? "pass" : "fail",
            assistantContentHasPrefix: hasPrefix,
            trainedSpanEqualsToolCall: spanMatches,
            assistantPrefixBytes: "\n\n".utf8.count,
            assistantPayloadDigest: C6Hash.sha256Hex(Data(content.utf8)),
            tokenArtifact: artifact,
            failureReceipt: failures
        )
    }

    private static func validateProbe(
        for sample: C5TrainingSample,
        expectedStart: String,
        artifact: C5MaskOffsetTokenArtifact,
        failures: inout [String]
    ) {
        let digest = C6Hash.sha256Hex(Data(sample.assistantPayload.utf8))
        guard let probe = artifact.probes.first(where: { $0.sampleID == sample.sampleID || $0.assistantPayloadDigest == digest }) else {
            failures.append("mlx_apply_chat_template_token_artifact_missing_probe_\(expectedStart == "NO_TOOL" ? "no_call" : "tool_call")")
            return
        }
        if probe.status != "pass" {
            failures.append("mlx_apply_chat_template_token_probe_failed_\(probe.sampleID)")
        }
        if probe.assistantPayloadDigest != digest {
            failures.append("mlx_apply_chat_template_token_probe_digest_mismatch_\(probe.sampleID)")
        }
        if probe.expectedStart != expectedStart || !probe.trainedSpanStartsWithExpected {
            failures.append("mlx_apply_chat_template_token_probe_start_mismatch_\(probe.sampleID)")
        }
        if probe.trainedSpanContainsUserMarker {
            failures.append("mlx_apply_chat_template_token_probe_contains_user_\(probe.sampleID)")
        }
        if probe.trainedSpanContainsSystemMarker {
            failures.append("mlx_apply_chat_template_token_probe_contains_system_\(probe.sampleID)")
        }
        if probe.trainedSpanContainsThinkMarker {
            failures.append("mlx_apply_chat_template_token_probe_contains_think_\(probe.sampleID)")
        }
        if probe.offset <= 0 || probe.length <= probe.offset || probe.trainedTokenCount <= 0 {
            failures.append("mlx_apply_chat_template_token_probe_invalid_offsets_\(probe.sampleID)")
        }
    }
}

public struct C5MLXLoRAConfig: Codable, Equatable, Sendable {
    public var model: String
    public var fineTuneType: String
    public var numLayers: Int
    public var rank: Int
    public var scale: Double
    public var dropout: Double
    public var learningRate: Double
    public var lrSchedule: String
    public var warmupFraction: Double
    public var scheduleDecaySteps: Int
    public var warmupSteps: Int
    public var epochs: Int
    public var batchSize: Int
    public var gradAccumulationSteps: Int
    public var maxSeqLength: Int
    public var optimizer: String
    public var weightDecay: Double
    public var seed: Int
    public var gradClipNorm: Double
    public var trainingLoop: String
    public var keys: [String]
    public var secondaryExperiments: [String]

    enum CodingKeys: String, CodingKey {
        case model
        case fineTuneType = "fine_tune_type"
        case numLayers = "num_layers"
        case rank
        case scale
        case dropout
        case learningRate = "learning_rate"
        case lrSchedule = "lr_schedule"
        case warmupFraction = "warmup_fraction"
        case scheduleDecaySteps = "schedule_decay_steps"
        case warmupSteps = "warmup_steps"
        case epochs
        case batchSize = "batch_size"
        case gradAccumulationSteps = "grad_accumulation_steps"
        case maxSeqLength = "max_seq_length"
        case optimizer
        case weightDecay = "weight_decay"
        case seed
        case gradClipNorm = "grad_clip_norm"
        case trainingLoop = "training_loop"
        case keys
        case secondaryExperiments = "secondary_experiments"
        case lrScheduleStepUnit = "lr_schedule_step_unit"
        case optimizerUpdateSteps = "optimizer_update_steps"
        case renderedScheduleDecaySteps = "rendered_schedule_decay_steps"
        case renderedWarmupSteps = "rendered_warmup_steps"
    }

    public init(
        model: String,
        fineTuneType: String,
        numLayers: Int,
        rank: Int,
        scale: Double,
        dropout: Double,
        learningRate: Double,
        lrSchedule: String,
        warmupFraction: Double,
        scheduleDecaySteps: Int,
        warmupSteps: Int,
        epochs: Int,
        batchSize: Int,
        gradAccumulationSteps: Int,
        maxSeqLength: Int,
        optimizer: String,
        weightDecay: Double,
        seed: Int,
        gradClipNorm: Double,
        trainingLoop: String,
        keys: [String],
        secondaryExperiments: [String]
    ) {
        self.model = model
        self.fineTuneType = fineTuneType
        self.numLayers = numLayers
        self.rank = rank
        self.scale = scale
        self.dropout = dropout
        self.learningRate = learningRate
        self.lrSchedule = lrSchedule
        self.warmupFraction = warmupFraction
        self.scheduleDecaySteps = scheduleDecaySteps
        self.warmupSteps = warmupSteps
        self.epochs = epochs
        self.batchSize = batchSize
        self.gradAccumulationSteps = gradAccumulationSteps
        self.maxSeqLength = maxSeqLength
        self.optimizer = optimizer
        self.weightDecay = weightDecay
        self.seed = seed
        self.gradClipNorm = gradClipNorm
        self.trainingLoop = trainingLoop
        self.keys = keys
        self.secondaryExperiments = secondaryExperiments
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            model: try container.decode(String.self, forKey: .model),
            fineTuneType: try container.decode(String.self, forKey: .fineTuneType),
            numLayers: try container.decode(Int.self, forKey: .numLayers),
            rank: try container.decode(Int.self, forKey: .rank),
            scale: try container.decode(Double.self, forKey: .scale),
            dropout: try container.decode(Double.self, forKey: .dropout),
            learningRate: try container.decode(Double.self, forKey: .learningRate),
            lrSchedule: try container.decode(String.self, forKey: .lrSchedule),
            warmupFraction: try container.decode(Double.self, forKey: .warmupFraction),
            scheduleDecaySteps: try container.decode(Int.self, forKey: .scheduleDecaySteps),
            warmupSteps: try container.decode(Int.self, forKey: .warmupSteps),
            epochs: try container.decode(Int.self, forKey: .epochs),
            batchSize: try container.decode(Int.self, forKey: .batchSize),
            gradAccumulationSteps: try container.decode(Int.self, forKey: .gradAccumulationSteps),
            maxSeqLength: try container.decode(Int.self, forKey: .maxSeqLength),
            optimizer: try container.decodeIfPresent(String.self, forKey: .optimizer) ?? "adamw",
            weightDecay: try container.decodeIfPresent(Double.self, forKey: .weightDecay) ?? 0.01,
            seed: try container.decodeIfPresent(Int.self, forKey: .seed) ?? 0,
            gradClipNorm: try container.decodeIfPresent(Double.self, forKey: .gradClipNorm) ?? 1.0,
            trainingLoop: try container.decodeIfPresent(String.self, forKey: .trainingLoop) ?? "maformac_c5_repo_loop_mlx_lm_0_31_1",
            keys: try container.decode([String].self, forKey: .keys),
            secondaryExperiments: try container.decode([String].self, forKey: .secondaryExperiments)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(model, forKey: .model)
        try container.encode(fineTuneType, forKey: .fineTuneType)
        try container.encode(numLayers, forKey: .numLayers)
        try container.encode(rank, forKey: .rank)
        try container.encode(scale, forKey: .scale)
        try container.encode(dropout, forKey: .dropout)
        try container.encode(learningRate, forKey: .learningRate)
        try container.encode(lrSchedule, forKey: .lrSchedule)
        try container.encode(warmupFraction, forKey: .warmupFraction)
        try container.encode(scheduleDecaySteps, forKey: .scheduleDecaySteps)
        try container.encode(warmupSteps, forKey: .warmupSteps)
        try container.encode(epochs, forKey: .epochs)
        try container.encode(batchSize, forKey: .batchSize)
        try container.encode(gradAccumulationSteps, forKey: .gradAccumulationSteps)
        try container.encode(maxSeqLength, forKey: .maxSeqLength)
        try container.encode(optimizer, forKey: .optimizer)
        try container.encode(weightDecay, forKey: .weightDecay)
        try container.encode(seed, forKey: .seed)
        try container.encode(gradClipNorm, forKey: .gradClipNorm)
        try container.encode(trainingLoop, forKey: .trainingLoop)
        try container.encode(keys, forKey: .keys)
        try container.encode(secondaryExperiments, forKey: .secondaryExperiments)
        try container.encode(lrScheduleStepUnit, forKey: .lrScheduleStepUnit)
        try container.encode(optimizerUpdateSteps, forKey: .optimizerUpdateSteps)
        try container.encode(renderedScheduleDecaySteps, forKey: .renderedScheduleDecaySteps)
        try container.encode(renderedWarmupSteps, forKey: .renderedWarmupSteps)
    }

    public static let defaultProjectionKeys = [
        "self_attn.q_proj",
        "self_attn.k_proj",
        "self_attn.v_proj",
        "self_attn.o_proj",
        "mlp.gate_proj",
        "mlp.up_proj",
        "mlp.down_proj"
    ]

    public static func rank16Mainline(model: String = "mlx-community/Qwen3-1.7B-4bit", maxSeqLength: Int = 1024) -> C5MLXLoRAConfig {
        C5MLXLoRAConfig(
            model: model,
            fineTuneType: "lora",
            numLayers: -1,
            rank: 16,
            scale: 32,
            dropout: 0,
            learningRate: 0.0001,
            lrSchedule: "cosine",
            warmupFraction: 0.08,
            scheduleDecaySteps: 600,
            warmupSteps: 48,
            epochs: 3,
            batchSize: 4,
            gradAccumulationSteps: 4,
            maxSeqLength: maxSeqLength,
            optimizer: "adamw",
            weightDecay: 0.01,
            seed: 0,
            gradClipNorm: 1.0,
            trainingLoop: "maformac_c5_repo_loop_mlx_lm_0_31_1",
            keys: defaultProjectionKeys,
            secondaryExperiments: ["rank32_confirmation", "dora_rank8_secondary"]
        )
    }

    public var excludesEmbeddingTargets: Bool {
        !keys.contains { $0.localizedCaseInsensitiveContains("embed") }
    }

    public var lrScheduleStepUnit: String {
        "optimizer_update"
    }

    public var optimizerUpdateSteps: Int {
        max(1, scheduleDecaySteps / max(1, gradAccumulationSteps))
    }

    public var renderedScheduleDecaySteps: Int {
        optimizerUpdateSteps
    }

    public var renderedWarmupSteps: Int {
        max(1, Int((Double(optimizerUpdateSteps) * warmupFraction).rounded()))
    }

    public var renderYAML: String {
        """
        # mlx-lm lr_schedule steps are optimizer updates, not micro-iterations.
        # training_iterations: \(scheduleDecaySteps)
        # grad_accumulation_steps: \(gradAccumulationSteps)
        # optimizer_update_steps: \(optimizerUpdateSteps)
        model: '\(model.replacingOccurrences(of: "'", with: "''"))'
        fine_tune_type: \(fineTuneType)
        num_layers: \(numLayers)
        batch_size: \(batchSize)
        grad_accumulation_steps: \(gradAccumulationSteps)
        optimizer: \(optimizer)
        optimizer_config:
          adamw:
            weight_decay: \(weightDecay)
        seed: \(seed)
        grad_clip_norm: \(gradClipNorm)
        training_loop: \(trainingLoop)
        learning_rate: \(learningRate)
        lr_schedule:
          name: cosine_decay
          arguments:
            - \(learningRate)
            - \(renderedScheduleDecaySteps)
            - \(learningRate / 10)
          warmup: \(renderedWarmupSteps)
          warmup_init: 0.0
        max_seq_length: \(maxSeqLength)
        lora_parameters:
          rank: \(rank)
          dropout: \(dropout)
          scale: \(scale)
          keys:
        \(keys.map { "    - \($0)" }.joined(separator: "\n"))
        """
    }
}

public struct C5GeneratorSourceReceipt: Codable, Equatable, Sendable {
    public var id: String
    public var role: String
    public var configured: Bool
    public var emittedRows: Int

    enum CodingKeys: String, CodingKey {
        case id
        case role
        case configured
        case emittedRows = "emitted_rows"
    }
}

public struct C5GeneratorOrchestrationReceipt: Codable, Equatable, Sendable {
    public var status: String
    public var augmentationEngine: String
    public var cloudAPIUsedForTrainableV0: Bool
    public var labelAuthority: String
    public var redlinePromptInput: String
    public var perSampleFieldsPresent: [String]
    public var sources: [C5GeneratorSourceReceipt]
    public var failureReceipt: [String]

    enum CodingKeys: String, CodingKey {
        case status
        case augmentationEngine = "augmentation_engine"
        case cloudAPIUsedForTrainableV0 = "cloud_api_used_for_trainable_v0"
        case labelAuthority = "label_authority"
        case redlinePromptInput = "redline_prompt_input"
        case perSampleFieldsPresent = "per_sample_fields_present"
        case sources
        case failureReceipt = "failure_receipt"
    }
}

public struct C5ValidatorSummary: Codable, Equatable, Sendable {
    public var layer1RuleStatus: String
    public var layer2SemanticStatus: String
    public var stopOnRuleFail: Bool
    public var judgeModelDistinctPerSample: Bool
    public var offsetCorrectnessStatus: String
    public var redactionStatus: String
    public var parentInTrainStatus: String
    public var failureReceipt: [String]

    enum CodingKeys: String, CodingKey {
        case layer1RuleStatus = "layer1_rule_status"
        case layer2SemanticStatus = "layer2_semantic_status"
        case stopOnRuleFail = "stop_on_rule_fail"
        case judgeModelDistinctPerSample = "judge_model_distinct_per_sample"
        case offsetCorrectnessStatus = "offset_correctness_status"
        case redactionStatus = "redaction_status"
        case parentInTrainStatus = "parent_in_train_status"
        case failureReceipt = "failure_receipt"
    }
}

public struct C5LineageSummary: Codable, Equatable, Sendable {
    public var candidateSemanticReassignmentStatus: String
    public var seedParentSemanticIDRole: String
    public var inheritedCandidateParentCount: Int
    public var compareAgainst: [String]
    public var protectedCollisionStatus: String
    public var actionOnUncertain: String
    public var failureReceipt: [String]

    enum CodingKeys: String, CodingKey {
        case candidateSemanticReassignmentStatus = "candidate_semantic_reassignment_status"
        case seedParentSemanticIDRole = "seed_parent_semantic_id_role"
        case inheritedCandidateParentCount = "inherited_candidate_parent_count"
        case compareAgainst = "compare_against"
        case protectedCollisionStatus = "protected_collision_status"
        case actionOnUncertain = "action_on_uncertain"
        case failureReceipt = "failure_receipt"
    }
}

public struct C5GeneralizationAxis: Codable, Equatable, Sendable {
    public var n: Int
    public var toolCallExact: Double
    public var IrrelAcc: Double
    public var hardGatePassRate: Double
    public var deltaVsBase: Double
    public var caseDigest: String

    enum CodingKeys: String, CodingKey {
        case n
        case toolCallExact = "ToolCallExact"
        case IrrelAcc
        case hardGatePassRate = "hard_gate_pass_rate"
        case deltaVsBase = "delta_vs_base"
        case caseDigest = "case_digest"
    }
}

public struct C5GeneralizationDiagnostic: Codable, Equatable, Sendable {
    public var inDistProbe: C5GeneralizationAxis?
    public var heldout: C5GeneralizationAxis?
    public var oodProbe: C5GeneralizationAxis?
    public var trainHeldoutGapPP: Double?
    public var trainOODGapPP: Double?
    public var parentOverlap: Int
    public var leakageViolations: Int
    public var diagnosticVerdict: String

    enum CodingKeys: String, CodingKey {
        case inDistProbe = "in_dist_probe"
        case heldout
        case oodProbe = "ood_probe"
        case trainHeldoutGapPP = "train_heldout_gap_pp"
        case trainOODGapPP = "train_ood_gap_pp"
        case parentOverlap = "parent_overlap"
        case leakageViolations = "leakage_violations"
        case diagnosticVerdict = "diagnostic_verdict"
    }

    public init(
        inDistProbe: C5GeneralizationAxis?,
        heldout: C5GeneralizationAxis?,
        oodProbe: C5GeneralizationAxis?,
        trainHeldoutGapPP: Double?,
        trainOODGapPP: Double?,
        parentOverlap: Int,
        leakageViolations: Int,
        diagnosticVerdict: String? = nil
    ) {
        self.inDistProbe = inDistProbe
        self.heldout = heldout
        self.oodProbe = oodProbe
        self.trainHeldoutGapPP = trainHeldoutGapPP
        self.trainOODGapPP = trainOODGapPP
        self.parentOverlap = parentOverlap
        self.leakageViolations = leakageViolations
        self.diagnosticVerdict = diagnosticVerdict ?? Self.evaluate(
            inDistProbe: inDistProbe,
            heldout: heldout,
            oodProbe: oodProbe,
            trainHeldoutGapPP: trainHeldoutGapPP,
            trainOODGapPP: trainOODGapPP,
            parentOverlap: parentOverlap,
            leakageViolations: leakageViolations
        )
    }

    public static func evaluate(
        inDistProbe: C5GeneralizationAxis?,
        heldout: C5GeneralizationAxis?,
        oodProbe: C5GeneralizationAxis?,
        trainHeldoutGapPP: Double?,
        trainOODGapPP: Double?,
        parentOverlap: Int,
        leakageViolations: Int
    ) -> String {
        if leakageViolations > 0 || parentOverlap > 0 {
            return "blocked_leakage"
        }
        if inDistProbe == nil || heldout == nil || oodProbe == nil {
            return "blocked_missing"
        }
        if (trainHeldoutGapPP ?? 0) > 20 || (trainOODGapPP ?? 0) > 25 {
            return "warn"
        }
        return "clear"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inDistProbe, forKey: .inDistProbe)
        try container.encode(heldout, forKey: .heldout)
        try container.encode(oodProbe, forKey: .oodProbe)
        try container.encode(trainHeldoutGapPP, forKey: .trainHeldoutGapPP)
        try container.encode(trainOODGapPP, forKey: .trainOODGapPP)
        try container.encode(parentOverlap, forKey: .parentOverlap)
        try container.encode(leakageViolations, forKey: .leakageViolations)
        try container.encode(diagnosticVerdict, forKey: .diagnosticVerdict)
    }
}

public struct C5FuseParityInput: Equatable, Sendable {
    public var dynamicToolCallExact: Double
    public var fusedToolCallExact: Double
    public var dynamicIrrelAcc: Double?
    public var fusedIrrelAcc: Double?
    public var mustPassRegressionCount: Int
    public var quantizedParseFailures: Int
    public var negativeFalseCallDeltaPP: Double
    public var quantizedIrrelAcc: Double
    public var c6ApprovedThreshold: Double

    public init(
        dynamicToolCallExact: Double,
        fusedToolCallExact: Double,
        dynamicIrrelAcc: Double? = nil,
        fusedIrrelAcc: Double? = nil,
        mustPassRegressionCount: Int = 0,
        quantizedParseFailures: Int = 0,
        negativeFalseCallDeltaPP: Double = 0,
        quantizedIrrelAcc: Double = 1,
        c6ApprovedThreshold: Double = 0.9
    ) {
        self.dynamicToolCallExact = dynamicToolCallExact
        self.fusedToolCallExact = fusedToolCallExact
        self.dynamicIrrelAcc = dynamicIrrelAcc
        self.fusedIrrelAcc = fusedIrrelAcc
        self.mustPassRegressionCount = mustPassRegressionCount
        self.quantizedParseFailures = quantizedParseFailures
        self.negativeFalseCallDeltaPP = negativeFalseCallDeltaPP
        self.quantizedIrrelAcc = quantizedIrrelAcc
        self.c6ApprovedThreshold = c6ApprovedThreshold
    }
}

public struct C5FuseParityGate: Codable, Equatable, Sendable {
    public var status: String
    public var toolCallExactDeltaPP: Double
    public var irrelAccDeltaPP: Double?
    public var dynamicIrrelAcc: Double?
    public var fusedIrrelAcc: Double?
    public var mustPassRegressionCount: Int
    public var quantizedParseFailures: Int
    public var negativeFalseCallDeltaPP: Double
    public var quantizedIrrelAcc: Double
    public var c6ApprovedThreshold: Double
    public var failureReceipt: [String]

    enum CodingKeys: String, CodingKey {
        case status
        case toolCallExactDeltaPP = "toolcall_exact_delta_pp"
        case irrelAccDeltaPP = "IrrelAcc_delta_pp"
        case dynamicIrrelAcc = "dynamic_IrrelAcc"
        case fusedIrrelAcc = "fused_IrrelAcc"
        case mustPassRegressionCount = "must_pass_regression_count"
        case quantizedParseFailures = "quantized_parse_failures"
        case negativeFalseCallDeltaPP = "negative_false_call_delta_pp"
        case quantizedIrrelAcc = "quantized_IrrelAcc"
        case c6ApprovedThreshold = "c6_approved_threshold"
        case failureReceipt = "failure_receipt"
    }

    public static func evaluate(_ input: C5FuseParityInput, tolerancePP: Double = 2) -> C5FuseParityGate {
        let delta = abs(input.dynamicToolCallExact - input.fusedToolCallExact) * 100
        let irrelDelta = input.dynamicIrrelAcc.flatMap { dynamic in
            input.fusedIrrelAcc.map { fused in abs(dynamic - fused) * 100 }
        }
        var failures: [String] = []
        if delta > tolerancePP {
            failures.append("toolcall_exact_delta_exceeds_\(tolerancePP)pp")
        }
        if let irrelDelta {
            if irrelDelta > tolerancePP {
                failures.append("IrrelAcc_delta_exceeds_\(tolerancePP)pp")
            }
        } else {
            failures.append("IrrelAcc_delta_missing_dynamic_or_fused")
        }
        if input.mustPassRegressionCount > 0 {
            failures.append("must_pass_regression")
        }
        if input.quantizedParseFailures > 0 {
            failures.append("quantized_parse_failures")
        }
        if abs(input.negativeFalseCallDeltaPP) > tolerancePP {
            failures.append("negative_false_call_delta_exceeds_\(tolerancePP)pp")
        }
        if input.quantizedIrrelAcc < input.c6ApprovedThreshold {
            failures.append("quantized_IrrelAcc_below_C6_threshold")
        }
        return C5FuseParityGate(
            status: failures.isEmpty ? "pass" : "fail",
            toolCallExactDeltaPP: delta,
            irrelAccDeltaPP: irrelDelta,
            dynamicIrrelAcc: input.dynamicIrrelAcc,
            fusedIrrelAcc: input.fusedIrrelAcc,
            mustPassRegressionCount: input.mustPassRegressionCount,
            quantizedParseFailures: input.quantizedParseFailures,
            negativeFalseCallDeltaPP: input.negativeFalseCallDeltaPP,
            quantizedIrrelAcc: input.quantizedIrrelAcc,
            c6ApprovedThreshold: input.c6ApprovedThreshold,
            failureReceipt: failures
        )
    }
}

public struct C5EndpointTokenizerParityGate: Codable, Equatable, Sendable {
    public var status: String
    public var endpointRenderSource: String
    public var trainingRenderDigest: String
    public var endpointRenderDigest: String
    public var byteParity: Bool
    public var firstMismatchByte: Int?
    public var trainingByteCount: Int
    public var endpointByteCount: Int
    public var thinkBlockParity: Bool
    public var failureReceipt: [String]

    enum CodingKeys: String, CodingKey {
        case status
        case endpointRenderSource = "endpoint_render_source"
        case trainingRenderDigest = "training_render_digest"
        case endpointRenderDigest = "endpoint_render_digest"
        case byteParity = "byte_parity"
        case firstMismatchByte = "first_mismatch_byte"
        case trainingByteCount = "training_byte_count"
        case endpointByteCount = "endpoint_byte_count"
        case thinkBlockParity = "think_block_parity"
        case failureReceipt = "failure_receipt"
    }

    public static func blockedMissingEndpointRender(trainingRendered: String? = nil) -> C5EndpointTokenizerParityGate {
        evaluate(
            trainingRendered: trainingRendered,
            endpointRendered: nil,
            endpointRenderSource: "missing"
        )
    }

    public static func evaluate(
        trainingRendered: String?,
        endpointRendered: String?,
        endpointRenderSource: String
    ) -> C5EndpointTokenizerParityGate {
        let allowedSources: Set<String> = ["patched_tokenizer", "explicit_enable_thinking_false"]
        let trainingBytes = trainingRendered.map { Array($0.utf8) } ?? []
        let endpointBytes = endpointRendered.map { Array($0.utf8) } ?? []
        let byteParity = trainingRendered != nil && endpointRendered != nil && trainingBytes == endpointBytes
        let firstMismatch = firstMismatchByte(trainingBytes, endpointBytes)
        let thinkBlockParity = thinkSignature(trainingRendered) == thinkSignature(endpointRendered)
        var failures: [String] = []
        if trainingRendered == nil {
            failures.append("training_render_bytes_missing")
        }
        if endpointRendered == nil {
            failures.append("endpoint_render_bytes_missing")
        }
        if !allowedSources.contains(endpointRenderSource) {
            failures.append("endpoint_render_source_missing_patched_tokenizer_or_explicit_enable_thinking_false")
        }
        if trainingRendered != nil && endpointRendered != nil && !byteParity {
            if let firstMismatch {
                failures.append("rendered_byte_parity_mismatch_first_byte_\(firstMismatch)")
            } else {
                failures.append("rendered_byte_parity_mismatch")
            }
        }
        if !thinkBlockParity {
            failures.append("think_marker_or_empty_block_parity_mismatch")
        }
        let status: String
        if failures.isEmpty {
            status = "pass"
        } else if trainingRendered == nil || endpointRendered == nil {
            status = "blocked"
        } else {
            status = "fail"
        }
        return C5EndpointTokenizerParityGate(
            status: status,
            endpointRenderSource: endpointRenderSource,
            trainingRenderDigest: trainingRendered.map { C6Hash.sha256Hex(Data($0.utf8)) } ?? "",
            endpointRenderDigest: endpointRendered.map { C6Hash.sha256Hex(Data($0.utf8)) } ?? "",
            byteParity: byteParity,
            firstMismatchByte: firstMismatch,
            trainingByteCount: trainingBytes.count,
            endpointByteCount: endpointBytes.count,
            thinkBlockParity: thinkBlockParity,
            failureReceipt: failures
        )
    }

    private static func firstMismatchByte(_ lhs: [UInt8], _ rhs: [UInt8]) -> Int? {
        let sharedCount = min(lhs.count, rhs.count)
        for index in 0..<sharedCount where lhs[index] != rhs[index] {
            return index
        }
        return lhs.count == rhs.count ? nil : sharedCount
    }

    private static func thinkSignature(_ rendered: String?) -> String {
        guard let rendered else {
            return "missing"
        }
        let hasThinkOpen = rendered.contains("<think>")
        let hasThinkClose = rendered.contains("</think>")
        let hasEmptyThink = rendered.contains("<think>\n\n</think>")
        return "open=\(hasThinkOpen);close=\(hasThinkClose);empty=\(hasEmptyThink)"
    }
}

public struct C5TrainingReceipt: Codable, Equatable, Sendable {
    public var receiptVersion: String
    public var generatedAt: String
    public var status: String
    public var sourceRefs: [String]
    public var discoveryFindings: [String]
    public var frameSurfaced: [String]
    public var physicalFields: [String]
    public var failureReceipt: [String]
    public var rowCount: Int
    public var trainEligibleCount: Int
    public var routeTierCounts: [String: Int]
    public var rehearsalRatio: Double
    public var refusalRatioTarget: Double
    public var refusalRatioHardCap: Double
    public var refusalRatioObserved: Double
    public var noCallCounterfactualCount: Int
    public var promptDistractorCount: Int
    public var devSelectionCount: Int
    public var smokeChainRecordCount: Int
    public var maskingStageCounts: [String: Int]
    public var maskingCoverage: C5MaskingCoverage
    public var acceptanceStage: C5AcceptanceStage
    public var offsetFixture: C5MaskOffsetFixture
    public var mlxConfig: C5MLXLoRAConfig
    public var generatorOrchestration: C5GeneratorOrchestrationReceipt
    public var validatorSummary: C5ValidatorSummary
    public var lineageSummary: C5LineageSummary
    public var generalizationDiagnostic: C5GeneralizationDiagnostic
    public var fuseParityGate: C5FuseParityGate
    public var endpointTokenizerParity: C5EndpointTokenizerParityGate
    public var dataGateReceipt: C5DataGateReceipt
    public var environment: C5TrainingEnvironment
    public var trainingCurve: C5TrainingCurveReceipt

    enum CodingKeys: String, CodingKey {
        case receiptVersion = "receipt_version"
        case generatedAt = "generated_at"
        case status
        case sourceRefs = "source_refs"
        case discoveryFindings = "discovery_findings"
        case frameSurfaced = "frame_surfaced"
        case physicalFields = "physical_fields"
        case failureReceipt = "failure_receipt"
        case rowCount = "row_count"
        case trainEligibleCount = "train_eligible_count"
        case routeTierCounts = "route_tier_counts"
        case rehearsalRatio = "rehearsal_ratio"
        case refusalRatioTarget = "refusal_ratio_target"
        case refusalRatioHardCap = "refusal_ratio_hard_cap"
        case refusalRatioObserved = "refusal_ratio_observed"
        case noCallCounterfactualCount = "no_call_counterfactual_count"
        case promptDistractorCount = "prompt_distractor_count"
        case devSelectionCount = "dev_selection_count"
        case smokeChainRecordCount = "smoke_chain_record_count"
        case maskingStageCounts = "masking_stage_counts"
        case maskingCoverage = "masking_coverage"
        case acceptanceStage = "acceptance_stage"
        case offsetFixture = "offset_fixture"
        case mlxConfig = "mlx_config"
        case generatorOrchestration = "generator_orchestration"
        case validatorSummary = "validator_summary"
        case lineageSummary = "lineage_summary"
        case generalizationDiagnostic = "generalization_diagnostic"
        case fuseParityGate = "fuse_parity_gate"
        case endpointTokenizerParity = "endpoint_tokenizer_parity"
        case dataGateReceipt = "data_gate_receipt"
        case environment
        case trainingCurve = "training_curve"
    }
}

public struct C5PreparedTrainingDataset: Equatable, Sendable {
    public var samples: [C5TrainingSample]
    public var receipt: C5TrainingReceipt
}

public enum C5TrainingRenderer {
    public static func renderToolCall(_ call: C5TrainingToolCall) -> String {
        let payload = C5CanonicalJSONObject.render([
            "name": .string(call.name),
            "arguments": .object(call.arguments)
        ])
        return "<tool_call>\(payload)</tool_call>"
    }

    public static func renderUserUtterance(seed: C5SemanticSeed, variant: Int, valueText: String, slotAssignments: [String: String]) -> String {
        let slotText: String
        if seed.slotKeys.isEmpty {
            slotText = "no_slots"
        } else {
            slotText = seed.slotKeys.map { key in
                guard let value = slotAssignments[key], !value.isEmpty else {
                    return key
                }
                return "\(key):\(value)"
            }.joined(separator: "+")
        }
        let suffixes = [
            "请按这个语义执行",
            "客户现场换一种说法",
            "用自然中文表达也要落到同一动作",
            "别输出解释只给工具调用",
            "带一点口语但保持语义不变",
            "把槽位和值对齐",
            "按 mock 车控协议处理",
            "这是离线演示的单跳请求"
        ]
        let suffix = suffixes[variant % suffixes.count]
        if valueText.isEmpty {
            return "device=\(seed.device); primitive=\(seed.actionPrimitive); slots=\(slotText); \(suffix)"
        }
        return "device=\(seed.device); primitive=\(seed.actionPrimitive); value=\(valueText); slots=\(slotText); \(suffix)"
    }

    public static func candidateParentSemanticID(userUtterance: String, renderedToolCall: String) -> String {
        let normalizedUtterance = userUtterance
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: "")
        let digestInput = [
            "utterance=\(normalizedUtterance)",
            "tool_call=\(C6Hash.sha256Hex(Data(renderedToolCall.utf8)))"
        ].joined(separator: "::")
        let digest = C6Hash.sha256Hex(Data(digestInput.utf8)).prefix(16)
        return "cand_sem_\(digest)"
    }

    public static func toolCallArguments(seed: C5SemanticSeed, value: C5ContractValue, slotAssignments: [String: String]) -> [String: JSONValue] {
        var args: [String: JSONValue] = [
            "device": .string(seed.device),
            "action_primitive": .string(seed.actionPrimitive),
            "value.ref": .string(value.ref),
            "value.direct": .string(value.direct),
            "value.offset": .string(value.offset),
            "value.type": .string(value.type),
            "contract_row_id": .string(seed.contractRowID),
            "canonical_semantic_id": .string(seed.canonicalSemanticID)
        ]
        for key in seed.slotKeys {
            if key == "device" || key == "action_primitive" {
                continue
            }
            args[key] = .string(slotAssignments[key, default: fallbackSlotValue(key: key, seed: seed, variant: 0)])
        }
        return args
    }

    public static func slotAssignments(seed: C5SemanticSeed, variant: Int, value: C5ContractValue) -> [String: String] {
        var assignments: [String: String] = [:]
        let rangeMap = parseRange(seed.range)
        for key in seed.slotKeys {
            if key == "device" {
                assignments[key] = seed.device
            } else if key == "action_primitive" {
                assignments[key] = seed.actionPrimitive
            } else if let fixed = fixedSemanticSlotValue(seed.semanticSlots[key]) {
                assignments[key] = fixed
            } else if let values = rangeMap[key], !values.isEmpty {
                assignments[key] = values[variant % values.count]
            } else {
                assignments[key] = fallbackSlotValue(key: key, seed: seed, variant: variant, value: value)
            }
        }
        return assignments
    }

    private static func parseRange(_ range: String) -> [String: [String]] {
        var parsed: [String: [String]] = [:]
        for rawLine in range.split(whereSeparator: \.isNewline) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let separator = line.firstIndex(of: "=") else {
                continue
            }
            let key = String(line[..<separator]).trimmingCharacters(in: .whitespacesAndNewlines)
            let valuesText = String(line[line.index(after: separator)...])
            let values = valuesText
                .split(separator: "|")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && !isPlaceholderLiteral($0) }
            if !key.isEmpty && !values.isEmpty {
                parsed[key] = values
            }
        }
        return parsed
    }

    private static func fixedSemanticSlotValue(_ value: JSONValue?) -> String? {
        guard case .string(let text) = value else {
            return nil
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isPlaceholderLiteral(trimmed) else {
            return nil
        }
        return trimmed
    }

    private static func isPlaceholderLiteral(_ value: String) -> Bool {
        value.hasPrefix("<") && value.hasSuffix(">")
    }

    private static func fallbackSlotValue(key: String, seed: C5SemanticSeed, variant: Int, value: C5ContractValue = C5ContractValue()) -> String {
        let normalized = key.lowercased()
        let candidates: [String]
        if normalized.contains("position") || normalized.contains("direction") {
            candidates = ["主驾", "副驾", "左前", "右前", "后排", "全车"]
        } else if normalized.contains("color") {
            candidates = ["蓝色", "暖白", "红色", "紫色"]
        } else if normalized.contains("mode") {
            candidates = ["自动", "强力", "低档", "高档"]
        } else if normalized.contains("name") {
            candidates = ["阅读灯", "氛围灯", "车窗", seed.device]
        } else if normalized.contains("temperature") || normalized.contains("temp") {
            candidates = ["22", "24", "26", "20"]
        } else if normalized.contains("percent") {
            candidates = ["25", "50", "75", "100"]
        } else if normalized.contains("action") {
            candidates = [seed.actionPrimitive]
        } else if !value.offset.isEmpty && !value.offset.hasPrefix("<") && !value.offset.hasSuffix(">") {
            candidates = [value.offset]
        } else {
            candidates = ["\(key)_value_\((variant % 4) + 1)"]
        }
        return candidates[variant % candidates.count]
    }

    public static func augmentValue(seed: C5SemanticSeed, variant: Int) -> C5ValueAugmentation {
        guard !seed.value.type.isEmpty else {
            return C5ValueAugmentation(value: seed.value, utteranceValueText: "", didAugment: false)
        }
        var value = seed.value
        switch seed.valueStrategy {
        case .slotExtract:
            let choices = spotChoices(for: seed.value.offset)
            let selected = choices[variant % choices.count]
            value.offset = selected
            return C5ValueAugmentation(value: value, utteranceValueText: "\(value.ref)/\(value.direct)/\(selected)/\(value.type)", didAugment: true)
        case .percentExtract:
            let choices = ["10", "25", "50", "75", "100"]
            let selected = choices[variant % choices.count]
            value.offset = selected
            return C5ValueAugmentation(value: value, utteranceValueText: "\(value.ref)/\(value.direct)/\(selected)%/\(value.type)", didAugment: true)
        case .expInverseNormalize:
            let feelings: [String]
            switch seed.value.offset.uppercased() {
            case "LITTLE":
                feelings = ["稍微一点", "轻微", "小幅"]
            case "MIDDLE", "MEDIUM":
                feelings = ["适中", "正常幅度", "中等"]
            case "MAX", "MAXIMUM":
                feelings = ["调到最大", "拉满", "最强"]
            default:
                feelings = ["舒服一点", "明显一点", "按感觉调"]
            }
            let selected = feelings[variant % feelings.count]
            return C5ValueAugmentation(value: value, utteranceValueText: "\(selected)->\(value.ref)/\(value.direct)/\(value.offset)/\(value.type)", didAugment: true)
        }
    }

    public static func distractorToolSchemas(variant: Int) -> (ids: [String], schemas: [[String: JSONValue]]) {
        let suffix = String(format: "%02d", variant % 17)
        let names = ["irrelevant_navigation_\(suffix)", "irrelevant_music_\(suffix)"]
        let schemas = names.map { name in
            [
                "type": JSONValue.string("function"),
                "function": .object([
                    "name": .string(name),
                    "description": .string("Distractor tool unavailable to MAformac vehicle-control labels."),
                    "parameters": .object([
                        "type": .string("object"),
                        "additionalProperties": .bool(false),
                        "properties": .object([
                            "unused_argument_\(suffix)": .object(["type": .string("string")])
                        ])
                    ])
                ])
            ]
        }
        return (names, schemas)
    }

    private static func spotChoices(for offset: String) -> [String] {
        if offset.contains("温") {
            return ["20", "22", "24", "26"]
        }
        if offset.contains("百分") {
            return ["25", "50", "75"]
        }
        if offset.contains("档") {
            return ["1", "3", "5", "7"]
        }
        return ["1", "2", "3", "4"]
    }

    public static var toolCallFrameToolSchema: [[String: JSONValue]] {
        [[
            "type": .string("function"),
            "function": .object([
                "name": .string("tool_call_frame"),
                "description": .string("Emit exactly one MAformac single-hop ToolCallFrame for offline mock vehicle control."),
                "parameters": .object([
                    "type": .string("object"),
                    "additionalProperties": .bool(true),
                    "required": .array([.string("device"), .string("action_primitive")]),
                    "properties": .object([
                        "device": .object(["type": .string("string")]),
                        "action_primitive": .object(["type": .string("string")]),
                        "value.ref": .object(["type": .string("string")]),
                        "value.direct": .object(["type": .string("string")]),
                        "value.offset": .object(["type": .string("string")]),
                        "value.type": .object(["type": .string("string")])
                    ])
                ])
            ])
        ]]
    }
}

public struct C5TrainingDatasetBuilder: Sendable {
    public init() {}

    public func build(
        seeds: [C5SemanticSeed],
        c6Cases: [C6BenchCase],
        dataGateContext: C5DataGateRunContext,
        options: C5TrainingBuildOptions = C5TrainingBuildOptions()
    ) -> C5PreparedTrainingDataset {
        let positiveSamples = buildPositiveSamples(seeds: seeds, options: options)
        let positiveWithDev = assignDevSelection(samples: positiveSamples, count: options.devSelectionRows)
        let noCalls = buildNoCallSamples(from: positiveWithDev.filter { $0.split == "train" }, options: options)
        let samples = positiveWithDev + noCalls
        let dataGateReceipt = C5DataGateValidator().receipt(
            candidates: samples.map(\.dataGateCandidate),
            c6Cases: c6Cases,
            context: dataGateContext
        )
        let routeTierCounts = Dictionary(grouping: samples.filter { $0.split == "train" && !$0.expectedToolCalls.isEmpty }, by: { $0.routeTier.rawValue }).mapValues(\.count)
        let maskingStageCounts = Dictionary(grouping: samples, by: { $0.maskingStage.rawValue }).mapValues(\.count)
        let trainActionCount = samples.filter { $0.split == "train" && !$0.expectedToolCalls.isEmpty }.count
        let trainNoCallCount = samples.filter { $0.split == "train" && $0.expectedToolCalls.isEmpty }.count
        let trainEligibleCount = samples.filter(\.trainEligible).count
        let rehearsalRatio = trainActionCount == 0 ? 0 : Double(routeTierCounts[C5RouteTier.ruleL1.rawValue, default: 0]) / Double(trainActionCount)
        let refusalRatio = (trainActionCount + trainNoCallCount) == 0 ? 0 : Double(trainNoCallCount) / Double(trainActionCount + trainNoCallCount)
        let coverage = C5MaskingCoverage(
            functionName: samples.contains { $0.masking.functionName },
            argumentName: samples.contains { $0.masking.argumentName },
            argumentValue: samples.contains { $0.masking.argumentValue },
            trainOnTurn: samples.contains { $0.masking.trainOnTurn }
        )
        let offsetFixture = C5MaskOffsetFixture.validate(
            samples: samples,
            usesTrainingTokenizerPatch: options.usesTrainingTokenizerPatch,
            tokenArtifact: options.offsetTokenArtifact,
            expectedTokenizerModelID: options.modelOverride ?? C5MLXLoRAConfig.rank16Mainline().model
        )
        var hardFailures: [String] = []
        if dataGateReceipt.status == "blocked" {
            hardFailures.append("data_gate_blocked")
        }
        if refusalRatio > options.refusalRatioHardCap {
            hardFailures.append("refusal_ratio_cap_exceeded")
        }
        if offsetFixture.status != "pass" && options.maskingStage != .smokeOnly {
            hardFailures.append("offset_fixture_failed")
        }
        if !(0.05...0.10).contains(rehearsalRatio) {
            hardFailures.append("rule_l1_rehearsal_ratio_outside_5_10_percent")
        }
        let generatorOrchestration = buildGeneratorOrchestrationReceipt(samples: samples)
        let validatorSummary = buildValidatorSummary(dataGateReceipt: dataGateReceipt, offsetFixture: offsetFixture, samples: samples)
        let lineageSummary = buildLineageSummary(samples: samples)
        var formalStep2Failures = generatorOrchestration.failureReceipt + validatorSummary.failureReceipt + lineageSummary.failureReceipt
        if !coverage.functionName || !coverage.argumentName || !coverage.argumentValue {
            formalStep2Failures.append("masking_complete_augmentation_not_implemented")
        }
        let receiptStatus: String
        if !hardFailures.isEmpty {
            receiptStatus = "blocked"
        } else if options.maskingStage == .smokeOnly {
            receiptStatus = "smoke_only_ready"
        } else if formalStep2Failures.isEmpty {
            receiptStatus = "trainable_v0_ready"
        } else {
            receiptStatus = "step2_dry_run_ready"
        }
        let acceptanceStage: C5AcceptanceStage = options.maskingStage == .smokeOnly ? .trainHealth : .trainableV0
        let smokeChainRecordCount = options.maskingStage == .smokeOnly
            ? samples.filter { $0.split == "train" }.count
            : 0
        let diagnostic = C5GeneralizationDiagnostic(
            inDistProbe: nil,
            heldout: nil,
            oodProbe: nil,
            trainHeldoutGapPP: nil,
            trainOODGapPP: nil,
            parentOverlap: dataGateReceipt.trainParentSemanticOverlap,
            leakageViolations: dataGateReceipt.mustNotTrainViolations
        )
        let parity = C5FuseParityGate.evaluate(C5FuseParityInput(dynamicToolCallExact: 0, fusedToolCallExact: 0, quantizedIrrelAcc: 0))
        let receipt = C5TrainingReceipt(
            receiptVersion: "c5-lora-training.v1",
            generatedAt: options.generatedAt,
            status: receiptStatus,
            sourceRefs: [
                "docs/p1c-training-grill-decisions.md:103-408",
                "docs/research/2026-06-21-c5-generator-selection-probe.md:37-54",
                "openspec/changes/define-lora-training/specs/lora-training/spec.md:3-164",
                "openspec/changes/define-lora-data-gate/specs/lora-data-gate/spec.md:3-105",
                "Core/Bench/C5DataGate.swift:242-406",
                "mlx_lm/tuner/datasets.py:57-75",
                "mlx_lm/tuner/trainer.py:75-88"
            ],
            discoveryFindings: [
                "route_tier is derived from normalized C1 fc_flags, not execution-tier metadata",
                "stock mlx-lm training has no enable_thinking injection point in tuner datasets path",
                "assistant content uses double-newline prefix so stock mask offset trains the tool_call span instead of swallowing its first bytes"
            ],
            frameSurfaced: [
                "dev_selection is a checkpoint-selection split, not heldout or release gold",
                "deterministic_semantic_protocol_v1 is a Step2 dry-run source only; it cannot satisfy Q13 multi-source cloud generation or Q14 semantic judge",
                "C6 release gate remains final-only; this receipt cannot claim model-quality V-PASS without a real C6 diff",
                "Mac behavior parity and true-device candidate V-PASS are reported separately",
                "endpoint tokenizer byte parity is a candidate gate; training-tokenizer patch alone does not prove mlx-swift render parity"
            ],
            physicalFields: [
                "route_tier_source", "route_tier", "utterance_source", "value_strategy", "masking_stage", "train_eligible",
                "generator_model_id", "generator_call_id", "semantic_judge_model_id", "semantic_judge_call_id", "prompt_hash",
                "augmentation_parent_id", "lineage_group_id", "split_origin", "candidate_dedupe_group_id", "expected_tool_call_signature",
                "counterfactual_pair_id", "acceptance_stage", "generator_orchestration", "validator_summary", "lineage_summary",
                "generalization_diagnostic", "fuse_parity_gate", "endpoint_tokenizer_parity"
            ],
            failureReceipt: hardFailures + formalStep2Failures,
            rowCount: samples.count,
            trainEligibleCount: trainEligibleCount,
            routeTierCounts: routeTierCounts,
            rehearsalRatio: rehearsalRatio,
            refusalRatioTarget: options.refusalRatioTarget,
            refusalRatioHardCap: options.refusalRatioHardCap,
            refusalRatioObserved: refusalRatio,
            noCallCounterfactualCount: trainNoCallCount,
            promptDistractorCount: samples.reduce(0) { $0 + $1.promptDistractorToolIDs.count },
            devSelectionCount: samples.filter { $0.split == "dev_selection" }.count,
            smokeChainRecordCount: smokeChainRecordCount,
            maskingStageCounts: maskingStageCounts,
            maskingCoverage: coverage,
            acceptanceStage: acceptanceStage,
            offsetFixture: offsetFixture,
            mlxConfig: .rank16Mainline(model: options.modelOverride ?? "mlx-community/Qwen3-1.7B-4bit"),
            generatorOrchestration: generatorOrchestration,
            validatorSummary: validatorSummary,
            lineageSummary: lineageSummary,
            generalizationDiagnostic: diagnostic,
            fuseParityGate: parity,
            endpointTokenizerParity: options.endpointTokenizerParity,
            dataGateReceipt: dataGateReceipt,
            environment: options.environment,
            trainingCurve: options.trainingCurve
        )
        return C5PreparedTrainingDataset(samples: samples, receipt: receipt)
    }

    private func buildGeneratorOrchestrationReceipt(samples: [C5TrainingSample]) -> C5GeneratorOrchestrationReceipt {
        let sourceCounts = Dictionary(grouping: samples.filter { !$0.expectedToolCalls.isEmpty }, by: \.generatorModelID).mapValues(\.count)
        let cloudSourceIDs: Set<String> = ["claude", "hermes_glm", "hermes_ark_standard", "hermes_gpt_5_5", "gptpro", "gpt_5", "codex"]
        let cloudRows = sourceCounts
            .filter { cloudSourceIDs.contains($0.key) }
            .values
            .reduce(0, +)
        var failures: [String] = []
        if cloudRows == 0 {
            failures.append("cloud_multi_source_generator_not_run")
        }
        if sourceCounts.keys.filter({ cloudSourceIDs.contains($0) }).count < 2 {
            failures.append("multi_source_generator_diversity_missing")
        }
        let requiredFieldsPresent = samples.allSatisfy {
            !$0.generatorModelID.isEmpty
                && !$0.generatorCallID.isEmpty
                && !$0.promptHash.isEmpty
        }
        if !requiredFieldsPresent {
            failures.append("generator_trace_fields_missing")
        }
        return C5GeneratorOrchestrationReceipt(
            status: failures.isEmpty ? "pass" : "dry_run_only",
            augmentationEngine: failures.isEmpty ? "hybrid_rule_first_multi_source_cloud_llm_candidate" : "deterministic_semantic_protocol_dry_run",
            cloudAPIUsedForTrainableV0: cloudRows > 0,
            labelAuthority: "deterministic_contract_toolcall",
            redlinePromptInput: "semantic_protocol_only",
            perSampleFieldsPresent: ["generator_model_id", "generator_call_id", "prompt_hash"],
            sources: [
                C5GeneratorSourceReceipt(id: "claude", role: "candidate_utterance_generator", configured: false, emittedRows: sourceCounts["claude", default: 0]),
                C5GeneratorSourceReceipt(id: "hermes_glm", role: "candidate_utterance_generator_or_cross_vendor_judge", configured: false, emittedRows: sourceCounts["hermes_glm", default: 0]),
                C5GeneratorSourceReceipt(id: "hermes_ark_standard", role: "candidate_utterance_generator_or_cross_source_judge", configured: false, emittedRows: sourceCounts["hermes_ark_standard", default: 0]),
                C5GeneratorSourceReceipt(id: "gptpro", role: "hard_sample_generator_or_tiebreaker", configured: false, emittedRows: sourceCounts["gptpro", default: 0]),
                C5GeneratorSourceReceipt(id: "codex", role: "low_weight_candidate_generator", configured: false, emittedRows: sourceCounts["codex", default: 0]),
                C5GeneratorSourceReceipt(id: "deterministic_semantic_protocol_v1", role: "local_dry_run_label_and_format_fixture", configured: true, emittedRows: sourceCounts["deterministic_semantic_protocol_v1", default: 0])
            ],
            failureReceipt: failures
        )
    }

    private func buildValidatorSummary(
        dataGateReceipt: C5DataGateReceipt,
        offsetFixture: C5MaskOffsetFixture,
        samples: [C5TrainingSample]
    ) -> C5ValidatorSummary {
        let layer1Pass = dataGateReceipt.status == "data_gate_ready"
            && dataGateReceipt.redactionStatus == "pass"
            && dataGateReceipt.toolCallFormatFailures.isEmpty
            && dataGateReceipt.mustNotTrainViolations == 0
            && dataGateReceipt.trainParentSemanticOverlap == 0
            && offsetFixture.status == "pass"
        let judgedRows = samples.filter { !$0.expectedToolCalls.isEmpty }
        let judgeDistinct = !judgedRows.isEmpty && judgedRows.allSatisfy {
            !$0.semanticJudgeModelID.isEmpty && $0.semanticJudgeModelID != $0.generatorModelID
        }
        var failures: [String] = []
        if !layer1Pass {
            failures.append("layer1_rule_validator_failed")
        }
        if !judgeDistinct {
            failures.append("cross_vendor_semantic_judge_not_run")
        }
        return C5ValidatorSummary(
            layer1RuleStatus: layer1Pass ? "pass" : "fail",
            layer2SemanticStatus: judgeDistinct ? "pass" : "blocked_missing",
            stopOnRuleFail: true,
            judgeModelDistinctPerSample: judgeDistinct,
            offsetCorrectnessStatus: offsetFixture.status,
            redactionStatus: dataGateReceipt.redactionStatus,
            parentInTrainStatus: dataGateReceipt.trainParentSemanticOverlap == 0 ? "pass" : "fail",
            failureReceipt: failures
        )
    }

    private func buildLineageSummary(samples: [C5TrainingSample]) -> C5LineageSummary {
        let actionSamples = samples.filter { !$0.expectedToolCalls.isEmpty }
        let inheritedCount = actionSamples.filter {
            $0.candidateParentSemanticID == $0.seedParentSemanticID
        }.count
        let protectedCollisionStatus = inheritedCount == 0 ? "pass" : "not_run_inherited_seed_identity"
        var failures: [String] = []
        if inheritedCount > 0 {
            failures.append("candidate_semantic_reassignment_not_run")
        }
        if actionSamples.contains(where: { $0.lineageGroupID.isEmpty || $0.expectedToolCallSignature.isEmpty }) {
            failures.append("lineage_trace_fields_missing")
        }
        return C5LineageSummary(
            candidateSemanticReassignmentStatus: inheritedCount == 0 ? "pass" : "blocked_missing",
            seedParentSemanticIDRole: "lineage_only_not_train_eligibility_authority",
            inheritedCandidateParentCount: inheritedCount,
            compareAgainst: ["heldout", "c6_base", "must_pass"],
            protectedCollisionStatus: protectedCollisionStatus,
            actionOnUncertain: "quarantine_human_review_fail_closed",
            failureReceipt: failures
        )
    }

    private func buildPositiveSamples(seeds: [C5SemanticSeed], options: C5TrainingBuildOptions) -> [C5TrainingSample] {
        let eligible = seeds.filter { !$0.device.isEmpty && !$0.actionPrimitive.isEmpty }
        let grouped = Dictionary(grouping: eligible, by: \.routeTier)
        var generatedByKey: [String: C5GeneratedUtteranceRecord] = [:]
        for record in options.generatedUtteranceRecords {
            let key = generatedRecordKey(contractRowID: record.contractRowID, variant: record.variant)
            if generatedByKey[key] == nil {
                generatedByKey[key] = record
            }
        }
        var usedVariantKeys: Set<String> = []
        let ruleTarget = max(1, Int(Double(options.targetPositiveRows) * 0.075))
        let fcTarget = max(0, options.targetPositiveRows - ruleTarget)
        var samples: [C5TrainingSample] = []
        samples.append(contentsOf: variants(from: grouped[.fcL3, default: []], target: fcTarget / 4, options: options, generatedByKey: generatedByKey, usedVariantKeys: &usedVariantKeys, sampleOffset: samples.count))
        samples.append(contentsOf: variants(from: grouped[.fcL2, default: []], target: max(0, fcTarget - samples.count), options: options, generatedByKey: generatedByKey, usedVariantKeys: &usedVariantKeys, sampleOffset: samples.count))
        samples.append(contentsOf: variants(from: grouped[.ruleL1, default: []], target: ruleTarget, options: options, generatedByKey: generatedByKey, usedVariantKeys: &usedVariantKeys, sampleOffset: samples.count))
        if samples.count < options.targetPositiveRows {
            let remaining = options.targetPositiveRows - samples.count
            samples.append(contentsOf: variants(from: eligible, target: remaining, options: options, generatedByKey: generatedByKey, usedVariantKeys: &usedVariantKeys, sampleOffset: samples.count))
        }
        return Array(samples.prefix(options.targetPositiveRows))
    }

    private func variants(
        from seeds: [C5SemanticSeed],
        target: Int,
        options: C5TrainingBuildOptions,
        generatedByKey: [String: C5GeneratedUtteranceRecord],
        usedVariantKeys: inout Set<String>,
        sampleOffset: Int = 0
    ) -> [C5TrainingSample] {
        guard !seeds.isEmpty, target > 0 else {
            return []
        }
        let sorted = seeds.sorted { $0.contractRowID < $1.contractRowID }
        var result: [C5TrainingSample] = []
        var variant = 0
        while result.count < target && variant < options.maxVariantsPerSeed {
            for seed in sorted where result.count < target {
                let key = generatedRecordKey(contractRowID: seed.contractRowID, variant: variant)
                guard !usedVariantKeys.contains(key) else {
                    continue
                }
                usedVariantKeys.insert(key)
                let generated = generatedByKey[key]
                result.append(makePositiveSample(seed: seed, variant: variant, ordinal: sampleOffset + result.count, maskingStage: options.maskingStage, generatedRecord: generated))
            }
            variant += 1
        }
        return result
    }

    private func generatedRecordKey(contractRowID: String, variant: Int) -> String {
        "\(contractRowID)#\(variant)"
    }

    private func assignDevSelection(samples: [C5TrainingSample], count: Int) -> [C5TrainingSample] {
        guard count > 0, !samples.isEmpty else {
            return samples
        }
        let selectedIDs = Set(samples.stratifiedSelection(count: min(count, samples.count)).map(\.sampleID))
        return samples.map { sample in
            guard selectedIDs.contains(sample.sampleID) else {
                return sample
            }
            var copy = sample
            copy.split = "dev_selection"
            copy.trainEligible = false
            return copy
        }
    }

    private func buildNoCallSamples(from trainPositives: [C5TrainingSample], options: C5TrainingBuildOptions) -> [C5TrainingSample] {
        guard !trainPositives.isEmpty else {
            return []
        }
        let targetCount = Int((Double(trainPositives.count) * options.refusalRatioTarget / (1 - options.refusalRatioTarget)).rounded())
        let cappedCount = min(targetCount, Int(Double(trainPositives.count) * options.refusalRatioHardCap / (1 - options.refusalRatioHardCap)))
        return trainPositives.prefix(max(0, cappedCount)).enumerated().map { index, positive in
            var sample = positive
            sample.sampleID = "c5-nocall-\(String(format: "%05d", index + 1))"
            sample.splitOrigin = "paired_counterfactual_from_train"
            sample.bucket = "paired_counterfactual_refusal"
            sample.expectedToolCalls = []
            sample.noCall = C5NoCallMetadata(
                counterfactualPairID: positive.sampleID,
                targetToolPresent: false,
                removedToolID: "tool_call_frame",
                distractorToolIDs: positive.promptDistractorToolIDs,
                noCallReason: "paired_counterfactual_removed_target_tool"
            )
            sample.messages[sample.messages.count - 1] = C5TrainingMessage(role: "assistant", content: "\n\nNO_TOOL")
            return sample
        }
    }

    private func makePositiveSample(seed: C5SemanticSeed, variant: Int, ordinal: Int, maskingStage: C5MaskingStage, generatedRecord: C5GeneratedUtteranceRecord?) -> C5TrainingSample {
        let valueAugmentation = C5TrainingRenderer.augmentValue(seed: seed, variant: variant)
        let slotAssignments = C5TrainingRenderer.slotAssignments(seed: seed, variant: variant, value: valueAugmentation.value)
        let call = C5TrainingToolCall(name: "tool_call_frame", arguments: C5TrainingRenderer.toolCallArguments(seed: seed, value: valueAugmentation.value, slotAssignments: slotAssignments))
        let renderedToolCall = C5TrainingRenderer.renderToolCall(call)
        let assistant = "\n\n" + renderedToolCall
        let localUtterance = C5TrainingRenderer.renderUserUtterance(seed: seed, variant: variant, valueText: valueAugmentation.utteranceValueText, slotAssignments: slotAssignments)
        let utterance = generatedRecord?.utterance ?? localUtterance
        let promptHash = generatedRecord?.promptHash.isEmpty == false ? generatedRecord?.promptHash ?? "" : C6Hash.sha256Hex(Data(utterance.utf8))
        let candidateParentSemanticID = C5TrainingRenderer.candidateParentSemanticID(userUtterance: utterance, renderedToolCall: renderedToolCall)
        let distractors = C5TrainingRenderer.distractorToolSchemas(variant: variant)
        return C5TrainingSample(
            sampleID: "c5-train-\(String(format: "%05d", ordinal + 1))",
            split: "train",
            splitOrigin: "protocol_seed_train",
            bucket: "semantic_protocol_augmented",
            augmentationParentID: seed.contractRowID,
            lineageGroupID: seed.dedupeGroupID,
            parentSemanticID: seed.canonicalSemanticID,
            seedParentSemanticID: seed.canonicalSemanticID,
            candidateParentSemanticID: candidateParentSemanticID,
            candidateCanonicalSemanticID: seed.canonicalSemanticID,
            candidateDedupeGroupID: seed.dedupeGroupID,
            expectedToolCallSignature: C6Hash.sha256Hex(Data(renderedToolCall.utf8)),
            routeTierSource: "fc_flags_normalized",
            routeTier: seed.routeTier,
            executionTier: seed.execTier,
            utteranceSource: generatedRecord == nil ? .singleTurnSeed : .llmAugmented,
            valueStrategy: seed.valueStrategy,
            maskingStage: maskingStage,
            trainEligible: maskingStage.trainEligible,
            masking: C5MaskingFlags(
                functionName: !distractors.ids.isEmpty,
                argumentName: !distractors.ids.isEmpty,
                argumentValue: valueAugmentation.didAugment,
                trainOnTurn: maskingStage != .smokeOnly
            ),
            acceptanceStage: maskingStage == .smokeOnly ? .trainHealth : .trainableV0,
            generatorModelID: generatedRecord?.generatorModelID ?? "deterministic_semantic_protocol_v1",
            generatorCallID: generatedRecord?.generatorCallID ?? "local-contract-\(seed.contractRowID)-v\(variant)",
            semanticJudgeModelID: generatedRecord?.semanticJudgeModelID ?? "",
            semanticJudgeCallID: generatedRecord?.semanticJudgeCallID ?? "",
            promptHash: promptHash,
            messages: [
                C5TrainingMessage(role: "system", content: "你是 MAformac 离线 mock 车控演示助手。控制路径只输出 tool_call 包裹或 NO_TOOL。"),
                C5TrainingMessage(role: "user", content: utterance),
                C5TrainingMessage(role: "assistant", content: assistant)
            ],
            tools: C5TrainingRenderer.toolCallFrameToolSchema + distractors.schemas,
            expectedToolCalls: [call],
            noCall: nil,
            promptDistractorToolIDs: distractors.ids
        )
    }
}

private enum C5CanonicalJSONObject {
    static func render(_ object: [String: JSONValue]) -> String {
        let keys = object.keys.sorted()
        let body = keys.map { key in
            "\"\(escape(key))\":\(renderValue(object[key] ?? .null))"
        }.joined(separator: ",")
        return "{\(body)}"
    }

    private static func renderValue(_ value: JSONValue) -> String {
        switch value {
        case .string(let text):
            return "\"\(escape(text))\""
        case .number(let number):
            if number.rounded() == number {
                return String(Int(number))
            }
            return String(number)
        case .bool(let bool):
            return bool ? "true" : "false"
        case .object(let object):
            return render(object)
        case .array(let values):
            return "[\(values.map(renderValue).joined(separator: ","))]"
        case .null:
            return "null"
        }
    }

    private static func escape(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}

private extension Array where Element == C5TrainingSample {
    func stratifiedSelection(count: Int) -> [C5TrainingSample] {
        guard count > 0 else {
            return []
        }
        let grouped = Dictionary(grouping: self, by: \.routeTier)
        var selected: [C5TrainingSample] = []
        for tier in C5RouteTier.allCases {
            let tierItems = grouped[tier, default: []]
            let totalCount = Double(self.count)
            let tierShare = Double(tierItems.count) / totalCount
            let requestedCount = (tierShare * Double(count)).rounded()
            let tierCount = Swift.max(1, Int(requestedCount))
            selected.append(contentsOf: tierItems.prefix(tierCount))
        }
        if selected.count < count {
            let selectedIDs = Set(selected.map(\.sampleID))
            selected.append(contentsOf: self.filter { !selectedIDs.contains($0.sampleID) }.prefix(count - selected.count))
        }
        return Array(selected.prefix(count))
    }
}
