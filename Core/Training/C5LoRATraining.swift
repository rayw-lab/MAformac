import Foundation

public enum C5RouteTier: String, Codable, CaseIterable, Sendable {
    case ruleL1 = "rule_l1"
    case fcL2 = "fc_l2"
    case fcL3 = "fc_l3"

    public static func derive(fuzzy: Bool, free: Bool) -> C5RouteTier {
        derive(fuzzy: fuzzy, free: free, valueType: "")
    }

    public static func derive(fuzzy: Bool, free: Bool, valueType: String) -> C5RouteTier {
        let normalizedValueType = valueType.uppercased()
        if free {
            return .fcL3
        }
        if fuzzy {
            return .fcL2
        }
        if normalizedValueType == "FREE" {
            return .fcL3
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

// 训练样本覆盖范围(paradigm §1 D-domain): demo=10 族 562 intent allowlist / full=全集 1538 intent。
public enum C5TrainingScope: String, Codable, CaseIterable, Sendable {
    case demo
    case full
}

// model-visible 训练 surface 形态: dDomain=具名工具(name=intent, value 形态编码进名) / frame=旧 generic tool_call_frame(strangler 保留, retrain 全迁后删)。
public enum C5TrainingSurface: String, Codable, CaseIterable, Sendable {
    case dDomain = "d_domain"
    case frame
}

public enum C5ScopeCandidateCatalog {
    public static func scopeCandidatesBySlot(from stateCells: StateCellContractLookup) -> [String: [String]] {
        var result: [String: [String]] = [:]
        for (_, slots) in scopeCandidatesByDeviceSlot(from: stateCells) {
            for (slot, values) in slots {
                appendUnique(values, to: &result[slot, default: []])
            }
        }
        return result
    }

    public static func scopeCandidatesByDeviceSlot(from stateCells: StateCellContractLookup) -> [String: [String: [String]]] {
        var result: [String: [String: [String]]] = [:]
        for (device, cellID) in ToolContractStateApplier.deviceCellMap.sorted(by: { $0.key < $1.key }) {
            guard let cell = stateCells.cell(id: cellID), !cell.scope.isEmpty else {
                continue
            }
            for slot in slotKeys(for: cellID) {
                result[device, default: [:]][slot] = cell.scope
            }
        }
        return result
    }

    private static func slotKeys(for cellID: String) -> [String] {
        switch cellID {
        case "screen.brightness":
            return ["screen_type"]
        case "ambient.brightness":
            return ["name"]
        case "ac.temp_setpoint", "ac.fan_speed":
            return ["direction", "position"]
        default:
            return ["position", "direction"]
        }
    }

    private static func appendUnique(_ values: [String], to target: inout [String]) {
        var seen = Set(target)
        for value in values where seen.insert(value).inserted {
            target.append(value)
        }
    }
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
        C5RouteTier.derive(fuzzy: fcFlags.fuzzy, free: fcFlags.free, valueType: value.type)
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

public enum C5LossObjectiveProfile: String, Codable, CaseIterable, Sendable {
    case assistantFullExceptThink = "assistant_full_except_think"
    case noToolFull = "no_tool_full"
    case diagnosticSpanOnly = "diagnostic_span_only"
}

public struct C5AugmentationProfile: Codable, Equatable, Sendable {
    public var functionName: Bool
    public var argumentName: Bool
    public var argumentValue: Bool

    enum CodingKeys: String, CodingKey {
        case functionName = "function_name"
        case argumentName = "argument_name"
        case argumentValue = "argument_value"
    }

    public init(functionName: Bool = false, argumentName: Bool = false, argumentValue: Bool = false) {
        self.functionName = functionName
        self.argumentName = argumentName
        self.argumentValue = argumentValue
    }
}

public struct C5NaturalToolCallRecord: Codable, Equatable, Sendable {
    public var contractRowID: String
    public var variant: Int
    public var user: String
    public var target: String
    public var generatorModelID: String
    public var generatorSourceVendor: String?
    public var generatorCallID: String
    public var semanticJudgeModelID: String
    public var semanticJudgeCallID: String
    public var promptHash: String

    enum CodingKeys: String, CodingKey {
        case contractRowID = "contract_row_id"
        case variant
        case user
        case target
        case generatorModelID = "generator_model_id"
        case generatorSourceVendor = "generator_source_vendor"
        case generatorCallID = "generator_call_id"
        case semanticJudgeModelID = "semantic_judge_model_id"
        case semanticJudgeCallID = "semantic_judge_call_id"
        case promptHash = "prompt_hash"
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
    public var device: String = ""
    public var expectedToolCallSignature: String
    public var routeTierSource: String
    public var routeTier: C5RouteTier
    public var executionTier: String
    public var utteranceSource: C5UtteranceSource
    public var valueStrategy: C5ValueStrategy
    public var lossObjectiveProfile: C5LossObjectiveProfile
    public var augmentationProfile: C5AugmentationProfile
    public var maskingStage: C5MaskingStage
    public var trainEligible: Bool
    public var masking: C5MaskingFlags
    public var acceptanceStage: C5AcceptanceStage
    public var generatorModelID: String
    public var generatorSourceVendor: String? = nil
    public var generatorCallID: String
    public var semanticJudgeModelID: String
    public var semanticJudgeCallID: String
    public var promptHash: String
    public var messages: [C5TrainingMessage]
    public var tools: [[String: JSONValue]]
    public var expectedToolCalls: [C5TrainingToolCall]
    public var noCall: C5NoCallMetadata?
    public var promptDistractorToolIDs: [String]
    public var subsetPolicyID: String? = nil
    public var subsetGroupID: String? = nil
    public var mountedToolCount: Int? = nil
    public var subsetPolicyDigest: String? = nil

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
        case device
        case expectedToolCallSignature = "expected_tool_call_signature"
        case routeTierSource = "route_tier_source"
        case routeTier = "route_tier"
        case executionTier = "execution_tier"
        case utteranceSource = "utterance_source"
        case valueStrategy = "value_strategy"
        case lossObjectiveProfile = "loss_objective_profile"
        case augmentationProfile = "augmentation_profile"
        case maskingStage = "masking_stage"
        case trainEligible = "train_eligible"
        case masking
        case acceptanceStage = "acceptance_stage"
        case generatorModelID = "generator_model_id"
        case generatorSourceVendor = "generator_source_vendor"
        case generatorCallID = "generator_call_id"
        case semanticJudgeModelID = "semantic_judge_model_id"
        case semanticJudgeCallID = "semantic_judge_call_id"
        case promptHash = "prompt_hash"
        case messages
        case tools
        case expectedToolCalls = "expected_tool_calls"
        case noCall = "no_call"
        case promptDistractorToolIDs = "prompt_distractor_tool_ids"
        case subsetPolicyID = "subset_policy_id"
        case subsetGroupID = "subset_group_id"
        case mountedToolCount = "mounted_tool_count"
        case subsetPolicyDigest = "subset_policy_digest"
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
            device: device,
            toolName: expectedToolCalls.first?.name,
            valueType: valueStrategy.rawValue,
            templateFamily: utteranceSource.rawValue,
            generatorSource: generatorSourceVendor ?? generatorModelID,
            generatorModelID: generatorModelID,
            generatorSourceVendor: generatorSourceVendor,
            mustNotTrain: split != "train",
            sourceAuthorization: "authorized_c1_semantic_contract",
            inputText: messages.first(where: { $0.role == "user" })?.content ?? "",
            assistantText: assistantPayload,
            hasActionToolCall: !expectedToolCalls.isEmpty,
            hasSharedWrapper: assistantPayload.contains("<tool_call>"),
            masking: masking,
            tools: tools,
            mountedToolCount: mountedToolCount,
            subsetPolicyID: subsetPolicyID,
            subsetGroupID: subsetGroupID,
            subsetPolicyDigest: subsetPolicyDigest,
            promptHash: promptHash,
            expectedToolCallSignature: expectedToolCallSignature,
            hashRecipeRef: C5DerivedHashRecipe.hashRecipeRef,
            hashRecomputedByPipeline: true
        )
    }

    public var mlxRecord: C5MLXRecord {
        C5MLXRecord(
            sampleID: sampleID,
            messages: messages,
            tools: tools,
            lossObjectiveProfile: lossObjectiveProfile,
            augmentationProfile: augmentationProfile,
            lossMask: lossMask
        )
    }

    public var supervisedEvaluationMLXRecord: C5MLXRecord {
        var supervised = self
        supervised.trainEligible = true
        supervised.masking.trainOnTurn = true
        return C5MLXRecord(
            sampleID: sampleID,
            messages: messages,
            tools: tools,
            lossObjectiveProfile: lossObjectiveProfile,
            augmentationProfile: augmentationProfile,
            lossMask: C5LossMaskBuilder.lossMask(for: supervised)
        )
    }

    public var lossMask: C5MLXLossMask {
        C5LossMaskBuilder.lossMask(for: self)
    }
}

public struct C5MLXRecord: Codable, Equatable, Sendable {
    public var sampleID: String
    public var messages: [C5TrainingMessage]
    public var tools: [[String: JSONValue]]
    public var lossObjectiveProfile: C5LossObjectiveProfile
    public var augmentationProfile: C5AugmentationProfile
    public var lossMask: C5MLXLossMask

    enum CodingKeys: String, CodingKey {
        case sampleID = "sample_id"
        case messages
        case tools
        case lossObjectiveProfile = "loss_objective_profile"
        case augmentationProfile = "augmentation_profile"
        case lossMask = "loss_mask"
    }
}

public struct C5MLXLossMaskSpan: Codable, Equatable, Sendable {
    public var kind: String
    public var start: Int
    public var end: Int
    public var text: String

    public init(kind: String, start: Int, end: Int, text: String) {
        self.kind = kind
        self.start = start
        self.end = end
        self.text = text
    }
}

public struct C5MLXLossMask: Codable, Equatable, Sendable {
    public static let ignoreIndex = -100
    public static let assistantEndToken = "<|im_end|>"

    public var ignoreIndex: Int
    public var trainableSpans: [C5MLXLossMaskSpan]
    public var maskedThinkSpans: [C5MLXLossMaskSpan]
    public var enforcement: String
    public var tokenLabelSource: String
    public var trainableAssistantEndToken: String?

    enum CodingKeys: String, CodingKey {
        case ignoreIndex = "ignore_index"
        case trainableSpans = "trainable_spans"
        case maskedThinkSpans = "masked_think_spans"
        case enforcement
        case tokenLabelSource = "token_label_source"
        case trainableAssistantEndToken = "trainable_assistant_end_token"
    }

    public init(
        ignoreIndex: Int = C5MLXLossMask.ignoreIndex,
        trainableSpans: [C5MLXLossMaskSpan],
        maskedThinkSpans: [C5MLXLossMaskSpan],
        enforcement: String,
        tokenLabelSource: String = "runtime_tokenizer_offsets",
        trainableAssistantEndToken: String? = C5MLXLossMask.assistantEndToken
    ) {
        self.ignoreIndex = ignoreIndex
        self.trainableSpans = trainableSpans
        self.maskedThinkSpans = maskedThinkSpans
        self.enforcement = enforcement
        self.tokenLabelSource = tokenLabelSource
        self.trainableAssistantEndToken = trainableAssistantEndToken
    }
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
    public var trainingLoopSourceState: String
    public var trainingLoopSourceSHA256: String
    public var trainingLoopVerificationStatus: String
    public var trainingLoopVerificationRef: String

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
        case trainingLoopSourceState = "training_loop_source_state"
        case trainingLoopSourceSHA256 = "training_loop_source_sha256"
        case trainingLoopVerificationStatus = "training_loop_verification_status"
        case trainingLoopVerificationRef = "training_loop_verification_ref"
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
        gradientClipStatus: String,
        trainingLoopSourceState: String,
        trainingLoopSourceSHA256: String,
        trainingLoopVerificationStatus: String,
        trainingLoopVerificationRef: String
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
        self.trainingLoopSourceState = trainingLoopSourceState
        self.trainingLoopSourceSHA256 = trainingLoopSourceSHA256
        self.trainingLoopVerificationStatus = trainingLoopVerificationStatus
        self.trainingLoopVerificationRef = trainingLoopVerificationRef
    }

    public static func defaultPrepare(
        baseModel: String = "mlx-community/Qwen3-1.7B-4bit",
        trainingLoopSourceState: String = "tracked_unverified",
        trainingLoopSourceSHA256: String = "unknown_at_prepare_time",
        trainingLoopVerificationStatus: String = "missing",
        trainingLoopVerificationRef: String = "missing"
    ) -> C5TrainingEnvironment {
        let clipStatus = trainingLoopSourceState == "verified" && trainingLoopVerificationStatus == "pass"
            ? "verified_repo_loop_clip_grad_norm_max_1.0_nonfinite_stop_fallback_lr_5e-5"
            : "tracked_unverified_repo_loop_clip_grad_norm_max_1.0_nonfinite_stop_fallback_lr_5e-5"
        return C5TrainingEnvironment(
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
            gradientClipStatus: clipStatus,
            trainingLoopSourceState: trainingLoopSourceState,
            trainingLoopSourceSHA256: trainingLoopSourceSHA256,
            trainingLoopVerificationStatus: trainingLoopVerificationStatus,
            trainingLoopVerificationRef: trainingLoopVerificationRef
        )
    }

    public var trainingLoopVerifiedForFormalTraining: Bool {
        trainingLoopSourceState == "verified" && trainingLoopVerificationStatus == "pass" && !trainingLoopSourceSHA256.isEmpty
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

public struct C5TrainingMethodContractAuthority: Codable, Equatable, Sendable {
    public static let activeMethodSpecPath = "openspec/specs/lora-training/spec.md"
    public static let archivedDefineTrainingChangePath = "openspec/changes/archive/2026-06-21-define-lora-training"
    public static let archivedDefineTrainingSpecPath = "openspec/changes/archive/2026-06-21-define-lora-training/specs/lora-training/spec.md"

    public var status: String
    public var activeMethodSpecPath: String
    public var activeMethodSpecSHA256: String?
    public var archivedChangePath: String
    public var archivedMethodSpecPath: String
    public var archivedMethodSpecSHA256: String?
    public var failureReceipt: [String]

    enum CodingKeys: String, CodingKey {
        case status
        case activeMethodSpecPath = "active_method_spec_path"
        case activeMethodSpecSHA256 = "active_method_spec_sha256"
        case archivedChangePath = "archived_change_path"
        case archivedMethodSpecPath = "archived_method_spec_path"
        case archivedMethodSpecSHA256 = "archived_method_spec_sha256"
        case failureReceipt = "failure_receipt"
    }

    public static func evaluate(
        activeMethodSpecPath: String = C5TrainingMethodContractAuthority.activeMethodSpecPath,
        archivedChangePath: String = C5TrainingMethodContractAuthority.archivedDefineTrainingChangePath,
        archivedMethodSpecPath: String = C5TrainingMethodContractAuthority.archivedDefineTrainingSpecPath,
        fileManager: FileManager = .default
    ) -> C5TrainingMethodContractAuthority {
        let activeSpecSHA = sha256IfPresent(path: activeMethodSpecPath)
        let archivedSpecSHA = sha256IfPresent(path: archivedMethodSpecPath)
        var failures: [String] = []
        if activeSpecSHA == nil {
            failures.append("active_training_method_spec_missing")
        }
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: archivedChangePath, isDirectory: &isDirectory) || !isDirectory.boolValue {
            failures.append("archived_define_lora_training_change_missing")
        }
        if archivedSpecSHA == nil {
            failures.append("archived_training_method_spec_missing")
        }
        return C5TrainingMethodContractAuthority(
            status: failures.isEmpty ? "pass" : "fail",
            activeMethodSpecPath: activeMethodSpecPath,
            activeMethodSpecSHA256: activeSpecSHA,
            archivedChangePath: archivedChangePath,
            archivedMethodSpecPath: archivedMethodSpecPath,
            archivedMethodSpecSHA256: archivedSpecSHA,
            failureReceipt: failures
        )
    }

    private static func sha256IfPresent(path: String) -> String? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        return C6Hash.sha256Hex(data)
    }
}

public struct C5ScaleAuthorityResolution: Codable, Equatable, Sendable {
    public var status: String
    public var firstCandidateScale: Double
    public var observedScale: Double
    public var sourceRef: String
    public var deferredABScales: [Double]
    public var failureReceipt: [String]

    enum CodingKeys: String, CodingKey {
        case status
        case firstCandidateScale = "first_candidate_scale"
        case observedScale = "observed_scale"
        case sourceRef = "source_ref"
        case deferredABScales = "deferred_ab_scales"
        case failureReceipt = "failure_receipt"
    }

    public static func evaluate(observedScale: Double, firstCandidateScale: Double = 20) -> C5ScaleAuthorityResolution {
        let matches = abs(observedScale - firstCandidateScale) < 0.000001
        return C5ScaleAuthorityResolution(
            status: matches ? "pass" : "fail",
            firstCandidateScale: firstCandidateScale,
            observedScale: observedScale,
            sourceRef: "docs/p1c-training-grill-decisions.md:61",
            deferredABScales: [32],
            failureReceipt: matches ? [] : ["scale_authority_mismatch"]
        )
    }
}

public struct C5CandidateDataQualityGate: Codable, Equatable, Sendable {
    public var status: String
    public var maxVariantsPerSeed: Int
    public var maxObservedVariantsPerSeed: Int
    public var capStatus: String
    public var diversityStatus: String
    public var uniqueUtteranceRatio: Double
    public var ambiguousDuplicateCount: Int
    public var lineageParentOverlap: Int
    public var epochExposureMax: Int
    public var failureReceipt: [String]

    enum CodingKeys: String, CodingKey {
        case status
        case maxVariantsPerSeed = "max_variants_per_seed"
        case maxObservedVariantsPerSeed = "max_observed_variants_per_seed"
        case capStatus = "cap_status"
        case diversityStatus = "diversity_status"
        case uniqueUtteranceRatio = "unique_utterance_ratio"
        case ambiguousDuplicateCount = "ambiguous_duplicate_count"
        case lineageParentOverlap = "lineage_parent_overlap"
        case epochExposureMax = "epoch_exposure_max"
        case failureReceipt = "failure_receipt"
    }

    public static func evaluate(
        samples: [C5TrainingSample],
        maxVariantsPerSeed: Int,
        epochs: Int,
        lineageParentOverlap: Int
    ) -> C5CandidateDataQualityGate {
        let actionSamples = samples.filter { !$0.expectedToolCalls.isEmpty }
        let variantsBySeed = Dictionary(grouping: actionSamples, by: \.augmentationParentID).mapValues(\.count)
        let maxObserved = variantsBySeed.values.max() ?? 0
        let userUtterances = actionSamples.map { sample in
            sample.messages.first { $0.role == "user" }?.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        let uniqueUtteranceRatio = actionSamples.isEmpty ? 1.0 : Double(Set(userUtterances).count) / Double(actionSamples.count)
        let groupedByUtteranceAndPromptContext = Dictionary(grouping: samples) { sample in
            let user = sample.messages.first { $0.role == "user" }?.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let targetToolPresent = sample.noCall?.targetToolPresent ?? true
            let distractors = sample.promptDistractorToolIDs.sorted().joined(separator: ",")
            return "\(user)|target_tool_present=\(targetToolPresent)|distractors=\(distractors)"
        }
        let ambiguousDuplicateCount = groupedByUtteranceAndPromptContext.values.filter { group in
            let signatures = Set(group.map { sample in
                sample.expectedToolCalls.isEmpty ? "NO_TOOL" : sample.expectedToolCallSignature
            })
            return group.count > 1 && signatures.count > 1
        }.count
        let capOK = maxObserved <= maxVariantsPerSeed
        let diversityOK = uniqueUtteranceRatio >= 0.80
        var failures: [String] = []
        if !capOK {
            failures.append("per_seed_variant_cap_exceeded")
        }
        if !diversityOK {
            failures.append("variant_diversity_check_failed")
        }
        if ambiguousDuplicateCount > 0 {
            failures.append("ambiguous_duplicate")
        }
        if lineageParentOverlap > 0 {
            failures.append("lineage_parent_overlap")
        }
        return C5CandidateDataQualityGate(
            status: failures.isEmpty ? "pass" : "fail",
            maxVariantsPerSeed: maxVariantsPerSeed,
            maxObservedVariantsPerSeed: maxObserved,
            capStatus: capOK ? "pass" : "fail",
            diversityStatus: diversityOK ? "pass" : "fail",
            uniqueUtteranceRatio: uniqueUtteranceRatio,
            ambiguousDuplicateCount: ambiguousDuplicateCount,
            lineageParentOverlap: lineageParentOverlap,
            epochExposureMax: maxObserved * epochs,
            failureReceipt: failures
        )
    }
}

public struct C5TrainingBuildOptions: Equatable, Sendable {
    public var targetPositiveRows: Int
    public var devSelectionRows: Int
    public var refusalRatioTarget: Double
    public var refusalRatioHardCap: Double
    public var includeNoCallCounterfactuals: Bool
    public var maxVariantsPerSeed: Int
    public var maskingStage: C5MaskingStage
    public var usesTrainingTokenizerPatch: Bool
    public var modelOverride: String?
    public var mlxConfig: C5MLXLoRAConfig
    public var generatedAt: String
    public var environment: C5TrainingEnvironment
    public var trainingCurve: C5TrainingCurveReceipt
    public var endpointTokenizerParity: C5EndpointTokenizerParityGate
    public var offsetTokenArtifact: C5MaskOffsetTokenArtifact?
    public var expectedOffsetArtifactSHA256: String?
    public var allowRegeneratedOffsetArtifact: Bool
    public var requireCandidateDataQualityGate: Bool
    public var requireGeneratedUtteranceRecords: Bool
    public var generatedUtteranceRecords: [C5GeneratedUtteranceRecord]
    public var naturalToolCallRecords: [C5NaturalToolCallRecord]
    // paradigm §1 D-domain surface(S4): scope=10 族 562 / full 全集; surface=具名工具/frame strangler; dDomainCatalog 由 CLI 注入(空→frame legacy 回退)。
    public var scope: C5TrainingScope
    public var surface: C5TrainingSurface
    public var dDomainCatalog: [DDomainToolEntry]
    public var subsetPolicyManifestPath: String?
    public var scopeCandidatesBySlot: [String: [String]]
    public var scopeCandidatesByDeviceSlot: [String: [String: [String]]]

    public init(
        targetPositiveRows: Int = 4_500,
        devSelectionRows: Int = 400,
        refusalRatioTarget: Double = 0.10,
        refusalRatioHardCap: Double = 0.20,
        includeNoCallCounterfactuals: Bool = true,
        maxVariantsPerSeed: Int = 8,
        maskingStage: C5MaskingStage = .trainableV0,
        usesTrainingTokenizerPatch: Bool = false,
        modelOverride: String? = nil,
        mlxConfig: C5MLXLoRAConfig = .rank16Mainline(),
        generatedAt: String = "1970-01-01T00:00:00Z",
        environment: C5TrainingEnvironment = .defaultPrepare(),
        trainingCurve: C5TrainingCurveReceipt = .preparePlanned,
        endpointTokenizerParity: C5EndpointTokenizerParityGate = .blockedMissingEndpointRender(),
        offsetTokenArtifact: C5MaskOffsetTokenArtifact? = nil,
        expectedOffsetArtifactSHA256: String? = nil,
        allowRegeneratedOffsetArtifact: Bool = false,
        requireCandidateDataQualityGate: Bool = false,
        requireGeneratedUtteranceRecords: Bool = false,
        generatedUtteranceRecords: [C5GeneratedUtteranceRecord] = [],
        naturalToolCallRecords: [C5NaturalToolCallRecord] = [],
        scope: C5TrainingScope = .demo,
        surface: C5TrainingSurface = .dDomain,
        dDomainCatalog: [DDomainToolEntry] = [],
        subsetPolicyManifestPath: String? = "generated/subset-policy-manifest.json",
        scopeCandidatesBySlot: [String: [String]] = [:],
        scopeCandidatesByDeviceSlot: [String: [String: [String]]] = [:]
    ) {
        self.targetPositiveRows = targetPositiveRows
        self.devSelectionRows = devSelectionRows
        self.refusalRatioTarget = refusalRatioTarget
        self.refusalRatioHardCap = refusalRatioHardCap
        self.includeNoCallCounterfactuals = includeNoCallCounterfactuals
        self.maxVariantsPerSeed = maxVariantsPerSeed
        self.maskingStage = maskingStage
        self.usesTrainingTokenizerPatch = usesTrainingTokenizerPatch
        self.modelOverride = modelOverride
        self.mlxConfig = mlxConfig
        self.generatedAt = generatedAt
        self.environment = environment
        self.trainingCurve = trainingCurve
        self.endpointTokenizerParity = endpointTokenizerParity
        self.offsetTokenArtifact = offsetTokenArtifact
        self.expectedOffsetArtifactSHA256 = expectedOffsetArtifactSHA256
        self.allowRegeneratedOffsetArtifact = allowRegeneratedOffsetArtifact
        self.requireCandidateDataQualityGate = requireCandidateDataQualityGate
        self.requireGeneratedUtteranceRecords = requireGeneratedUtteranceRecords
        self.generatedUtteranceRecords = generatedUtteranceRecords
        self.naturalToolCallRecords = naturalToolCallRecords
        self.scope = scope
        self.surface = surface
        self.dDomainCatalog = dDomainCatalog
        self.subsetPolicyManifestPath = subsetPolicyManifestPath
        self.scopeCandidatesBySlot = scopeCandidatesBySlot
        self.scopeCandidatesByDeviceSlot = scopeCandidatesByDeviceSlot
    }
}

public struct C5ResolvedRefusalRatioConfig: Equatable, Sendable {
    public var refusalRatioTarget: Double
    public var refusalRatioHardCap: Double
    public var includeNoCallCounterfactuals: Bool
    public var source: String
}

public enum C5RefusalRatioResolutionError: Error, Equatable, CustomStringConvertible {
    case missingExplicitOrManifestValue
    case invalidRatio(field: String, value: Double)

    public var description: String {
        switch self {
        case .missingExplicitOrManifestValue:
            return "missing refusal_ratio_target/refusal_ratio_hard_cap: pass --refusal-ratio-target and --refusal-ratio-hard-cap, --theta-alpha-positive-only, or a batch manifest with locked refusal values"
        case .invalidRatio(let field, let value):
            return "invalid \(field) \(value): expected 0 <= value < 1"
        }
    }
}

public enum C5RefusalRatioResolver {
    public static func resolve(
        thetaAlphaPositiveOnly: Bool,
        explicitTarget: Double?,
        explicitHardCap: Double?,
        manifestTarget: Double?,
        manifestHardCap: Double?
    ) throws -> C5ResolvedRefusalRatioConfig {
        if thetaAlphaPositiveOnly {
            return C5ResolvedRefusalRatioConfig(
                refusalRatioTarget: 0,
                refusalRatioHardCap: 0,
                includeNoCallCounterfactuals: false,
                source: "theta_alpha_positive_only"
            )
        }
        guard let target = explicitTarget ?? manifestTarget,
              let hardCap = explicitHardCap ?? manifestHardCap else {
            throw C5RefusalRatioResolutionError.missingExplicitOrManifestValue
        }
        try validate(field: "refusal_ratio_target", value: target)
        try validate(field: "refusal_ratio_hard_cap", value: hardCap)
        return C5ResolvedRefusalRatioConfig(
            refusalRatioTarget: target,
            refusalRatioHardCap: hardCap,
            includeNoCallCounterfactuals: target > 0 && hardCap > 0,
            source: explicitTarget != nil || explicitHardCap != nil ? "explicit_cli" : "batch_manifest"
        )
    }

    private static func validate(field: String, value: Double) throws {
        guard value >= 0, value < 1 else {
            throw C5RefusalRatioResolutionError.invalidRatio(field: field, value: value)
        }
    }
}

private struct C5LoadedSubsetPolicyManifest: Sendable {
    var policyID: String
    var digest: String
    var singleGroupEntriesByToolID: [String: C5SubsetPolicyManifest.Entry]
}

private struct C5SubsetPolicyManifest: Decodable, Sendable {
    // Policy authority source: scripts/gen_subset_manifest.py:24 POLICY_ID.
    static let expectedPolicyID = "e2-lite-v1"

    var entries: [Entry]

    struct Entry: Decodable, Sendable {
        var subsetPolicyID: String
        var groupID: String
        var mountMode: String
        var toolIDsOrdered: [String]
        var distractorPolicy: DistractorPolicy

        enum CodingKeys: String, CodingKey {
            case subsetPolicyID = "subset_policy_id"
            case groupID = "group_id"
            case mountMode = "mount_mode"
            case toolIDsOrdered = "tool_ids_ordered"
            case distractorPolicy = "distractor_policy"
        }
    }

    struct DistractorPolicy: Decodable, Sendable {
        var strategy: String
        var k: Int
    }
}

// A2 cut3: 自然中文话术 generator 接口预留(数据通路不变, generatedUtteranceRecords 仍是消费入口)。
// DeterministicPlaceholderGenerator nil-stub = A2 边界(不实装云 generator/不生成语料); 实装 DEFERRED retrain-c5。
public protocol C5NaturalUtteranceGenerator: Sendable {
    func utterance(forContractRowID contractRowID: String, variant: Int) -> String?
}

public struct DeterministicPlaceholderGenerator: C5NaturalUtteranceGenerator {
    public init() {}
    public func utterance(forContractRowID contractRowID: String, variant: Int) -> String? {
        nil  // A2 nil-stub: 不调云 generator/不生成语料(DEFERRED); 返 nil → makePositiveSample 走本地确定性话术
    }
}

public struct C5GeneratedUtteranceRecord: Codable, Equatable, Sendable {
    public var contractRowID: String
    public var variant: Int
    public var utterance: String
    public var generatorModelID: String
    public var generatorSourceVendor: String? = nil
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
        case generatorSourceVendor = "generator_source_vendor"
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

public struct C5OffsetArtifactAuthority: Codable, Equatable, Sendable {
    public static let approvedFinalV3SHA256 = "c71ffb059610b337cd22350f9883eadb699c2d0d825bcd38b8cdf2752420a1a9"

    public var status: String
    public var authorityMode: String
    public var approvedArtifactSHA256: String?
    public var observedArtifactSHA256: String?
    public var observedArtifactPath: String?
    public var samePathRegenerationRequired: Bool
    public var samePathRegenerationObserved: Bool
    public var failureReceipt: [String]

    enum CodingKeys: String, CodingKey {
        case status
        case authorityMode = "authority_mode"
        case approvedArtifactSHA256 = "approved_artifact_sha256"
        case observedArtifactSHA256 = "observed_artifact_sha256"
        case observedArtifactPath = "observed_artifact_path"
        case samePathRegenerationRequired = "same_path_regeneration_required"
        case samePathRegenerationObserved = "same_path_regeneration_observed"
        case failureReceipt = "failure_receipt"
    }

    public static func notConfigured(offsetFixture: C5MaskOffsetFixture) -> C5OffsetArtifactAuthority {
        C5OffsetArtifactAuthority(
            status: "not_configured",
            authorityMode: "not_configured",
            approvedArtifactSHA256: nil,
            observedArtifactSHA256: offsetFixture.tokenArtifact?.artifactSHA256,
            observedArtifactPath: offsetFixture.tokenArtifact?.artifactPath,
            samePathRegenerationRequired: false,
            samePathRegenerationObserved: false,
            failureReceipt: []
        )
    }

    public static func evaluate(
        offsetFixture: C5MaskOffsetFixture,
        approvedArtifactSHA256: String = approvedFinalV3SHA256,
        allowRegeneratedSamePathArtifact: Bool = false
    ) -> C5OffsetArtifactAuthority {
        let artifact = offsetFixture.tokenArtifact
        let observedSHA = artifact?.artifactSHA256
        let observedPath = artifact?.artifactPath
        let samePathObserved = observedPath?.hasSuffix("offset-fixture/mlx-mask-offset-fixture.json") == true
        var failures: [String] = []

        if offsetFixture.status != "pass" {
            failures.append("offset_fixture_failed")
        }

        let exactApproved = observedSHA == approvedArtifactSHA256
        let regeneratedSamePath = allowRegeneratedSamePathArtifact && samePathObserved && !(observedSHA ?? "").isEmpty
        if !exactApproved && !regeneratedSamePath {
            failures.append("offset_artifact_mismatch")
        }

        return C5OffsetArtifactAuthority(
            status: failures.isEmpty ? "pass" : "fail",
            authorityMode: exactApproved ? "approved_final_v3" : (regeneratedSamePath ? "regenerated_same_path" : "unapproved"),
            approvedArtifactSHA256: approvedArtifactSHA256,
            observedArtifactSHA256: observedSHA,
            observedArtifactPath: observedPath,
            samePathRegenerationRequired: allowRegeneratedSamePathArtifact && !exactApproved,
            samePathRegenerationObserved: samePathObserved,
            failureReceipt: Array(Set(failures)).sorted()
        )
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
    public var earlyStopBasis: String
    public var earlyStopCheckpointSteps: [Int]
    public var earlyStopPolicy: String

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
        case earlyStopBasis = "early_stop_basis"
        case earlyStopCheckpointSteps = "early_stop_checkpoint_steps"
        case earlyStopPolicy = "early_stop_policy"
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
        secondaryExperiments: [String],
        earlyStopBasis: String = "task_metric_checkpoint_gate_not_val_loss",
        earlyStopCheckpointSteps: [Int] = [50, 100, 150],
        earlyStopPolicy: String = "human_pause_on_action_or_no_call_regression"
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
        self.earlyStopBasis = earlyStopBasis
        self.earlyStopCheckpointSteps = earlyStopCheckpointSteps
        self.earlyStopPolicy = earlyStopPolicy
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
            secondaryExperiments: try container.decode([String].self, forKey: .secondaryExperiments),
            earlyStopBasis: try container.decodeIfPresent(String.self, forKey: .earlyStopBasis) ?? "task_metric_checkpoint_gate_not_val_loss",
            earlyStopCheckpointSteps: try container.decodeIfPresent([Int].self, forKey: .earlyStopCheckpointSteps) ?? [50, 100, 150],
            earlyStopPolicy: try container.decodeIfPresent(String.self, forKey: .earlyStopPolicy) ?? "human_pause_on_action_or_no_call_regression"
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
        try container.encode(earlyStopBasis, forKey: .earlyStopBasis)
        try container.encode(earlyStopCheckpointSteps, forKey: .earlyStopCheckpointSteps)
        try container.encode(earlyStopPolicy, forKey: .earlyStopPolicy)
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

    public static func rank16Mainline(model: String = "mlx-community/Qwen3-1.7B-4bit", maxSeqLength: Int = 8192) -> C5MLXLoRAConfig {
        C5MLXLoRAConfig(
            model: model,
            fineTuneType: "lora",
            numLayers: -1,
            rank: 16,
            scale: 20,
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
            secondaryExperiments: ["rank32_confirmation", "dora_rank8_secondary"],
            earlyStopBasis: "task_metric_checkpoint_gate_not_val_loss",
            earlyStopCheckpointSteps: [50, 100, 150],
            earlyStopPolicy: "human_pause_on_action_or_no_call_regression"
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
        # early_stop_basis: \(earlyStopBasis)
        # early_stop_checkpoint_steps: \(earlyStopCheckpointSteps.map(String.init).joined(separator: ","))
        # early_stop_policy: \(earlyStopPolicy)
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

public struct C5SupervisionCoverageDigest: Codable, Equatable, Sendable {
    public var status: String
    public var parserCriticalStatus: String
    public var ratioStatus: String
    public var trainableRatioMinimum: Double
    public var assistantNonThinkCharCount: Int
    public var trainableNonThinkCharCount: Int
    public var trainableNonThinkRatio: Double
    public var promptLeakageCount: Int
    public var userLeakageCount: Int
    public var systemLeakageCount: Int
    public var thinkLeakageCount: Int
    public var parserCriticalFailures: [String]
    public var failureReceipt: [String]
    public var gateContract: [String: String]

    enum CodingKeys: String, CodingKey {
        case status
        case parserCriticalStatus = "parser_critical_status"
        case ratioStatus = "ratio_status"
        case trainableRatioMinimum = "trainable_ratio_minimum"
        case assistantNonThinkCharCount = "assistant_non_think_char_count"
        case trainableNonThinkCharCount = "trainable_non_think_char_count"
        case trainableNonThinkRatio = "trainable_non_think_ratio"
        case promptLeakageCount = "prompt_leakage_count"
        case userLeakageCount = "user_leakage_count"
        case systemLeakageCount = "system_leakage_count"
        case thinkLeakageCount = "think_leakage_count"
        case parserCriticalFailures = "parser_critical_failures"
        case failureReceipt = "failure_receipt"
        case gateContract = "gate_contract"
    }

    public static func evaluate(samples: [C5TrainingSample], trainableRatioMinimum: Double = 0.90) -> C5SupervisionCoverageDigest {
        var assistantNonThinkChars = 0
        var trainableNonThinkChars = 0
        var parserFailures: [String] = []
        var thinkLeakageCount = 0

        for sample in samples where sample.trainEligible {
            let assistant = sample.assistantPayload
            let thinkSpans = C5LossMaskBuilder.thinkBlockSpans(in: assistant)
            let nonThinkSpans = C5LossMaskBuilder.nonThinkSpans(in: assistant, excluding: thinkSpans)
            assistantNonThinkChars += nonThinkSpans.reduce(0) { $0 + ($1.end - $1.start) }
            let trainableRanges = sample.lossMask.trainableSpans.map { $0.start..<$0.end }
            trainableNonThinkChars += countCoveredCharacters(in: nonThinkSpans, by: trainableRanges)
            thinkLeakageCount += thinkSpans.reduce(0) { count, span in
                count + (trainableRanges.contains { $0.lowerBound < span.end && span.start < $0.upperBound } ? 1 : 0)
            }

            if !sample.expectedToolCalls.isEmpty {
                let required = parserCriticalFragments(for: sample)
                for fragment in required where !fragment.isEmpty {
                    guard let range = assistant.range(of: fragment) else {
                        parserFailures.append("\(sample.sampleID):parser_critical_missing:\(fragment)")
                        continue
                    }
                    let start = assistant.distance(from: assistant.startIndex, to: range.lowerBound)
                    let end = assistant.distance(from: assistant.startIndex, to: range.upperBound)
                    if !trainableRanges.contains(where: { $0.lowerBound <= start && end <= $0.upperBound }) {
                        parserFailures.append("\(sample.sampleID):parser_critical_untrained:\(fragment)")
                    }
                }
            } else if !sample.assistantPayload.contains("NO_TOOL") {
                parserFailures.append("\(sample.sampleID):no_tool_payload_missing")
            }
        }

        let ratio = assistantNonThinkChars == 0 ? 1.0 : Double(trainableNonThinkChars) / Double(assistantNonThinkChars)
        var failures = parserFailures
        if ratio < trainableRatioMinimum {
            failures.append("assistant_non_think_trainable_ratio_below_\(trainableRatioMinimum)")
        }
        if thinkLeakageCount > 0 {
            failures.append("think_leakage_count_nonzero")
        }
        return C5SupervisionCoverageDigest(
            status: failures.isEmpty ? "pass" : "fail",
            parserCriticalStatus: parserFailures.isEmpty ? "pass" : "fail",
            ratioStatus: ratio >= trainableRatioMinimum ? "pass" : "fail",
            trainableRatioMinimum: trainableRatioMinimum,
            assistantNonThinkCharCount: assistantNonThinkChars,
            trainableNonThinkCharCount: trainableNonThinkChars,
            trainableNonThinkRatio: ratio,
            promptLeakageCount: 0,
            userLeakageCount: 0,
            systemLeakageCount: 0,
            thinkLeakageCount: thinkLeakageCount,
            parserCriticalFailures: parserFailures,
            failureReceipt: failures,
            gateContract: [
                "parser_critical": "threshold=all_required_fragments_trainable",
                "assistant_non_think_trainable_ratio": "threshold>=\(trainableRatioMinimum)",
                "prompt_user_system_leakage": "threshold=0",
                "think_leakage": "threshold=0"
            ]
        )
    }

    private static func parserCriticalFragments(for sample: C5TrainingSample) -> [String] {
        var fragments = ["<tool_call>", "</tool_call>", "{", "}", "\"name\"", "\"arguments\""]
        for call in sample.expectedToolCalls {
            fragments.append(call.name)
            for key in call.arguments.keys.sorted() {
                fragments.append("\"\(key)\"")
            }
            for value in call.arguments.values {
                fragments.append(contentsOf: C5LossMaskBuilder.scalarValueStrings(value))
            }
        }
        return Array(Set(fragments)).sorted()
    }

    private static func countCoveredCharacters(in spans: [C5MLXLossMaskSpan], by ranges: [Range<Int>]) -> Int {
        var covered = Set<Int>()
        for span in spans {
            for index in span.start..<span.end {
                if ranges.contains(where: { $0.contains(index) }) {
                    covered.insert(index)
                }
            }
        }
        return covered.count
    }
}

public struct C5TrainingReceipt: Codable, Equatable, Sendable {
    public var receiptVersion: String
    public var generatedAt: String
    public var status: String
    public var fitProofLevel: String
    public var consumer: String
    public var consumedArtifact: String
    public var sufficiencyEvidence: String
    public var residualGap: String
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
    public var supervisionCoverageDigest: C5SupervisionCoverageDigest
    public var acceptanceStage: C5AcceptanceStage
    public var trainingMethodContractAuthority: C5TrainingMethodContractAuthority
    public var offsetFixture: C5MaskOffsetFixture
    public var offsetArtifactAuthority: C5OffsetArtifactAuthority
    public var mlxConfig: C5MLXLoRAConfig
    public var scaleAuthorityResolution: C5ScaleAuthorityResolution
    public var candidateDataQualityGate: C5CandidateDataQualityGate
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
        case fitProofLevel = "fit_proof_level"
        case consumer
        case consumedArtifact = "consumed_artifact"
        case sufficiencyEvidence = "sufficiency_evidence"
        case residualGap = "residual_gap"
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
        case supervisionCoverageDigest = "supervision_coverage_digest"
        case acceptanceStage = "acceptance_stage"
        case trainingMethodContractAuthority = "training_method_contract_authority"
        case offsetFixture = "offset_fixture"
        case offsetArtifactAuthority = "offset_artifact_authority"
        case mlxConfig = "mlx_config"
        case scaleAuthorityResolution = "scale_authority_resolution"
        case candidateDataQualityGate = "candidate_data_quality_gate"
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

public enum C5LossMaskBuilder {
    public static func lossMask(for sample: C5TrainingSample) -> C5MLXLossMask {
        let assistant = sample.assistantPayload
        let thinkSpans = thinkBlockSpans(in: assistant)
        guard sample.trainEligible, sample.masking.trainOnTurn else {
            return C5MLXLossMask(
                trainableSpans: [],
                maskedThinkSpans: thinkSpans,
                enforcement: "all_masked_not_train_eligible",
                trainableAssistantEndToken: nil
            )
        }

        let trainableSpans: [C5MLXLossMaskSpan]
        switch sample.lossObjectiveProfile {
        case .assistantFullExceptThink, .noToolFull:
            trainableSpans = nonThinkSpans(in: assistant, excluding: thinkSpans)
        case .diagnosticSpanOnly:
            trainableSpans = diagnosticSpans(for: sample, in: assistant)
        }

        return C5MLXLossMask(
            trainableSpans: trainableSpans.sorted { lhs, rhs in
                lhs.start == rhs.start ? lhs.end < rhs.end : lhs.start < rhs.start
            },
            maskedThinkSpans: thinkSpans,
            enforcement: "token_labels_enforced_after_tokenization_with_think_mask"
        )
    }

    public static func nonThinkSpans(in assistant: String, excluding thinkSpans: [C5MLXLossMaskSpan]) -> [C5MLXLossMaskSpan] {
        guard !assistant.isEmpty else {
            return []
        }
        let sortedThink = thinkSpans.sorted { $0.start < $1.start }
        var spans: [C5MLXLossMaskSpan] = []
        var cursor = 0
        for think in sortedThink {
            if cursor < think.start {
                spans.append(span(kind: "assistant_non_think_payload", start: cursor, end: think.start, in: assistant))
            }
            cursor = max(cursor, think.end)
        }
        if cursor < assistant.count {
            spans.append(span(kind: "assistant_non_think_payload", start: cursor, end: assistant.count, in: assistant))
        }
        return spans.filter { !$0.text.isEmpty }
    }

    private static func diagnosticSpans(for sample: C5TrainingSample, in assistant: String) -> [C5MLXLossMaskSpan] {
        var trainableSpans: [C5MLXLossMaskSpan] = []
        if sample.expectedToolCalls.isEmpty {
            markAllOccurrences(
                of: "NO_TOOL",
                kind: "no_tool_label",
                in: assistant,
                spans: &trainableSpans
            )
        } else {
            for call in sample.expectedToolCalls {
                if sample.augmentationProfile.functionName {
                    markAllOccurrences(
                        of: call.name,
                        kind: "function_name",
                        in: assistant,
                        spans: &trainableSpans
                    )
                }
                if sample.augmentationProfile.argumentName {
                    for key in call.arguments.keys.sorted() {
                        markJSONStringOccurrences(
                            key,
                            kind: "argument_name",
                            in: assistant,
                            spans: &trainableSpans
                        )
                    }
                }
                if sample.augmentationProfile.argumentValue {
                    for value in call.arguments.values {
                        for text in scalarValueStrings(value) {
                            markAllOccurrences(
                                of: text,
                                kind: "argument_value",
                                in: assistant,
                                spans: &trainableSpans
                            )
                        }
                    }
                }
            }
        }
        return trainableSpans
    }

    private static func markJSONStringOccurrences(
        _ text: String,
        kind: String,
        in haystack: String,
        spans: inout [C5MLXLossMaskSpan]
    ) {
        markAllOccurrences(of: "\"\(text)\"", kind: kind, in: haystack, spans: &spans, trimQuotes: true)
    }

    private static func markAllOccurrences(
        of needle: String,
        kind: String,
        in haystack: String,
        spans: inout [C5MLXLossMaskSpan],
        trimQuotes: Bool = false
    ) {
        guard !needle.isEmpty else {
            return
        }
        var searchStart = haystack.startIndex
        while let range = haystack.range(of: needle, range: searchStart..<haystack.endIndex) {
            let effectiveRange: Range<String.Index>
            if trimQuotes, needle.hasPrefix("\""), needle.hasSuffix("\""), needle.count >= 2 {
                effectiveRange = haystack.index(after: range.lowerBound)..<haystack.index(before: range.upperBound)
            } else {
                effectiveRange = range
            }
            let start = haystack.distance(from: haystack.startIndex, to: effectiveRange.lowerBound)
            let end = haystack.distance(from: haystack.startIndex, to: effectiveRange.upperBound)
            spans.append(C5MLXLossMaskSpan(kind: kind, start: start, end: end, text: String(haystack[effectiveRange])))
            searchStart = range.upperBound
        }
    }

    public static func scalarValueStrings(_ value: JSONValue) -> [String] {
        switch value {
        case .string(let text):
            return text.isEmpty ? [] : [text]
        case .number(let number):
            if number.rounded() == number {
                return [String(Int(number))]
            }
            return [String(number)]
        case .bool(let bool):
            return [bool ? "true" : "false"]
        case .object(let object):
            return object.values.flatMap(scalarValueStrings)
        case .array(let values):
            return values.flatMap(scalarValueStrings)
        case .null:
            return []
        }
    }

    public static func thinkBlockSpans(in text: String) -> [C5MLXLossMaskSpan] {
        var spans: [C5MLXLossMaskSpan] = []
        var searchStart = text.startIndex
        while let open = text.range(of: "<think>", range: searchStart..<text.endIndex) {
            let afterOpen = open.upperBound
            guard let close = text.range(of: "</think>", range: afterOpen..<text.endIndex) else {
                break
            }
            let end = close.upperBound
            let startOffset = text.distance(from: text.startIndex, to: open.lowerBound)
            let endOffset = text.distance(from: text.startIndex, to: end)
            spans.append(C5MLXLossMaskSpan(kind: "think_span", start: startOffset, end: endOffset, text: String(text[open.lowerBound..<end])))
            searchStart = end
        }
        return spans
    }

    private static func span(kind: String, start: Int, end: Int, in text: String) -> C5MLXLossMaskSpan {
        let lower = text.index(text.startIndex, offsetBy: start)
        let upper = text.index(text.startIndex, offsetBy: end)
        return C5MLXLossMaskSpan(kind: kind, start: start, end: end, text: String(text[lower..<upper]))
    }

}

public enum C5TrainingRenderer {
    public static func renderToolCall(_ call: C5TrainingToolCall) -> String {
        C5DerivedHashRecipe.renderToolCall(name: call.name, arguments: call.arguments)
    }

    public static func parseRenderedToolCall(_ rendered: String) -> C5TrainingToolCall? {
        let trimmed = rendered.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("<tool_call>"), trimmed.hasSuffix("</tool_call>") else {
            return nil
        }
        let jsonStart = trimmed.index(trimmed.startIndex, offsetBy: "<tool_call>".count)
        let jsonEnd = trimmed.index(trimmed.endIndex, offsetBy: -"</tool_call>".count)
        let jsonText = String(trimmed[jsonStart..<jsonEnd])
        struct Payload: Decodable {
            var name: String
            var arguments: [String: JSONValue]
        }
        guard let data = jsonText.data(using: .utf8),
              let payload = try? JSONDecoder().decode(Payload.self, from: data) else {
            return nil
        }
        return C5TrainingToolCall(name: payload.name, arguments: payload.arguments)
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

    public static func toolCallArguments(
        seed: C5SemanticSeed,
        value: C5ContractValue,
        slotAssignments: [String: String],
        scopeCandidatesBySlot: [String: [String]] = [:],
        scopeCandidatesByDeviceSlot: [String: [String: [String]]] = [:]
    ) -> [String: JSONValue] {
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
            args[key] = .string(slotAssignments[key, default: fallbackSlotValue(
                key: key,
                seed: seed,
                variant: 0,
                scopeCandidatesBySlot: scopeCandidatesBySlot,
                scopeCandidatesByDeviceSlot: scopeCandidatesByDeviceSlot
            )])
        }
        return args
    }

    public static func slotAssignments(
        seed: C5SemanticSeed,
        variant: Int,
        value: C5ContractValue,
        scopeCandidatesBySlot: [String: [String]] = [:],
        scopeCandidatesByDeviceSlot: [String: [String: [String]]] = [:]
    ) -> [String: String] {
        var assignments: [String: String] = [:]
        let rangeMap = parseRange(seed.range)
        for key in seed.slotKeys {
            let c2ScopeCandidates = scopeCandidates(
                for: key,
                seed: seed,
                in: scopeCandidatesBySlot,
                deviceSlots: scopeCandidatesByDeviceSlot
            )
            if key == "device" {
                assignments[key] = seed.device
            } else if key == "action_primitive" {
                assignments[key] = seed.actionPrimitive
            } else if let fixed = fixedSemanticSlotValue(seed.semanticSlots[key]) {
                assignments[key] = fixed
            } else if isScopeLikeSlot(key), !c2ScopeCandidates.isEmpty {
                assignments[key] = c2ScopeCandidates[variant % c2ScopeCandidates.count]
            } else if let values = rangeMap[key], !values.isEmpty {
                assignments[key] = values[variant % values.count]
            } else {
                assignments[key] = fallbackSlotValue(
                    key: key,
                    seed: seed,
                    variant: variant,
                    value: value,
                    scopeCandidatesBySlot: scopeCandidatesBySlot,
                    scopeCandidatesByDeviceSlot: scopeCandidatesByDeviceSlot
                )
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

    private static func fallbackSlotValue(
        key: String,
        seed: C5SemanticSeed,
        variant: Int,
        value: C5ContractValue = C5ContractValue(),
        scopeCandidatesBySlot: [String: [String]] = [:],
        scopeCandidatesByDeviceSlot: [String: [String: [String]]] = [:]
    ) -> String {
        let normalized = key.lowercased()
        let candidates: [String]
        if isScopeLikeSlot(key) {
            candidates = scopeCandidates(
                for: key,
                seed: seed,
                in: scopeCandidatesBySlot,
                deviceSlots: scopeCandidatesByDeviceSlot
            )
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
        return candidates.isEmpty ? "\(key)_value_\((variant % 4) + 1)" : candidates[variant % candidates.count]
    }

    private static func isScopeLikeSlot(_ key: String) -> Bool {
        let normalized = key.lowercased()
        return normalized.contains("position")
            || normalized.contains("direction")
            || normalized.contains("screen_type")
            || normalized.contains("name")
    }

    private static func scopeCandidates(
        for key: String,
        seed: C5SemanticSeed,
        in scopeCandidatesBySlot: [String: [String]],
        deviceSlots: [String: [String: [String]]]
    ) -> [String] {
        let normalized = key.lowercased()
        if let byDevice = deviceSlots[seed.device],
           let candidates = byDevice[key] ?? byDevice[normalized],
           !candidates.isEmpty {
            return candidates
        }
        return scopeCandidatesBySlot[key] ?? scopeCandidatesBySlot[normalized] ?? []
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
        ToolContractCompiler(seeds: []).frameToolSchema
    }

    public static func toolCallFrameToolSchema(seeds: [C5SemanticSeed]) -> [[String: JSONValue]] {
        ToolContractCompiler(seeds: seeds).frameToolSchema
    }

    // MARK: - A2 cut1/cut2 D-domain 具名工具 surface 渲染

    // 单个 D-domain 具名工具 schema(name=intent, parameters 来自 S1 catalog; 复用 ToolContractCompiler.dDomainToolSchemas 等价渲染)。
    public static func dDomainToolSchema(_ entry: DDomainToolEntry) -> [String: JSONValue] {
        [
            "type": .string(entry.type),
            "function": .object([
                "name": .string(entry.function.name),
                "description": .string(entry.function.description),
                "parameters": entry.function.parameters
            ])
        ]
    }

    // tool schema 属性键→enum 值([] = 自由字符串)。供 dDomainToolCallArguments 保证 additionalProperties:false 合规。
    private static func dDomainPropertyEnums(_ entry: DDomainToolEntry) -> [String: [String]] {
        guard case let .object(params) = entry.function.parameters,
              case let .object(props)? = params["properties"] else {
            return [:]
        }
        var out: [String: [String]] = [:]
        for (key, schema) in props {
            if case let .object(s) = schema, case let .array(enumVals)? = s["enum"] {
                out[key] = enumVals.compactMap { if case let .string(v) = $0 { return v }; return nil }
            } else {
                out[key] = []
            }
        }
        return out
    }

    // D-domain 工具调用 arguments: device/action 已编码进工具名(不 emit); 只 emit catalog schema 属性内的键(防 additionalProperties:false 违规)。
    // value 形态值统一命名 "value"(S1 derive_arg_schema:133); slot 槽走 slotAssignments(非法 enum 成员→取合法值, 确定性)。
    public static func dDomainToolCallArguments(
        seed: C5SemanticSeed,
        value: C5ContractValue,
        slotAssignments: [String: String],
        toolEntry: DDomainToolEntry,
        variant: Int
    ) -> [String: JSONValue] {
        let propertyEnums = dDomainPropertyEnums(toolEntry)
        var args: [String: JSONValue] = [:]
        // value 形态 arg(210/562 具名工具有此键): 填增广后的值(offset 优先, 否则 direct)
        if propertyEnums.keys.contains("value") {
            let valueText = value.offset.isEmpty ? value.direct : value.offset
            if !valueText.isEmpty && !isPlaceholderLiteral(valueText) {
                args["value"] = .string(valueText)
            }
        }
        // slot 参数: device/action_primitive 为 frame 内部字段(编码进名), 不 emit; 只 emit schema 内键
        for (key, assigned) in slotAssignments where key != "device" && key != "action_primitive" {
            guard let enums = propertyEnums[key] else { continue }   // 不在 tool schema → drop(additionalProperties:false 安全)
            guard !assigned.isEmpty, !isPlaceholderLiteral(assigned) else { continue }
            if enums.isEmpty || enums.contains(assigned) {
                args[key] = .string(assigned)
            } else {
                args[key] = .string(enums[variant % enums.count])   // 非法 enum 值→取合法成员(确定性, 非 hashValue)
            }
        }
        return args
    }

    // 同族 distractor: 优先同 device(_sg)→同 family(_domain)→其他; K 个; 替 distractorToolSchemas 占位(irrelevant_navigation/music)。不渲全 562(token 爆)。
    public static func sameFamilyDistractors(
        target: DDomainToolEntry,
        catalog: [DDomainToolEntry],
        variant: Int,
        count: Int = 3
    ) -> (ids: [String], schemas: [[String: JSONValue]]) {
        let pool = catalog.filter { $0.function.name != target.function.name }
        guard !pool.isEmpty else { return ([], []) }
        let sameDevice = pool.filter { $0.sg == target.sg }.sorted { $0.function.name < $1.function.name }
        let sameFamily = pool.filter { $0.sg != target.sg && $0.domain == target.domain }.sorted { $0.function.name < $1.function.name }
        let others = pool.filter { $0.domain != target.domain }.sorted { $0.function.name < $1.function.name }
        let ranked = sameDevice + sameFamily + others
        var picked: [DDomainToolEntry] = []
        var idx = variant % ranked.count
        var guardCounter = 0
        while picked.count < min(count, ranked.count) && guardCounter < ranked.count * 2 {
            let entry = ranked[idx % ranked.count]
            if !picked.contains(where: { $0.function.name == entry.function.name }) {
                picked.append(entry)
            }
            idx += 1
            guardCounter += 1
        }
        return (picked.map(\.function.name), picked.map(dDomainToolSchema))
    }
}

public enum C5DerivedHashRecipe {
    public static let hashRecipeAnchorTokens = [
        "repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.promptHash(utterance:)",
        "repo:Core/Training/C5LoRATraining.swift#C5DerivedHashRecipe.expectedToolCallSignature(renderedToolCall:)",
        "repo:Core/Bench/C6VehicleToolBench.swift#C6Hash.sha256Hex"
    ]
    public static let hashRecipeRef = hashRecipeAnchorTokens.joined(separator: ";")

    public static func promptHash(utterance: String) -> String {
        C6Hash.sha256Hex(Data(utterance.utf8))
    }

    public static func renderToolCall(name: String, arguments: [String: JSONValue]) -> String {
        let payload = C5CanonicalJSONObject.renderOrdered([
            ("name", .string(name)),
            ("arguments", .object(arguments))
        ])
        return "<tool_call>\(payload)</tool_call>"
    }

    public static func expectedToolCallSignature(renderedToolCall: String) -> String {
        C6Hash.sha256Hex(Data(renderedToolCall.utf8))
    }

    public static func expectedToolCallSignature(name: String, arguments: [String: JSONValue]) -> String {
        expectedToolCallSignature(renderedToolCall: renderToolCall(name: name, arguments: arguments))
    }

    public static func firstRenderedToolCall(in assistantText: String) -> String? {
        let trimmed = assistantText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("<tool_call>"), trimmed.hasSuffix("</tool_call>") {
            return trimmed
        }
        guard let start = assistantText.range(of: "<tool_call>"),
              let end = assistantText.range(of: "</tool_call>", range: start.upperBound..<assistantText.endIndex) else {
            return nil
        }
        return String(assistantText[start.lowerBound..<end.upperBound])
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
        let positiveResult = buildPositiveSamples(seeds: seeds, options: options)
        let positiveSamples = positiveResult.samples
        let positiveWithDev = assignDevSelection(samples: positiveSamples, count: options.devSelectionRows)
        let noCalls = options.includeNoCallCounterfactuals
            ? buildNoCallSamples(from: positiveWithDev.filter { $0.split == "train" }, options: options)
            : []
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
        var mlxConfig = options.mlxConfig
        if let modelOverride = options.modelOverride {
            mlxConfig.model = modelOverride
        }
        let offsetFixture = C5MaskOffsetFixture.validate(
            samples: samples,
            usesTrainingTokenizerPatch: options.usesTrainingTokenizerPatch,
            tokenArtifact: options.offsetTokenArtifact,
            expectedTokenizerModelID: mlxConfig.model
        )
        let scaleAuthority = C5ScaleAuthorityResolution.evaluate(observedScale: mlxConfig.scale)
        let offsetArtifactAuthority = options.expectedOffsetArtifactSHA256 != nil || options.allowRegeneratedOffsetArtifact
            ? C5OffsetArtifactAuthority.evaluate(
                offsetFixture: offsetFixture,
                approvedArtifactSHA256: options.expectedOffsetArtifactSHA256 ?? C5OffsetArtifactAuthority.approvedFinalV3SHA256,
                allowRegeneratedSamePathArtifact: options.allowRegeneratedOffsetArtifact
            )
            : C5OffsetArtifactAuthority.notConfigured(offsetFixture: offsetFixture)
        let candidateDataQuality = C5CandidateDataQualityGate.evaluate(
            samples: samples,
            maxVariantsPerSeed: options.maxVariantsPerSeed,
            epochs: mlxConfig.epochs,
            lineageParentOverlap: dataGateReceipt.trainParentSemanticOverlap
        )
        let trainingMethodAuthority = C5TrainingMethodContractAuthority.evaluate()
        var hardFailures: [String] = positiveResult.failureReceipt
        if dataGateReceipt.status == "blocked" {
            hardFailures.append("data_gate_blocked")
        }
        if refusalRatio > options.refusalRatioHardCap {
            hardFailures.append("refusal_ratio_cap_exceeded")
        }
        if offsetFixture.status != "pass" && options.maskingStage != .smokeOnly {
            hardFailures.append("offset_fixture_failed")
        }
        if options.maskingStage != .smokeOnly && offsetArtifactAuthority.status == "fail" {
            for failure in offsetArtifactAuthority.failureReceipt where !hardFailures.contains(failure) {
                hardFailures.append(failure)
            }
        }
        if !(0.05...0.10).contains(rehearsalRatio) {
            hardFailures.append("rule_l1_rehearsal_ratio_outside_5_10_percent")
        }
        if options.maskingStage != .smokeOnly && !options.environment.trainingLoopVerifiedForFormalTraining {
            hardFailures.append("training_loop_source_unverified")
        }
        if options.maskingStage != .smokeOnly && trainingMethodAuthority.status != "pass" {
            hardFailures.append(contentsOf: trainingMethodAuthority.failureReceipt)
        }
        if options.maskingStage != .smokeOnly && scaleAuthority.status != "pass" {
            hardFailures.append(contentsOf: scaleAuthority.failureReceipt)
        }
        if options.requireCandidateDataQualityGate && candidateDataQuality.status != "pass" {
            hardFailures.append(contentsOf: candidateDataQuality.failureReceipt)
        }
        let lossMaskFailures = validateLossMaskEnforcement(samples: samples)
        let supervisionCoverageDigest = C5SupervisionCoverageDigest.evaluate(samples: samples)
        let generatorOrchestration = buildGeneratorOrchestrationReceipt(samples: samples)
        let validatorSummary = buildValidatorSummary(dataGateReceipt: dataGateReceipt, offsetFixture: offsetFixture, samples: samples)
        let lineageSummary = buildLineageSummary(samples: samples)
        var formalStep2Failures = lossMaskFailures + generatorOrchestration.failureReceipt + validatorSummary.failureReceipt + lineageSummary.failureReceipt
        if supervisionCoverageDigest.status != "pass" {
            formalStep2Failures.append(contentsOf: supervisionCoverageDigest.failureReceipt)
        }
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
        var frameSurfaced = [
            "dev_selection is a checkpoint-selection split, not heldout or release gold",
            "deterministic_semantic_protocol_v1 is a Step2 dry-run source only; it cannot satisfy Q13 multi-source cloud generation or Q14 semantic judge",
            "C6 release gate remains final-only; this receipt cannot claim model-quality V-PASS without a real C6 diff",
            "Mac behavior parity and true-device candidate V-PASS are reported separately",
            "endpoint tokenizer byte parity is a candidate gate; training-tokenizer patch alone does not prove mlx-swift render parity",
            "formal training requires verified repo loop source state; tracked_unverified loop sources are blocked before candidate training",
            "mlx-data records carry loss_mask trainable/think char spans plus trainable_assistant_end_token; c5_mlx_train_loop tokenizes records and constructs token-level labels with ignore_index=-100"
        ]
        if !options.includeNoCallCounterfactuals || options.refusalRatioTarget == 0 {
            frameSurfaced.append("theta-alpha positive-only scope excludes theta-beta refusal/no-call rows")
        }
        let receipt = C5TrainingReceipt(
            receiptVersion: "c5-lora-training.v1",
            generatedAt: options.generatedAt,
            status: receiptStatus,
            fitProofLevel: "mechanism_true",
            consumer: "Tools/C5TrainingCLI/c5_mlx_train_loop.py --require-maformac-loss-mask",
            consumedArtifact: "mlx-data JSONL loss_objective_profile + loss_mask.trainable_spans + loss_mask.masked_think_spans + loss_mask.trainable_assistant_end_token",
            sufficiencyEvidence: "prepare emits objective-separated loss records; preflight fails closed on missing objectives/end-token supervision unless --allow-legacy-loss-objective is explicit for objectives; repo training loop converts spans plus assistant <|im_end|> to token labels before loss",
            residualGap: "prepare receipt does not claim live training, C6 model-quality V-PASS, endpoint byte parity, or true-device acceptance",
            sourceRefs: [
                "docs/p1c-training-grill-decisions.md:103-408",
                "docs/research/2026-06-21-c5-generator-selection-probe.md:37-54",
                C5TrainingMethodContractAuthority.activeMethodSpecPath,
                C5TrainingMethodContractAuthority.archivedDefineTrainingChangePath,
                C5TrainingMethodContractAuthority.archivedDefineTrainingSpecPath,
                "openspec/changes/define-lora-data-gate/specs/lora-data-gate/spec.md:3-105",
                "Core/Bench/C5DataGate.swift:242-406",
                "mlx_lm/tuner/datasets.py:57-75",
                "mlx_lm/tuner/trainer.py:75-88"
            ],
            discoveryFindings: [
                "route_tier is derived from normalized C1 fc_flags, not execution-tier metadata",
                "stock mlx-lm training has no enable_thinking injection point in tuner datasets path",
                "stock mlx-lm mask_prompt is only a contiguous completion offset; MAformac training loop overrides dataset/iterate/loss for token-level span masks"
            ],
            frameSurfaced: frameSurfaced,
            physicalFields: [
                "route_tier_source", "route_tier", "utterance_source", "value_strategy", "masking_stage", "train_eligible",
                "generator_model_id", "generator_call_id", "semantic_judge_model_id", "semantic_judge_call_id", "prompt_hash",
                "augmentation_parent_id", "lineage_group_id", "split_origin", "candidate_dedupe_group_id", "expected_tool_call_signature",
                "subset_policy_id", "subset_group_id", "mounted_tool_count", "subset_policy_digest",
                "counterfactual_pair_id", "acceptance_stage", "training_method_contract_authority", "offset_artifact_authority", "generator_orchestration", "validator_summary", "lineage_summary",
                "scale_authority_resolution", "candidate_data_quality_gate", "generalization_diagnostic", "fuse_parity_gate", "endpoint_tokenizer_parity", "loss_objective_profile", "augmentation_profile",
                "supervision_coverage_digest", "loss_mask.trainable_spans", "loss_mask.masked_think_spans", "loss_mask.trainable_assistant_end_token"
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
            supervisionCoverageDigest: supervisionCoverageDigest,
            acceptanceStage: acceptanceStage,
            trainingMethodContractAuthority: trainingMethodAuthority,
            offsetFixture: offsetFixture,
            offsetArtifactAuthority: offsetArtifactAuthority,
            mlxConfig: mlxConfig,
            scaleAuthorityResolution: scaleAuthority,
            candidateDataQualityGate: candidateDataQuality,
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

    private func validateLossMaskEnforcement(samples: [C5TrainingSample]) -> [String] {
        var failures: [String] = []
        for sample in samples where sample.trainEligible {
            let mask = sample.lossMask
            if mask.trainableAssistantEndToken != C5MLXLossMask.assistantEndToken {
                failures.append("loss_mask_assistant_end_token_supervision_missing_\(sample.sampleID)")
            }
            for span in mask.maskedThinkSpans {
                if span.start < 0 || span.end > sample.assistantPayload.count || span.start >= span.end {
                    failures.append("loss_mask_think_span_bounds_invalid_\(sample.sampleID)")
                }
                if mask.trainableSpans.contains(where: { trainable in
                    trainable.start < span.end && span.start < trainable.end
                }) {
                    failures.append("loss_mask_trainable_span_overlaps_think_\(sample.sampleID)")
                }
            }
            for span in mask.trainableSpans where span.start < 0 || span.end > sample.assistantPayload.count || span.start >= span.end {
                failures.append("loss_mask_trainable_span_bounds_invalid_\(sample.sampleID)")
            }
            if sample.expectedToolCalls.isEmpty {
                if sample.lossObjectiveProfile != .noToolFull {
                    failures.append("loss_objective_profile_no_tool_mismatch_\(sample.sampleID)")
                }
                if !mask.trainableSpans.contains(where: { $0.text.contains("NO_TOOL") }) {
                    failures.append("loss_mask_no_tool_label_missing_\(sample.sampleID)")
                }
            } else {
                if sample.lossObjectiveProfile != .assistantFullExceptThink {
                    failures.append("loss_objective_profile_tool_call_mismatch_\(sample.sampleID)")
                }
                let parserCritical = ["<tool_call>", "</tool_call>", "\"name\"", "\"arguments\""]
                for required in parserCritical where !mask.trainableSpans.contains(where: { $0.text.contains(required) }) {
                    failures.append("loss_mask_parser_critical_span_missing_\(required)_\(sample.sampleID)")
                }
            }
        }
        return failures
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

    private struct PositiveBuildResult {
        var samples: [C5TrainingSample]
        var failureReceipt: [String]
    }

    private func buildPositiveSamples(seeds: [C5SemanticSeed], options: C5TrainingBuildOptions) -> PositiveBuildResult {
        // paradigm §1 scope: demo→10 族 562 intent allowlist(seed.intent ∈ catalog names); 空 catalog→不过滤(frame legacy 向后兼容)
        let catalogNames = Set(options.dDomainCatalog.map(\.function.name))
        let scopedSeeds: [C5SemanticSeed]
        switch options.scope {
        case .demo:
            scopedSeeds = catalogNames.isEmpty ? seeds : seeds.filter { catalogNames.contains($0.intent) }
        case .full:
            scopedSeeds = seeds
        }
        let catalogByName = Dictionary(options.dDomainCatalog.map { ($0.function.name, $0) }, uniquingKeysWith: { first, _ in first })
        let manifestResult = loadSubsetPolicyManifestIfRequired(options: options, catalogByName: catalogByName)
        let eligible = scopedSeeds.filter { !$0.device.isEmpty && !$0.actionPrimitive.isEmpty }
        let grouped = Dictionary(grouping: eligible, by: \.routeTier)
        var generatedByKey: [String: C5GeneratedUtteranceRecord] = [:]
        for record in options.generatedUtteranceRecords {
            let key = generatedRecordKey(contractRowID: record.contractRowID, variant: record.variant)
            if generatedByKey[key] == nil {
                generatedByKey[key] = record
            }
        }
        var naturalRowsByKey: [String: C5NaturalToolCallRecord] = [:]
        for record in options.naturalToolCallRecords {
            let key = generatedRecordKey(contractRowID: record.contractRowID, variant: record.variant)
            if naturalRowsByKey[key] == nil {
                naturalRowsByKey[key] = record
            }
        }
        var usedVariantKeys: Set<String> = []
        let ruleTarget = max(1, Int(Double(options.targetPositiveRows) * 0.075))
        let fcTarget = max(0, options.targetPositiveRows - ruleTarget)
        var samples: [C5TrainingSample] = []
        var sampleFailures = manifestResult.failures
        if manifestResult.manifest == nil, !sampleFailures.isEmpty {
            return PositiveBuildResult(samples: [], failureReceipt: Array(Set(sampleFailures)).sorted())
        }
        samples.append(contentsOf: variants(from: grouped[.fcL3, default: []], target: fcTarget / 4, options: options, generatedByKey: generatedByKey, naturalRowsByKey: naturalRowsByKey, usedVariantKeys: &usedVariantKeys, catalogByName: catalogByName, subsetManifest: manifestResult.manifest, failureReceipt: &sampleFailures, sampleOffset: samples.count))
        samples.append(contentsOf: variants(from: grouped[.fcL2, default: []], target: max(0, fcTarget - samples.count), options: options, generatedByKey: generatedByKey, naturalRowsByKey: naturalRowsByKey, usedVariantKeys: &usedVariantKeys, catalogByName: catalogByName, subsetManifest: manifestResult.manifest, failureReceipt: &sampleFailures, sampleOffset: samples.count))
        samples.append(contentsOf: variants(from: grouped[.ruleL1, default: []], target: ruleTarget, options: options, generatedByKey: generatedByKey, naturalRowsByKey: naturalRowsByKey, usedVariantKeys: &usedVariantKeys, catalogByName: catalogByName, subsetManifest: manifestResult.manifest, failureReceipt: &sampleFailures, sampleOffset: samples.count))
        if samples.count < options.targetPositiveRows {
            let remaining = options.targetPositiveRows - samples.count
            samples.append(contentsOf: variants(from: eligible, target: remaining, options: options, generatedByKey: generatedByKey, naturalRowsByKey: naturalRowsByKey, usedVariantKeys: &usedVariantKeys, catalogByName: catalogByName, subsetManifest: manifestResult.manifest, failureReceipt: &sampleFailures, sampleOffset: samples.count))
        }
        return PositiveBuildResult(samples: Array(samples.prefix(options.targetPositiveRows)), failureReceipt: Array(Set(sampleFailures)).sorted())
    }

    private func loadSubsetPolicyManifestIfRequired(
        options: C5TrainingBuildOptions,
        catalogByName: [String: DDomainToolEntry]
    ) -> (manifest: C5LoadedSubsetPolicyManifest?, failures: [String]) {
        guard options.surface == .dDomain, !options.dDomainCatalog.isEmpty else {
            return (nil, [])
        }
        guard let path = options.subsetPolicyManifestPath, !path.isEmpty else {
            FileHandle.standardError.write(Data("G7D_SUBSET_MANIFEST_MISSING path unset — fail-closed\n".utf8))
            return (nil, ["subset_manifest_missing"])
        }
        let url = path.hasPrefix("/")
            ? URL(fileURLWithPath: path)
            : URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true).appendingPathComponent(path)
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(C5SubsetPolicyManifest.self, from: data)
            let observedPolicyIDs = Set(decoded.entries.map(\.subsetPolicyID))
            guard observedPolicyIDs.count == 1, observedPolicyIDs.first == C5SubsetPolicyManifest.expectedPolicyID else {
                let observed = observedPolicyIDs.sorted().joined(separator: ",")
                FileHandle.standardError.write(Data("G7D_SUBSET_POLICY_MISMATCH path=\(url.path) expected=\(C5SubsetPolicyManifest.expectedPolicyID) observed=\(observed.isEmpty ? "<none>" : observed) — fail-closed\n".utf8))
                return (nil, ["subset_policy_mismatch"])
            }
            let singleGroupEntries = decoded.entries.filter { $0.mountMode == "single_group" }
            guard !singleGroupEntries.isEmpty else {
                FileHandle.standardError.write(Data("G7D_SUBSET_MANIFEST_EMPTY path=\(url.path) no single_group entries — fail-closed\n".utf8))
                return (nil, ["subset_manifest_no_single_group_entries"])
            }
            var entriesByToolID: [String: C5SubsetPolicyManifest.Entry] = [:]
            var failures: [String] = []
            for entry in singleGroupEntries {
                for toolID in entry.toolIDsOrdered {
                    guard catalogByName[toolID] != nil else {
                        appendUnique("subset_manifest_catalog_mismatch", to: &failures)
                        continue
                    }
                    if entriesByToolID[toolID] == nil {
                        entriesByToolID[toolID] = entry
                    }
                }
            }
            guard failures.isEmpty else {
                FileHandle.standardError.write(Data("G7D_SUBSET_MANIFEST_CLOSURE_FAIL path=\(url.path) failures=\(failures.joined(separator: ",")) — fail-closed\n".utf8))
                return (nil, failures)
            }
            let policyID = singleGroupEntries.first?.subsetPolicyID ?? C5SubsetPolicyManifest.expectedPolicyID
            return (
                C5LoadedSubsetPolicyManifest(
                    policyID: policyID,
                    digest: C6Hash.sha256Hex(data),
                    singleGroupEntriesByToolID: entriesByToolID
                ),
                []
            )
        } catch {
            FileHandle.standardError.write(Data("G7D_SUBSET_MANIFEST_MISSING path=\(url.path) error=\(error.localizedDescription) — fail-closed\n".utf8))
            return (nil, ["subset_manifest_missing"])
        }
    }

    private func variants(
        from seeds: [C5SemanticSeed],
        target: Int,
        options: C5TrainingBuildOptions,
        generatedByKey: [String: C5GeneratedUtteranceRecord],
        naturalRowsByKey: [String: C5NaturalToolCallRecord],
        usedVariantKeys: inout Set<String>,
        catalogByName: [String: DDomainToolEntry],
        subsetManifest: C5LoadedSubsetPolicyManifest?,
        failureReceipt: inout [String],
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
                let generated = generatedByKey[key]
                let naturalRow = naturalRowsByKey[key]
                if options.requireGeneratedUtteranceRecords && generated == nil {
                    continue
                }
                usedVariantKeys.insert(key)
                // P1 fail-closed: makePositiveSample 对 dDomain intent miss 返 nil(skip 不污染 frame); compactMap 过滤。
                if let sample = makePositiveSample(
                    seed: seed,
                    variant: variant,
                    ordinal: sampleOffset + result.count,
                    maskingStage: options.maskingStage,
                    generatedRecord: generated,
                    naturalToolCallRecord: naturalRow,
                    surface: options.surface,
                    catalog: options.dDomainCatalog,
                    catalogByName: catalogByName,
                    subsetManifest: subsetManifest,
                    failureReceipt: &failureReceipt,
                    scopeCandidatesBySlot: options.scopeCandidatesBySlot,
                    scopeCandidatesByDeviceSlot: options.scopeCandidatesByDeviceSlot
                ) {
                    result.append(sample)
                }
            }
            variant += 1
        }
        return result
    }

    private func appendUnique(_ failure: String, to failures: inout [String]) {
        if !failures.contains(failure) {
            failures.append(failure)
        }
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
        guard !trainPositives.isEmpty, options.refusalRatioTarget > 0, options.refusalRatioHardCap > 0 else {
            return []
        }
        let targetCount = Int((Double(trainPositives.count) * options.refusalRatioTarget / (1 - options.refusalRatioTarget)).rounded())
        let cappedCount = min(targetCount, Int(Double(trainPositives.count) * options.refusalRatioHardCap / (1 - options.refusalRatioHardCap)))
        var noCallSamples: [C5TrainingSample] = []
        noCallSamples.reserveCapacity(max(0, cappedCount))
        for positive in trainPositives where noCallSamples.count < max(0, cappedCount) {
            var sample = positive
            // cut5 真删(claim-vs-reality 铁律1, 修 446 假删灾难 variant): 被移除的目标工具 = positive 的 expectedToolCalls 工具名,
            // 从 sample.tools 物理删该工具(非只写 metadata removedToolID)。removedName 兼容 frame(tool_call_frame)/D-domain(intent)。
            let removedName = positive.expectedToolCalls.first?.name ?? "tool_call_frame"
            sample.tools = positive.tools.filter { Self.toolSchemaName($0) != removedName }
            guard !sample.tools.isEmpty else {
                continue
            }
            sample.sampleID = "c5-nocall-\(String(format: "%05d", noCallSamples.count + 1))"
            sample.splitOrigin = "paired_counterfactual_from_train"
            sample.bucket = "paired_counterfactual_refusal"
            sample.expectedToolCalls = []
            sample.lossObjectiveProfile = .noToolFull
            sample.augmentationProfile = C5AugmentationProfile(
                functionName: positive.augmentationProfile.functionName,
                argumentName: positive.augmentationProfile.argumentName,
                argumentValue: positive.augmentationProfile.argumentValue
            )
            sample.mountedToolCount = sample.tools.count
            // 活样本断言: removedName 真不在 tools(targetToolPresent=false 与产物一致, 防 metadata 假声称)
            let targetStillPresent = sample.tools.contains { Self.toolSchemaName($0) == removedName }
            sample.noCall = C5NoCallMetadata(
                counterfactualPairID: positive.sampleID,
                targetToolPresent: targetStillPresent,
                removedToolID: removedName,
                distractorToolIDs: positive.promptDistractorToolIDs,
                noCallReason: "paired_counterfactual_removed_target_tool"
            )
            sample.messages[sample.messages.count - 1] = C5TrainingMessage(role: "assistant", content: "\n\nNO_TOOL")
            noCallSamples.append(sample)
        }
        return noCallSamples
    }

    // tool schema dict → function.name(供 cut5 真删比对; nil = 非标准 schema)。
    private static func toolSchemaName(_ schema: [String: JSONValue]) -> String? {
        guard case let .object(function)? = schema["function"],
              case let .string(name)? = function["name"] else {
            return nil
        }
        return name
    }

    private func makePositiveSample(
        seed: C5SemanticSeed,
        variant: Int,
        ordinal: Int,
        maskingStage: C5MaskingStage,
        generatedRecord: C5GeneratedUtteranceRecord?,
        naturalToolCallRecord: C5NaturalToolCallRecord?,
        surface: C5TrainingSurface,
        catalog: [DDomainToolEntry],
        catalogByName: [String: DDomainToolEntry],
        subsetManifest: C5LoadedSubsetPolicyManifest?,
        failureReceipt: inout [String],
        scopeCandidatesBySlot: [String: [String]],
        scopeCandidatesByDeviceSlot: [String: [String: [String]]]
    ) -> C5TrainingSample? {
        let valueAugmentation = C5TrainingRenderer.augmentValue(seed: seed, variant: variant)
        let slotAssignments = C5TrainingRenderer.slotAssignments(
            seed: seed,
            variant: variant,
            value: valueAugmentation.value,
            scopeCandidatesBySlot: scopeCandidatesBySlot,
            scopeCandidatesByDeviceSlot: scopeCandidatesByDeviceSlot
        )
        // paradigm §1 surface 分流: dDomain→具名工具(name=intent, value 形态编码进名) / frame→旧 generic(strangler 保留)。
        let call: C5TrainingToolCall
        let resolvedTools: [[String: JSONValue]]
        let distractorIDs: [String]
        let subsetPolicyID: String?
        let subsetGroupID: String?
        let mountedToolCount: Int?
        let subsetPolicyDigest: String?
        if surface == .dDomain, !catalog.isEmpty {
            // 🔴 P1(GPT Pro+GLM 审计共识): catalog 非空但 intent 缺失 = 铁律5 fail-CLOSED(skip 返 nil, 不 fallback frame 污染 A2 surface);
            // scope filter 已保证命中, 此分支是 defensive。旧实现 stderr+frame fallback 会让 dDomain 调用者误以为产 D-domain 实混入 frame。
            guard let entry = catalogByName[seed.intent] else {
                appendUnique("ddomain_catalog_target_missing", to: &failureReceipt)
                FileHandle.standardError.write(Data("S4_DDOMAIN_MISS intent=\(seed.intent) not in catalog(\(catalog.count)) — fail-closed skip(不 fallback frame), scope filter should prevent\n".utf8))
                return nil
            }
            guard let subsetManifest else {
                appendUnique("subset_manifest_missing", to: &failureReceipt)
                FileHandle.standardError.write(Data("G7D_SUBSET_MANIFEST_MISSING intent=\(seed.intent) — fail-closed skip\n".utf8))
                return nil
            }
            guard let subsetEntry = subsetManifest.singleGroupEntriesByToolID[seed.intent] else {
                appendUnique("subset_manifest_target_missing", to: &failureReceipt)
                FileHandle.standardError.write(Data("G7D_SUBSET_TARGET_MISS intent=\(seed.intent) — fail-closed skip\n".utf8))
                return nil
            }
            guard subsetEntry.distractorPolicy.strategy == "same_sg_then_same_domain_then_other" else {
                appendUnique("subset_manifest_distractor_policy_unsupported", to: &failureReceipt)
                FileHandle.standardError.write(Data("G7D_SUBSET_DISTRACTOR_POLICY_UNSUPPORTED intent=\(seed.intent) strategy=\(subsetEntry.distractorPolicy.strategy) — fail-closed skip\n".utf8))
                return nil
            }
            var manifestMountedEntries: [DDomainToolEntry] = []
            for toolID in subsetEntry.toolIDsOrdered {
                guard let mountedEntry = catalogByName[toolID] else {
                    appendUnique("subset_manifest_catalog_mismatch", to: &failureReceipt)
                    FileHandle.standardError.write(Data("G7D_SUBSET_MOUNT_MISS group=\(subsetEntry.groupID) tool=\(toolID) — fail-closed skip\n".utf8))
                    return nil
                }
                manifestMountedEntries.append(mountedEntry)
            }
            call = C5TrainingToolCall(
                name: seed.intent,
                arguments: C5TrainingRenderer.dDomainToolCallArguments(seed: seed, value: valueAugmentation.value, slotAssignments: slotAssignments, toolEntry: entry, variant: variant)
            )
            let mountedEntries = degradedMountedEntriesIfNeeded(
                target: entry,
                manifestEntries: manifestMountedEntries,
                subsetEntry: subsetEntry
            )
            resolvedTools = mountedEntries.map(C5TrainingRenderer.dDomainToolSchema)
            if mountedEntries.count < manifestMountedEntries.count {
                distractorIDs = mountedEntries
                    .map(\.function.name)
                    .filter { $0 != entry.function.name }
            } else {
                distractorIDs = manifestDistractorIDs(
                    target: entry,
                    catalog: catalog,
                    variant: variant,
                    policy: subsetEntry.distractorPolicy
                )
            }
            subsetPolicyID = subsetEntry.subsetPolicyID.isEmpty ? subsetManifest.policyID : subsetEntry.subsetPolicyID
            subsetGroupID = subsetEntry.groupID
            mountedToolCount = resolvedTools.count
            subsetPolicyDigest = subsetManifest.digest
        } else {
            // frame legacy(catalog 空 OR surface=.frame): strangler 向后兼容(唯一 frame 入口, 非 dDomain miss fallback)
            call = C5TrainingToolCall(
                name: "tool_call_frame",
                arguments: C5TrainingRenderer.toolCallArguments(
                    seed: seed,
                    value: valueAugmentation.value,
                    slotAssignments: slotAssignments,
                    scopeCandidatesBySlot: scopeCandidatesBySlot,
                    scopeCandidatesByDeviceSlot: scopeCandidatesByDeviceSlot
                )
            )
            let distractors = C5TrainingRenderer.distractorToolSchemas(variant: variant)
            resolvedTools = C5TrainingRenderer.toolCallFrameToolSchema(seeds: [seed]) + distractors.schemas
            distractorIDs = distractors.ids
            subsetPolicyID = nil
            subsetGroupID = nil
            mountedToolCount = nil
            subsetPolicyDigest = nil
        }
        let renderedToolCall: String
        let finalCall = call
        if let naturalToolCallRecord {
            guard let parsed = C5TrainingRenderer.parseRenderedToolCall(naturalToolCallRecord.target), parsed == call else {
                appendUnique("natural_tool_call_target_mismatch", to: &failureReceipt)
                return nil
            }
        }
        renderedToolCall = C5TrainingRenderer.renderToolCall(call)
        let assistant = "\n\n" + renderedToolCall
        let localUtterance = C5TrainingRenderer.renderUserUtterance(seed: seed, variant: variant, valueText: valueAugmentation.utteranceValueText, slotAssignments: slotAssignments)
        let utterance = naturalToolCallRecord?.user ?? generatedRecord?.utterance ?? localUtterance
        let promptHash: String
        if let naturalToolCallRecord, !naturalToolCallRecord.promptHash.isEmpty {
            promptHash = naturalToolCallRecord.promptHash
        } else if generatedRecord?.promptHash.isEmpty == false {
            promptHash = generatedRecord?.promptHash ?? ""
        } else {
            promptHash = C5DerivedHashRecipe.promptHash(utterance: utterance)
        }
        let candidateParentSemanticID = C5TrainingRenderer.candidateParentSemanticID(userUtterance: utterance, renderedToolCall: renderedToolCall)
        let augmentationProfile = C5AugmentationProfile(
            functionName: !distractorIDs.isEmpty,
            argumentName: !distractorIDs.isEmpty,
            argumentValue: valueAugmentation.didAugment
        )
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
            device: seed.device,
            expectedToolCallSignature: C5DerivedHashRecipe.expectedToolCallSignature(renderedToolCall: renderedToolCall),
            routeTierSource: "route_deriver_v2_fc_flags_value_type",
            routeTier: seed.routeTier,
            executionTier: seed.execTier,
            utteranceSource: generatedRecord == nil && naturalToolCallRecord == nil ? .singleTurnSeed : .llmAugmented,
            valueStrategy: seed.valueStrategy,
            lossObjectiveProfile: .assistantFullExceptThink,
            augmentationProfile: augmentationProfile,
            maskingStage: maskingStage,
            trainEligible: maskingStage.trainEligible,
            masking: C5MaskingFlags(
                functionName: augmentationProfile.functionName,
                argumentName: augmentationProfile.argumentName,
                argumentValue: augmentationProfile.argumentValue,
                trainOnTurn: maskingStage != .smokeOnly
            ),
            acceptanceStage: maskingStage == .smokeOnly ? .trainHealth : .trainableV0,
            generatorModelID: naturalToolCallRecord?.generatorModelID ?? generatedRecord?.generatorModelID ?? "deterministic_semantic_protocol_v1",
            generatorSourceVendor: naturalToolCallRecord?.generatorSourceVendor ?? generatedRecord?.generatorSourceVendor,
            generatorCallID: naturalToolCallRecord?.generatorCallID ?? generatedRecord?.generatorCallID ?? "local-contract-\(seed.contractRowID)-v\(variant)",
            semanticJudgeModelID: naturalToolCallRecord?.semanticJudgeModelID ?? generatedRecord?.semanticJudgeModelID ?? "",
            semanticJudgeCallID: naturalToolCallRecord?.semanticJudgeCallID ?? generatedRecord?.semanticJudgeCallID ?? "",
            promptHash: promptHash,
            messages: [
                C5TrainingMessage(role: "system", content: "你是 MAformac 离线 mock 车控演示助手。控制路径只输出 tool_call 包裹或 NO_TOOL。"),
                C5TrainingMessage(role: "user", content: utterance),
                C5TrainingMessage(role: "assistant", content: assistant)
            ],
            tools: resolvedTools,
            expectedToolCalls: [finalCall],
            noCall: nil,
            promptDistractorToolIDs: distractorIDs,
            subsetPolicyID: subsetPolicyID,
            subsetGroupID: subsetGroupID,
            mountedToolCount: mountedToolCount,
            subsetPolicyDigest: subsetPolicyDigest
        )
    }

    private func degradedMountedEntriesIfNeeded(
        target: DDomainToolEntry,
        manifestEntries: [DDomainToolEntry],
        subsetEntry: C5SubsetPolicyManifest.Entry
    ) -> [DDomainToolEntry] {
        guard subsetEntry.groupID == "seat.massage_force_time" else {
            return manifestEntries
        }
        guard let targetEntry = manifestEntries.first(where: { $0.function.name == target.function.name }) else {
            return manifestEntries
        }
        guard let firstSibling = manifestEntries.first(where: { $0.function.name != target.function.name }) else {
            return [targetEntry]
        }
        return [targetEntry, firstSibling]
    }

    private func manifestDistractorIDs(
        target: DDomainToolEntry,
        catalog: [DDomainToolEntry],
        variant: Int,
        policy: C5SubsetPolicyManifest.DistractorPolicy
    ) -> [String] {
        let pool = catalog.filter { $0.function.name != target.function.name }
        guard !pool.isEmpty, policy.k > 0 else {
            return []
        }
        let sameGroup = pool.filter { $0.sg == target.sg }.sorted { $0.function.name < $1.function.name }
        let sameDomain = pool.filter { $0.sg != target.sg && $0.domain == target.domain }.sorted { $0.function.name < $1.function.name }
        let others = pool.filter { $0.domain != target.domain }.sorted { $0.function.name < $1.function.name }
        let ranked = sameGroup + sameDomain + others
        guard !ranked.isEmpty else {
            return []
        }
        var picked: [String] = []
        var idx = variant % ranked.count
        var guardCounter = 0
        while picked.count < min(policy.k, ranked.count) && guardCounter < ranked.count * 2 {
            let name = ranked[idx % ranked.count].function.name
            if !picked.contains(name) {
                picked.append(name)
            }
            idx += 1
            guardCounter += 1
        }
        return picked
    }
}

enum C5CanonicalJSONObject {
    static func render(_ object: [String: JSONValue]) -> String {
        let keys = object.keys.sorted()
        let body = keys.map { key in
            "\"\(escape(key))\":\(renderValue(object[key] ?? .null))"
        }.joined(separator: ",")
        return "{\(body)}"
    }

    static func renderOrdered(_ pairs: [(String, JSONValue)]) -> String {
        let body = pairs.map { key, value in
            "\"\(escape(key))\":\(renderValue(value))"
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
