import Foundation

public struct C5DataGateCandidate: Codable, Sendable {
    public var sampleID: String
    public var split: String?
    public var bucket: String
    public var caseID: String?
    public var parentSemanticID: String?
    public var candidateParentSemanticID: String?
    public var device: String?
    public var toolName: String?
    public var valueType: String?
    public var templateFamily: String?
    public var generatorSource: String?
    public var generatorModelID: String?
    public var generatorSourceVendor: String?
    public var mustNotTrain: Bool
    public var sourceAuthorization: String?
    public var inputText: String
    public var assistantText: String
    public var hasActionToolCall: Bool
    public var hasSharedWrapper: Bool
    public var masking: C5MaskingFlags
    public var tools: [[String: JSONValue]]
    public var mountedToolCount: Int?
    public var subsetPolicyID: String?
    public var subsetGroupID: String?
    public var subsetPolicyDigest: String?
    public var toolSchemaDigest: String?
    public var promptHash: String?
    public var expectedToolCallSignature: String?
    public var hashRecipeRef: String?
    public var hashRecomputedByPipeline: Bool?
    public var renderedToolCall: String?

    enum CodingKeys: String, CodingKey {
        case sampleID = "sample_id"
        case split
        case bucket
        case datasetBucket = "dataset_bucket"
        case caseID = "case_id"
        case parentSemanticID = "parent_semantic_id"
        case candidateParentSemanticID = "candidate_parent_semantic_id"
        case parentID = "parent_id"
        case scenarioFamilyID = "scenario_family_id"
        case device
        case toolName = "tool_name"
        case valueType = "value_type"
        case templateFamily = "template_family"
        case generatorSource = "generator_source"
        case generatorModelID = "generator_model_id"
        case generatorSourceVendor = "generator_source_vendor"
        case value
        case mustNotTrain = "must_not_train"
        case sourceAuthorization = "source_authorization"
        case inputText = "input_text"
        case assistantText = "assistant_text"
        case hasActionToolCall = "has_action_tool_call"
        case hasSharedWrapper = "has_shared_wrapper"
        case inputZh = "input_zh"
        case utterance
        case queryTemplate = "query_template"
        case messages
        case toolCall = "tool_call"
        case expectedToolCalls = "expected_tool_calls"
        case expected
        case masking
        case tools
        case mountedToolCount = "mounted_tool_count"
        case subsetPolicyID = "subset_policy_id"
        case subsetGroupID = "subset_group_id"
        case subsetPolicyDigest = "subset_policy_digest"
        case toolSchemaDigest = "tool_schema_digest"
        case promptHash = "prompt_hash"
        case expectedToolCallSignature = "expected_tool_call_signature"
        case hashRecipeRef = "hash_recipe_ref"
        case hashRecomputedByPipeline = "hash_recomputed_by_pipeline"
        case renderedToolCall = "rendered_tool_call"
    }

    public init(
        sampleID: String,
        split: String?,
        bucket: String,
        caseID: String?,
        parentSemanticID: String?,
        candidateParentSemanticID: String? = nil,
        device: String? = nil,
        toolName: String? = nil,
        valueType: String? = nil,
        templateFamily: String? = nil,
        generatorSource: String? = nil,
        generatorModelID: String? = nil,
        generatorSourceVendor: String? = nil,
        mustNotTrain: Bool,
        sourceAuthorization: String?,
        inputText: String,
        assistantText: String,
        hasActionToolCall: Bool,
        hasSharedWrapper: Bool,
        masking: C5MaskingFlags,
        tools: [[String: JSONValue]] = [],
        mountedToolCount: Int? = nil,
        subsetPolicyID: String? = nil,
        subsetGroupID: String? = nil,
        subsetPolicyDigest: String? = nil,
        toolSchemaDigest: String? = nil,
        promptHash: String? = nil,
        expectedToolCallSignature: String? = nil,
        hashRecipeRef: String? = nil,
        hashRecomputedByPipeline: Bool? = nil,
        renderedToolCall: String? = nil
    ) {
        self.sampleID = sampleID
        self.split = split
        self.bucket = bucket
        self.caseID = caseID
        self.parentSemanticID = parentSemanticID
        self.candidateParentSemanticID = candidateParentSemanticID
        self.device = device
        self.toolName = toolName
        self.valueType = valueType
        self.templateFamily = templateFamily
        self.generatorModelID = generatorModelID
        self.generatorSourceVendor = Self.canonicalGeneratorSourceVendor(
            vendor: generatorSourceVendor,
            source: generatorSource,
            modelID: generatorModelID
        )
        self.generatorSource = self.generatorSourceVendor
        self.mustNotTrain = mustNotTrain
        self.sourceAuthorization = sourceAuthorization
        self.inputText = inputText
        self.assistantText = assistantText
        self.hasActionToolCall = hasActionToolCall
        self.hasSharedWrapper = hasSharedWrapper
        self.masking = masking
        self.tools = tools
        self.mountedToolCount = mountedToolCount
        self.subsetPolicyID = subsetPolicyID
        self.subsetGroupID = subsetGroupID
        self.subsetPolicyDigest = subsetPolicyDigest
        self.toolSchemaDigest = toolSchemaDigest
        self.promptHash = promptHash
        self.expectedToolCallSignature = expectedToolCallSignature
        self.hashRecipeRef = hashRecipeRef
        self.hashRecomputedByPipeline = hashRecomputedByPipeline
        self.renderedToolCall = renderedToolCall
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let caseID = try container.decodeIfPresent(String.self, forKey: .caseID)
        let sampleID = try container.decodeIfPresent(String.self, forKey: .sampleID)
            ?? caseID
            ?? UUID().uuidString
        let bucket = try container.decodeIfPresent(String.self, forKey: .bucket)
            ?? container.decodeIfPresent(String.self, forKey: .datasetBucket)
            ?? "unknown"
        let messages = try container.decodeIfPresent([C5ChatMessage].self, forKey: .messages) ?? []
        let assistantText = messages.last { $0.role == "assistant" }?.content ?? ""
        let toolCall = try container.decodeIfPresent(C5InlineToolCall.self, forKey: .toolCall)
        let expectedToolCalls = try container.decodeIfPresent([C5ExpectedToolCall].self, forKey: .expectedToolCalls)
            ?? C5LegacyExpected.decode(from: container)
        let decodedAssistantText = try container.decodeIfPresent(String.self, forKey: .assistantText) ?? assistantText
        let explicitWrapper = toolCall?.wrapper == "tool_call"
        self.sampleID = sampleID
        self.split = try container.decodeIfPresent(String.self, forKey: .split)
        self.bucket = bucket
        self.caseID = caseID
        self.parentSemanticID = try container.decodeIfPresent(String.self, forKey: .parentSemanticID)
            ?? container.decodeIfPresent(String.self, forKey: .parentID)
            ?? container.decodeIfPresent(String.self, forKey: .scenarioFamilyID)
        self.candidateParentSemanticID = try container.decodeIfPresent(String.self, forKey: .candidateParentSemanticID)
        self.device = try container.decodeIfPresent(String.self, forKey: .device)
        self.toolName = try container.decodeIfPresent(String.self, forKey: .toolName)
            ?? toolCall?.name
            ?? expectedToolCalls?.compactMap { $0.toolName ?? $0.name }.first
        self.valueType = try container.decodeIfPresent(String.self, forKey: .valueType)
            ?? container.decodeIfPresent(C5DataGateCandidateValue.self, forKey: .value)?.type
        self.templateFamily = try container.decodeIfPresent(String.self, forKey: .templateFamily)
        let generatorSource = try container.decodeIfPresent(String.self, forKey: .generatorSource)
        let generatorModelID = try container.decodeIfPresent(String.self, forKey: .generatorModelID)
        let generatorSourceVendor = try container.decodeIfPresent(String.self, forKey: .generatorSourceVendor)
        self.generatorModelID = generatorModelID
        self.generatorSourceVendor = Self.canonicalGeneratorSourceVendor(
            vendor: generatorSourceVendor,
            source: generatorSource,
            modelID: generatorModelID
        )
        self.generatorSource = self.generatorSourceVendor
        self.mustNotTrain = try container.decodeIfPresent(Bool.self, forKey: .mustNotTrain) ?? false
        self.sourceAuthorization = try container.decodeIfPresent(String.self, forKey: .sourceAuthorization)
        self.inputText = try container.decodeIfPresent(String.self, forKey: .inputText)
            ?? container.decodeIfPresent(String.self, forKey: .inputZh)
            ?? container.decodeIfPresent(String.self, forKey: .utterance)
            ?? container.decodeIfPresent(String.self, forKey: .queryTemplate)
            ?? messages.first { $0.role == "user" }?.content
            ?? ""
        self.assistantText = decodedAssistantText
        self.hasActionToolCall = try container.decodeIfPresent(Bool.self, forKey: .hasActionToolCall)
            ?? (!(expectedToolCalls ?? []).isEmpty || toolCall != nil)
        self.hasSharedWrapper = try container.decodeIfPresent(Bool.self, forKey: .hasSharedWrapper)
            ?? (explicitWrapper || assistantText.contains("<tool_call>"))
        self.masking = (try container.decodeIfPresent(C5MaskingFlags.self, forKey: .masking)) ?? C5MaskingFlags()
        self.tools = try container.decodeIfPresent([[String: JSONValue]].self, forKey: .tools) ?? []
        self.mountedToolCount = try container.decodeIfPresent(Int.self, forKey: .mountedToolCount)
        self.subsetPolicyID = try container.decodeIfPresent(String.self, forKey: .subsetPolicyID)
        self.subsetGroupID = try container.decodeIfPresent(String.self, forKey: .subsetGroupID)
        self.subsetPolicyDigest = try container.decodeIfPresent(String.self, forKey: .subsetPolicyDigest)
        self.toolSchemaDigest = try container.decodeIfPresent(String.self, forKey: .toolSchemaDigest)
        self.promptHash = try container.decodeIfPresent(String.self, forKey: .promptHash)
        self.expectedToolCallSignature = try container.decodeIfPresent(String.self, forKey: .expectedToolCallSignature)
        self.hashRecipeRef = try container.decodeIfPresent(String.self, forKey: .hashRecipeRef)
        self.hashRecomputedByPipeline = try container.decodeIfPresent(Bool.self, forKey: .hashRecomputedByPipeline)
        self.renderedToolCall = try container.decodeIfPresent(String.self, forKey: .renderedToolCall)
            ?? toolCall?.renderedToolCall
            ?? expectedToolCalls?.first?.renderedToolCall
            ?? C5DerivedHashRecipe.firstRenderedToolCall(in: decodedAssistantText)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sampleID, forKey: .sampleID)
        try container.encodeIfPresent(split, forKey: .split)
        try container.encode(bucket, forKey: .bucket)
        try container.encodeIfPresent(caseID, forKey: .caseID)
        try container.encodeIfPresent(parentSemanticID, forKey: .parentSemanticID)
        try container.encodeIfPresent(candidateParentSemanticID, forKey: .candidateParentSemanticID)
        try container.encodeIfPresent(device, forKey: .device)
        try container.encodeIfPresent(toolName, forKey: .toolName)
        try container.encodeIfPresent(valueType, forKey: .valueType)
        try container.encodeIfPresent(templateFamily, forKey: .templateFamily)
        try container.encodeIfPresent(generatorSource, forKey: .generatorSource)
        try container.encodeIfPresent(generatorModelID, forKey: .generatorModelID)
        try container.encodeIfPresent(generatorSourceVendor, forKey: .generatorSourceVendor)
        try container.encode(mustNotTrain, forKey: .mustNotTrain)
        try container.encodeIfPresent(sourceAuthorization, forKey: .sourceAuthorization)
        try container.encode(inputText, forKey: .inputText)
        try container.encode(assistantText, forKey: .assistantText)
        try container.encode(hasActionToolCall, forKey: .hasActionToolCall)
        try container.encode(hasSharedWrapper, forKey: .hasSharedWrapper)
        try container.encode(masking, forKey: .masking)
        try container.encode(tools, forKey: .tools)
        try container.encodeIfPresent(mountedToolCount, forKey: .mountedToolCount)
        try container.encodeIfPresent(subsetPolicyID, forKey: .subsetPolicyID)
        try container.encodeIfPresent(subsetGroupID, forKey: .subsetGroupID)
        try container.encodeIfPresent(subsetPolicyDigest, forKey: .subsetPolicyDigest)
        try container.encodeIfPresent(toolSchemaDigest, forKey: .toolSchemaDigest)
        try container.encodeIfPresent(promptHash, forKey: .promptHash)
        try container.encodeIfPresent(expectedToolCallSignature, forKey: .expectedToolCallSignature)
        try container.encodeIfPresent(hashRecipeRef, forKey: .hashRecipeRef)
        try container.encodeIfPresent(hashRecomputedByPipeline, forKey: .hashRecomputedByPipeline)
        try container.encodeIfPresent(renderedToolCall, forKey: .renderedToolCall)
    }

    public var overlapParentSemanticID: String? {
        candidateParentSemanticID ?? parentSemanticID
    }

    private static func canonicalGeneratorSourceVendor(vendor: String?, source: String?, modelID: String?) -> String? {
        let raw = [vendor, source, modelID]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty }
            .first
        guard let raw else {
            return nil
        }
        let normalized = raw.lowercased().replacingOccurrences(of: "-", with: "_")
        if normalized.contains("claude") || normalized.contains("anthropic") {
            return "Anthropic"
        }
        if normalized.contains("gpt") || normalized.contains("openai") || normalized.contains("codex") {
            return "OpenAI"
        }
        if normalized.contains("volc") || normalized.contains("twofish") || normalized.contains("hermes") || normalized.contains("ark") {
            return "Volc-twofish"
        }
        return raw
    }
}

public struct C5MaskingFlags: Codable, Equatable, Sendable {
    public var functionName: Bool
    public var argumentName: Bool
    public var argumentValue: Bool
    public var trainOnTurn: Bool

    enum CodingKeys: String, CodingKey {
        case functionName = "function_name"
        case argumentName = "argument_name"
        case argumentValue = "argument_value"
        case trainOnTurn = "train_on_turn"
    }

    public init(
        functionName: Bool = false,
        argumentName: Bool = false,
        argumentValue: Bool = false,
        trainOnTurn: Bool = false
    ) {
        self.functionName = functionName
        self.argumentName = argumentName
        self.argumentValue = argumentValue
        self.trainOnTurn = trainOnTurn
    }
}

public struct C5DataGateRunContext: Sendable {
    public var sourceSnapshotDigest: String
    public var sourceAuthorizationStatus: String
    public var formatContractVersion: String
    public var generatedAt: String
    public var allowLegacyMissingSurface: Bool
    public var surfaceManifest: C5DataGateSurfaceManifest?

    public init(
        sourceSnapshotDigest: String,
        sourceAuthorizationStatus: String,
        formatContractVersion: String,
        generatedAt: String,
        allowLegacyMissingSurface: Bool = false,
        surfaceManifest: C5DataGateSurfaceManifest? = nil
    ) {
        self.sourceSnapshotDigest = sourceSnapshotDigest
        self.sourceAuthorizationStatus = sourceAuthorizationStatus
        self.formatContractVersion = formatContractVersion
        self.generatedAt = generatedAt
        self.allowLegacyMissingSurface = allowLegacyMissingSurface
        self.surfaceManifest = surfaceManifest
    }
}

public struct C5DataGateSurfaceManifest: Equatable, Sendable {
    public var manifestFileDigest: String
    public var groupingContractDigest: String?
    public var entries: [C5DataGateSurfaceManifestEntry]
    public var toolSchemasByName: [String: [String: JSONValue]]

    public init(
        manifestFileDigest: String,
        groupingContractDigest: String? = nil,
        entries: [C5DataGateSurfaceManifestEntry],
        toolSchemasByName: [String: [String: JSONValue]] = [:]
    ) {
        self.manifestFileDigest = manifestFileDigest
        self.groupingContractDigest = groupingContractDigest
        self.entries = entries
        self.toolSchemasByName = toolSchemasByName
    }
}

public struct C5DataGateSurfaceManifestEntry: Equatable, Sendable {
    public var subsetPolicyID: String
    public var subsetGroupID: String
    public var toolIDsOrdered: [String]
    public var toolSchemaDigest: String

    public init(
        subsetPolicyID: String,
        subsetGroupID: String,
        toolIDsOrdered: [String],
        toolSchemaDigest: String
    ) {
        self.subsetPolicyID = subsetPolicyID
        self.subsetGroupID = subsetGroupID
        self.toolIDsOrdered = toolIDsOrdered
        self.toolSchemaDigest = toolSchemaDigest
    }
}

public struct C5DataGateReceipt: Codable, Equatable, Sendable {
    public var receiptVersion: String
    public var generatedAt: String
    public var status: String
    public var sourceSnapshotDigest: String
    public var sourceAuthorizationStatus: String
    public var formatContractVersion: String
    public var rowCount: Int
    public var bucketCounts: [String: Int]
    public var splitWhitelist: [String]
    public var mustNotTrainViolations: Int
    public var detectedParentSemanticOverlapCount: Int
    public var trainParentSemanticOverlap: Int
    public var heldOutAxisOverlaps: [C5HeldOutAxisOverlap]?
    public var trainHeldOutAxisOverlapCount: Int?
    public var trainHeldOutAxisOverlapRowCount: Int?
    public var toolCallFormatPass: Int
    public var toolCallFormatFailures: [C5DataGateFailure]
    public var allowLegacyMissingSurface: Bool?
    public var missingSurfaceCount: Int?
    public var legacyMissingSurfaceAllowedCount: Int?
    public var surfaceFieldPass: Int?
    public var maskingCoverage: C5MaskingCoverage
    public var redactionStatus: String
    public var quarantineCount: Int
    public var failureReceipt: [C5DataGateFailure]
    public var proposedFix: C5ProposedFix

    enum CodingKeys: String, CodingKey {
        case receiptVersion = "receipt_version"
        case generatedAt = "generated_at"
        case status
        case sourceSnapshotDigest = "source_snapshot_digest"
        case sourceAuthorizationStatus = "source_authorization_status"
        case formatContractVersion = "format_contract_version"
        case rowCount = "row_count"
        case bucketCounts = "bucket_counts"
        case splitWhitelist = "split_whitelist"
        case mustNotTrainViolations = "must_not_train_violations"
        case detectedParentSemanticOverlapCount = "detected_parent_semantic_overlap_count"
        case trainParentSemanticOverlap = "train_parent_semantic_overlap"
        case heldOutAxisOverlaps = "held_out_axis_overlaps"
        case trainHeldOutAxisOverlapCount = "train_held_out_axis_overlap_count"
        case trainHeldOutAxisOverlapRowCount = "train_held_out_axis_overlap_row_count"
        case toolCallFormatPass = "tool_call_format_pass"
        case toolCallFormatFailures = "tool_call_format_failures"
        case allowLegacyMissingSurface = "allow_legacy_missing_surface"
        case missingSurfaceCount = "missing_surface_count"
        case legacyMissingSurfaceAllowedCount = "legacy_missing_surface_allowed_count"
        case surfaceFieldPass = "surface_field_pass"
        case maskingCoverage = "masking_coverage"
        case redactionStatus = "redaction_status"
        case quarantineCount = "quarantine_count"
        case failureReceipt = "failure_receipt"
        case proposedFix = "proposed_fix"
    }

    public var hasHardFailure: Bool {
        mustNotTrainViolations > 0
            || trainParentSemanticOverlap > 0
            || (trainHeldOutAxisOverlapCount ?? 0) > 0
            || (trainHeldOutAxisOverlapRowCount ?? 0) > 0
            || !toolCallFormatFailures.isEmpty
            || failureReceipt.contains { $0.reason == "missing_candidate_surface_fields" }
            || failureReceipt.contains { isSurfaceFailureReason($0.reason) }
            || failureReceipt.contains { $0.reason == "missing_train_device_axis_for_six_axis_split" }
            || redactionStatus == "fail"
    }

    private func isSurfaceFailureReason(_ reason: String) -> Bool {
        reason.hasPrefix("candidate_surface_")
            || reason.hasPrefix("subset_manifest_")
            || reason.hasSuffix("_manifest_mismatch")
            || reason.hasSuffix("_digest_mismatch")
            || reason == "tool_name_not_mounted"
            || reason == "duplicate_mounted_tool_name"
    }
}

public enum C5HeldOutOverlapAxis: String, CaseIterable, Codable, Sendable {
    case parentSemanticID = "parent_semantic_id"
    case device
    case toolName = "tool_name"
    case valueType = "value_type"
    case templateFamily = "template_family"
    case generatorSource = "generator_source"

    var failureReason: String {
        switch self {
        case .parentSemanticID:
            return "train_parent_semantic_overlap"
        case .device:
            return "train_device_overlap"
        case .toolName:
            return "train_tool_overlap"
        case .valueType:
            return "train_value_type_overlap"
        case .templateFamily:
            return "train_template_family_overlap"
        case .generatorSource:
            return "train_generator_source_overlap"
        }
    }

    func value(in candidate: C5DataGateCandidate) -> String? {
        let raw: String?
        switch self {
        case .parentSemanticID:
            raw = candidate.overlapParentSemanticID
        case .device:
            raw = candidate.device
        case .toolName:
            raw = candidate.toolName
        case .valueType:
            raw = candidate.valueType
        case .templateFamily:
            raw = candidate.templateFamily
        case .generatorSource:
            raw = candidate.generatorSource
        }
        return raw?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
    }
}

public struct C5HeldOutAxisOverlap: Codable, Equatable, Sendable {
    public var axis: String
    public var trainOverlapCount: Int
    public var overlappingValues: [String]

    enum CodingKeys: String, CodingKey {
        case axis
        case trainOverlapCount = "train_overlap_count"
        case overlappingValues = "overlapping_values"
    }
}

public struct C5MaskingCoverage: Codable, Equatable, Sendable {
    public var functionName: Bool
    public var argumentName: Bool
    public var argumentValue: Bool
    public var trainOnTurn: Bool

    enum CodingKeys: String, CodingKey {
        case functionName = "function_name"
        case argumentName = "argument_name"
        case argumentValue = "argument_value"
        case trainOnTurn = "train_on_turn"
    }
}

public struct C5DataGateFailure: Codable, Equatable, Sendable {
    public var sampleID: String
    public var caseID: String?
    public var split: String
    public var bucket: String
    public var parentSemanticID: String?
    public var reason: String
    public var severity: String

    enum CodingKeys: String, CodingKey {
        case sampleID = "sample_id"
        case caseID = "case_id"
        case split
        case bucket
        case parentSemanticID = "parent_semantic_id"
        case reason
        case severity
    }
}

public struct C5ProposedFix: Codable, Equatable, Sendable {
    public var autoApply: Bool
    public var suggestions: [String]

    enum CodingKeys: String, CodingKey {
        case autoApply = "auto_apply"
        case suggestions
    }
}

public struct C5DataGateValidator: Sendable {
    public static let splitWhitelist = ["train", "heldout", "must_pass", "c6_base", "dev_selection", "quarantine"]
    public static let heldOutOverlapAxes = C5HeldOutOverlapAxis.allCases

    public init() {}

    public func receipt(
        candidates: [C5DataGateCandidate],
        c6Cases: [C6BenchCase],
        context: C5DataGateRunContext
    ) -> C5DataGateReceipt {
        let protectedCaseIDs = Set(c6Cases.filter { $0.tags.mustPass || $0.tags.mustNotTrain }.map(\.caseID))
        let protectedParents = Set(c6Cases.filter { $0.tags.mustPass || $0.tags.mustNotTrain }.flatMap(\.sourceRefs.semanticContractIDs))
        let normalized = candidates.map { NormalizedCandidate(candidate: $0, split: normalizedSplit($0)) }
        let nonTrainParents = Set(normalized.filter { $0.split != "train" && $0.split != "dev_selection" && $0.split != "quarantine" }.compactMap(\.candidate.overlapParentSemanticID))
            .union(protectedParents)
        let trainOverlapParents = Set(normalized.filter { $0.split == "train" }.compactMap(\.candidate.overlapParentSemanticID))
            .intersection(nonTrainParents)
        let heldOutAxisOverlaps = Self.heldOutOverlapAxes.map {
            axisOverlap(axis: $0, normalized: normalized, protectedParents: protectedParents)
        }
        let trainHeldOutAxisOverlapCount = heldOutAxisOverlaps.reduce(0) { $0 + $1.trainOverlapCount }
        let heldOutOverlapByAxis = Dictionary(uniqueKeysWithValues: zip(Self.heldOutOverlapAxes, heldOutAxisOverlaps))
        let trainHeldOutAxisOverlapRowCount = normalized.filter { item in
            item.split == "train" && Self.heldOutOverlapAxes.contains { axis in
                guard let value = axis.value(in: item.candidate) else {
                    return false
                }
                return heldOutOverlapByAxis[axis]?.overlappingValues.contains(value) == true
            }
        }.count
        var failures: [C5DataGateFailure] = []
        var formatFailures: [C5DataGateFailure] = []
        var redactionFailures: [C5DataGateFailure] = []
        var missingAxisMetadataFailures: [C5DataGateFailure] = []
        var surfaceFailures: [C5DataGateFailure] = []
        var hashFailures: [C5DataGateFailure] = []
        var missingSurfaceCount = 0
        var legacyMissingSurfaceAllowedCount = 0
        var surfaceFieldPass = 0
        var mustNotTrainViolations = 0
        var toolCallFormatPass = 0
        var quarantineCount = 0

        for item in normalized {
            let candidate = item.candidate
            var isQuarantined = item.split == "quarantine"
            let missingSurfaceFields = missingSurfaceFields(candidate)
            if missingSurfaceFields.isEmpty {
                let semanticSurfaceFailures = semanticSurfaceFailures(candidate, context: context)
                if semanticSurfaceFailures.isEmpty {
                    surfaceFieldPass += 1
                } else {
                    for reason in semanticSurfaceFailures {
                        let itemFailure = failure(candidate, split: item.split, reason: reason, severity: "P1")
                        surfaceFailures.append(itemFailure)
                        failures.append(itemFailure)
                    }
                }
            } else {
                missingSurfaceCount += 1
                if context.allowLegacyMissingSurface {
                    legacyMissingSurfaceAllowedCount += 1
                } else {
                    let itemFailure = failure(candidate, split: item.split, reason: "missing_candidate_surface_fields", severity: "P1")
                    surfaceFailures.append(itemFailure)
                    failures.append(itemFailure)
                }
            }
            if item.split == "train" && (candidate.mustNotTrain || candidate.caseID.map(protectedCaseIDs.contains) == true) {
                mustNotTrainViolations += 1
                failures.append(failure(candidate, split: item.split, reason: "must_not_train_candidate_in_train", severity: "P0"))
            }
            if item.split == "train", let parent = candidate.overlapParentSemanticID, trainOverlapParents.contains(parent) {
                failures.append(failure(candidate, split: item.split, reason: "train_parent_semantic_overlap", severity: "P1"))
            }
            for axis in Self.heldOutOverlapAxes where axis != .parentSemanticID {
                guard item.split == "train",
                      let value = axis.value(in: candidate),
                      heldOutOverlapByAxis[axis]?.overlappingValues.contains(value) == true else {
                    continue
                }
                failures.append(failure(candidate, split: item.split, reason: axis.failureReason, severity: "P1"))
            }
            if item.split == "train" && candidate.overlapParentSemanticID == nil {
                failures.append(failure(candidate, split: item.split, reason: "missing_candidate_parent_semantic_id_for_train", severity: "P1"))
            }
            let hasSixAxisMetadata = [candidate.valueType, candidate.templateFamily, candidate.generatorSource].contains {
                $0?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty != nil
            }
            if item.split == "train" && hasSixAxisMetadata && candidate.device?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty == nil {
                let itemFailure = failure(candidate, split: item.split, reason: "missing_train_device_axis_for_six_axis_split", severity: "P1")
                missingAxisMetadataFailures.append(itemFailure)
                failures.append(itemFailure)
            }
            if item.split == "train" && candidate.hasActionToolCall {
                if candidate.hasSharedWrapper {
                    toolCallFormatPass += 1
                } else {
                    let itemFailure = failure(candidate, split: item.split, reason: "tool_call_format_mismatch", severity: "P1")
                    formatFailures.append(itemFailure)
                    failures.append(itemFailure)
                }
            }
            if !isValidSplit(item.split) {
                isQuarantined = true
                failures.append(failure(candidate, split: item.split, reason: "split_not_whitelisted", severity: "Important"))
            }
            if containsProhibitedText(candidate) {
                redactionFailures.append(failure(candidate, split: item.split, reason: "redaction_violation", severity: "P0"))
                failures.append(failure(candidate, split: item.split, reason: "redaction_violation", severity: "P0"))
            }
            if isQuarantined {
                quarantineCount += 1
            }
            for reason in hashConsistencyFailures(candidate) {
                let itemFailure = failure(candidate, split: item.split, reason: reason, severity: "P0")
                hashFailures.append(itemFailure)
                failures.append(itemFailure)
            }
        }

        let coverage = C5MaskingCoverage(
            functionName: candidates.contains { $0.masking.functionName },
            argumentName: candidates.contains { $0.masking.argumentName },
            argumentValue: candidates.contains { $0.masking.argumentValue },
            trainOnTurn: candidates.contains { $0.masking.trainOnTurn }
        )
        let sourceReady = !context.sourceSnapshotDigest.isEmpty
            && context.sourceAuthorizationStatus.contains("authorized")
            && !candidates.isEmpty
        let hardTrainOverlap = normalized.filter {
            $0.split == "train" && ($0.candidate.overlapParentSemanticID.map(trainOverlapParents.contains) == true)
        }.count
        let status: String
        if mustNotTrainViolations > 0 || hardTrainOverlap > 0 || trainHeldOutAxisOverlapCount > 0 || !formatFailures.isEmpty || !redactionFailures.isEmpty || !missingAxisMetadataFailures.isEmpty || !surfaceFailures.isEmpty || !hashFailures.isEmpty {
            status = "blocked"
        } else if sourceReady {
            status = "data_gate_ready"
        } else {
            status = "t_pass"
        }
        return C5DataGateReceipt(
            receiptVersion: "c5-data-gate.v1",
            generatedAt: context.generatedAt,
            status: status,
            sourceSnapshotDigest: context.sourceSnapshotDigest,
            sourceAuthorizationStatus: context.sourceAuthorizationStatus,
            formatContractVersion: context.formatContractVersion,
            rowCount: candidates.count,
            bucketCounts: Dictionary(grouping: normalized, by: { $0.split }).mapValues(\.count),
            splitWhitelist: Self.splitWhitelist,
            mustNotTrainViolations: mustNotTrainViolations,
            detectedParentSemanticOverlapCount: trainOverlapParents.count,
            trainParentSemanticOverlap: hardTrainOverlap,
            heldOutAxisOverlaps: heldOutAxisOverlaps,
            trainHeldOutAxisOverlapCount: trainHeldOutAxisOverlapCount,
            trainHeldOutAxisOverlapRowCount: trainHeldOutAxisOverlapRowCount,
            toolCallFormatPass: toolCallFormatPass,
            toolCallFormatFailures: formatFailures,
            allowLegacyMissingSurface: context.allowLegacyMissingSurface,
            missingSurfaceCount: missingSurfaceCount,
            legacyMissingSurfaceAllowedCount: legacyMissingSurfaceAllowedCount,
            surfaceFieldPass: surfaceFieldPass,
            maskingCoverage: coverage,
            redactionStatus: redactionFailures.isEmpty ? "pass" : "fail",
            quarantineCount: quarantineCount,
            failureReceipt: failures,
            proposedFix: C5ProposedFix(
                autoApply: false,
                suggestions: suggestedFixes(failures: failures, sourceReady: sourceReady)
            )
        )
    }

    public func renderMarkdown(_ receipt: C5DataGateReceipt) -> String {
        let suggestions = receipt.proposedFix.suggestions.isEmpty ? "[]" : receipt.proposedFix.suggestions.joined(separator: "; ")
        let failures = receipt.failureReceipt.isEmpty
            ? "none"
            : receipt.failureReceipt.map { "- [\($0.severity)] \($0.sampleID) split=\($0.split) bucket=\($0.bucket) reason=\($0.reason)" }.joined(separator: "\n")
        return """
        # C5 data gate receipt

        status: \(receipt.status)
        receipt_version: \(receipt.receiptVersion)
        generated_at: \(receipt.generatedAt)
        source_snapshot_digest: \(receipt.sourceSnapshotDigest)
        source_authorization_status: \(receipt.sourceAuthorizationStatus)
        format_contract_version: \(receipt.formatContractVersion)

        ## Counts
        - row_count: \(receipt.rowCount)
        - bucket_counts: \(receipt.bucketCounts.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))
        - quarantine_count: \(receipt.quarantineCount)
        - must_not_train_violations: \(receipt.mustNotTrainViolations)
        - detected_parent_semantic_overlap_count: \(receipt.detectedParentSemanticOverlapCount)
        - train_parent_semantic_overlap: \(receipt.trainParentSemanticOverlap)
        - train_held_out_axis_overlap_count: \(receipt.trainHeldOutAxisOverlapCount ?? 0)
        - train_held_out_axis_overlap_row_count: \(receipt.trainHeldOutAxisOverlapRowCount ?? 0)
        - tool_call_format_pass: \(receipt.toolCallFormatPass)
        - tool_call_format_failures: \(receipt.toolCallFormatFailures.count)
        - allow_legacy_missing_surface: \(receipt.allowLegacyMissingSurface == true)
        - missing_surface_count: \(receipt.missingSurfaceCount ?? 0)
        - legacy_missing_surface_allowed_count: \(receipt.legacyMissingSurfaceAllowedCount ?? 0)
        - surface_field_pass: \(receipt.surfaceFieldPass ?? 0)
        - redaction_status: \(receipt.redactionStatus)

        ## Masking coverage
        - function_name: \(receipt.maskingCoverage.functionName)
        - argument_name: \(receipt.maskingCoverage.argumentName)
        - argument_value: \(receipt.maskingCoverage.argumentValue)
        - train_on_turn: \(receipt.maskingCoverage.trainOnTurn)

        ## Proposed fix
        - auto_apply: \(receipt.proposedFix.autoApply)
        - suggestions: \(suggestions)

        ## Failures
        \(failures)
        """
    }

    private func normalizedSplit(_ candidate: C5DataGateCandidate) -> String {
        if let split = candidate.split {
            return split
        }
        let value = candidate.bucket
        if value == "train_candidate" || value == "train" || value.hasPrefix("positive") || value == "tool_call_wrapper_format" || value == "ambiguity" || value == "readback" || value == "no_think_formatting" || value == "unsafe" || value == "context" || value == "restraint_bare_json_negative" {
            return "train"
        }
        if value == "heldout_test_candidate" || value == "heldout_test" || value == "heldout" || value == "negative_eval" || value == "negative" {
            return "heldout"
        }
        if value == "acceptance_locked" || value == "acceptance" || value == "must_pass" {
            return "must_pass"
        }
        if value == "c6_base" {
            return "c6_base"
        }
        if value == "dev_selection" || value == "checkpoint_selection" {
            return "dev_selection"
        }
        return "quarantine"
    }

    private func isValidSplit(_ split: String) -> Bool {
        Self.splitWhitelist.contains(split)
    }

    private func axisOverlap(
        axis: C5HeldOutOverlapAxis,
        normalized: [NormalizedCandidate],
        protectedParents: Set<String>
    ) -> C5HeldOutAxisOverlap {
        let protectedSplits = normalized.filter {
            $0.split != "train" && $0.split != "dev_selection" && $0.split != "quarantine"
        }
        var protectedValues = Set(protectedSplits.compactMap { axis.value(in: $0.candidate) })
        if axis == .parentSemanticID {
            protectedValues.formUnion(protectedParents)
        }
        let overlappingValues = Set(normalized.filter { $0.split == "train" }.compactMap { axis.value(in: $0.candidate) })
            .intersection(protectedValues)
        let trainOverlapCount = normalized.filter {
            $0.split == "train" && (axis.value(in: $0.candidate).map(overlappingValues.contains) == true)
        }.count
        return C5HeldOutAxisOverlap(
            axis: axis.rawValue,
            trainOverlapCount: trainOverlapCount,
            overlappingValues: overlappingValues.sorted()
        )
    }

    private func failure(_ candidate: C5DataGateCandidate, split: String, reason: String, severity: String) -> C5DataGateFailure {
        C5DataGateFailure(
            sampleID: candidate.sampleID,
            caseID: candidate.caseID,
            split: split,
            bucket: candidate.bucket,
            parentSemanticID: candidate.overlapParentSemanticID ?? candidate.parentSemanticID,
            reason: reason,
            severity: severity
        )
    }

    private func containsProhibitedText(_ candidate: C5DataGateCandidate) -> Bool {
        let text = [candidate.inputText, candidate.assistantText].joined(separator: "\n")
        let prohibited = [
            "禁止外传",
            "对内",
            "报价",
            "成本",
            "身份证",
            "手机号",
            "api_key",
            "secret",
            "password"
        ]
        return prohibited.contains { text.localizedCaseInsensitiveContains($0) }
    }

    private func missingSurfaceFields(_ candidate: C5DataGateCandidate) -> [String] {
        var fields: [String] = []
        if candidate.tools.isEmpty {
            fields.append("tools")
        }
        if let mountedToolCount = candidate.mountedToolCount {
            if mountedToolCount != candidate.tools.count {
                fields.append("mounted_tool_count_mismatch")
            }
        } else {
            fields.append("mounted_tool_count")
        }
        if candidate.subsetPolicyID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty == nil {
            fields.append("subset_policy_id")
        }
        if candidate.subsetGroupID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty == nil {
            fields.append("subset_group_id")
        }
        if candidate.subsetPolicyDigest?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty == nil {
            fields.append("subset_policy_digest")
        }
        return fields
    }

    private func semanticSurfaceFailures(_ candidate: C5DataGateCandidate, context: C5DataGateRunContext) -> [String] {
        var reasons: [String] = []
        let mounted = mountedToolNames(candidate)
        reasons.append(contentsOf: mounted.reasons)
        if let mountedToolCount = candidate.mountedToolCount, mountedToolCount != mounted.names.count {
            reasons.append("candidate_surface_mounted_tool_count_mismatch")
        }
        if candidate.hasActionToolCall {
            guard let toolName = candidate.toolName?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty else {
                reasons.append("candidate_surface_missing_action_tool_name")
                return uniqueReasons(reasons)
            }
            if !mounted.names.contains(toolName) {
                reasons.append("tool_name_not_mounted")
            }
        }
        if let manifest = context.surfaceManifest {
            reasons.append(contentsOf: manifestSurfaceFailures(candidate, mountedToolNames: mounted.names, manifest: manifest))
        }
        return uniqueReasons(reasons)
    }

    private func mountedToolNames(_ candidate: C5DataGateCandidate) -> (names: [String], reasons: [String]) {
        var names: [String] = []
        var reasons: [String] = []
        for tool in candidate.tools {
            guard case .string("function")? = tool["type"],
                  case .object(let function)? = tool["function"],
                  case .string(let rawName)? = function["name"],
                  let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty else {
                reasons.append("candidate_surface_invalid_tool_schema")
                continue
            }
            names.append(name)
        }
        if Set(names).count != names.count {
            reasons.append("duplicate_mounted_tool_name")
        }
        return (names, reasons)
    }

    private func manifestSurfaceFailures(
        _ candidate: C5DataGateCandidate,
        mountedToolNames: [String],
        manifest: C5DataGateSurfaceManifest
    ) -> [String] {
        var reasons: [String] = []
        guard let subsetPolicyID = candidate.subsetPolicyID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
              let subsetGroupID = candidate.subsetGroupID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty else {
            return reasons
        }
        let entries = manifest.entries.filter {
            $0.subsetPolicyID == subsetPolicyID && $0.subsetGroupID == subsetGroupID
        }
        guard !entries.isEmpty else {
            return ["subset_manifest_entry_missing"]
        }
        guard let entry = entries.first else {
            return ["subset_manifest_entry_missing"]
        }
        let sourceToolNames = Set(entry.toolIDsOrdered)
        if !Set(mountedToolNames).isSubset(of: sourceToolNames) {
            reasons.append("mounted_tool_names_manifest_mismatch")
            return reasons
        }
        if let subsetPolicyDigest = candidate.subsetPolicyDigest?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty {
            let acceptedDigests = [manifest.manifestFileDigest, manifest.groupingContractDigest].compactMap { $0 }
            if !acceptedDigests.contains(subsetPolicyDigest) {
                reasons.append("subset_policy_digest_mismatch")
            }
        }
        if let toolSchemaDigest = candidate.toolSchemaDigest?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
           mountedToolNames == entry.toolIDsOrdered,
           toolSchemaDigest != entry.toolSchemaDigest {
            reasons.append("tool_schema_digest_mismatch")
        }
        if !manifest.toolSchemasByName.isEmpty {
            let expectedSchemas = mountedToolNames.compactMap { manifest.toolSchemasByName[$0] }
            if expectedSchemas.count != mountedToolNames.count || expectedSchemas != candidate.tools {
                reasons.append("tool_schema_digest_mismatch")
            }
        }
        return reasons
    }

    private func uniqueReasons(_ reasons: [String]) -> [String] {
        var seen: Set<String> = []
        var result: [String] = []
        for reason in reasons where seen.insert(reason).inserted {
            result.append(reason)
        }
        return result
    }

    private func suggestedFixes(failures: [C5DataGateFailure], sourceReady: Bool) -> [String] {
        var suggestions: [String] = []
        if !sourceReady {
            suggestions.append("provide authorized non-empty source snapshot digest before V-PASS")
        }
        if failures.contains(where: { $0.reason == "must_not_train_candidate_in_train" }) {
            suggestions.append("move C6/must_not_train identities out of train")
        }
        if failures.contains(where: { $0.reason == "train_parent_semantic_overlap" }) {
            suggestions.append("split by parent_semantic_id and quarantine overlaps before train")
        }
        if failures.contains(where: { $0.reason.hasPrefix("train_") && $0.reason.hasSuffix("_overlap") && $0.reason != "train_parent_semantic_overlap" }) {
            suggestions.append("split held-out by device/tool/value_type/template_family/generator_source before train")
        }
        if failures.contains(where: { $0.reason == "missing_train_device_axis_for_six_axis_split" }) {
            suggestions.append("populate train device from C5TrainingSample/semantic seed before six-axis split")
        }
        if failures.contains(where: { $0.reason == "tool_call_format_mismatch" }) {
            suggestions.append("render train action rows with shared qwen tool_call wrapper")
        }
        if failures.contains(where: { $0.reason == "missing_candidate_surface_fields" }) {
            suggestions.append("populate tools/mounted_tool_count/subset fields before formal wave-1 data gate, or rerun legacy fixtures with explicit allow_legacy_missing_surface")
        }
        if failures.contains(where: { $0.reason.hasPrefix("candidate_surface_") || $0.reason == "tool_name_not_mounted" || $0.reason == "duplicate_mounted_tool_name" || $0.reason.hasPrefix("subset_manifest_") || $0.reason.hasSuffix("_manifest_mismatch") || $0.reason.hasSuffix("_digest_mismatch") }) {
            suggestions.append("rebuild mounted tool surface from subset manifest/catalog and keep tool_name, mounted_tool_count, subset digests, and tool_schema_digest same-source")
        }
        if failures.contains(where: { $0.reason == "redaction_violation" }) {
            suggestions.append("redact prohibited raw-source text before re-running gate")
        }
        if failures.contains(where: { $0.reason.hasPrefix("prompt_hash_") || $0.reason.hasPrefix("expected_tool_call_signature_") || $0.reason.hasPrefix("hash_") }) {
            suggestions.append("recompute prompt_hash and expected_tool_call_signature in the generation pipeline using C5DerivedHashRecipe before DataGate")
        }
        return suggestions
    }

    private func hashConsistencyFailures(_ candidate: C5DataGateCandidate) -> [String] {
        var reasons: [String] = []
        let promptHash = candidate.promptHash?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        if promptHash == nil {
            reasons.append("prompt_hash_missing")
        } else if promptHash != C5DerivedHashRecipe.promptHash(utterance: candidate.inputText) {
            reasons.append("prompt_hash_mismatch")
        }
        if candidate.hashRecomputedByPipeline != true {
            reasons.append("hash_recomputed_by_pipeline_missing_or_false")
        }
        let hashRecipeRef = candidate.hashRecipeRef?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        if hashRecipeRef == nil {
            reasons.append("hash_recipe_ref_missing")
        } else if hashRecipeRef?.contains("C5LoRATraining.swift:") != true || hashRecipeRef?.contains("C6VehicleToolBench.swift:2329") != true {
            reasons.append("hash_recipe_ref_invalid")
        }
        if candidate.hasActionToolCall {
            let expectedSignature = candidate.expectedToolCallSignature?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            if expectedSignature == nil {
                reasons.append("expected_tool_call_signature_missing")
            } else if let renderedToolCall = candidate.renderedToolCall ?? C5DerivedHashRecipe.firstRenderedToolCall(in: candidate.assistantText) {
                let recomputed = C5DerivedHashRecipe.expectedToolCallSignature(renderedToolCall: renderedToolCall)
                if expectedSignature != recomputed {
                    reasons.append("expected_tool_call_signature_mismatch")
                }
            } else {
                reasons.append("expected_tool_call_signature_unrenderable")
            }
        }
        return uniqueReasons(reasons)
    }
}

private struct NormalizedCandidate {
    var candidate: C5DataGateCandidate
    var split: String
}

private struct C5ChatMessage: Decodable {
    var role: String
    var content: String
}

private struct C5InlineToolCall: Decodable {
    var wrapper: String?
    var name: String?
    var arguments: [String: JSONValue]?

    var renderedToolCall: String? {
        guard let name, !name.isEmpty else {
            return nil
        }
        return C5DerivedHashRecipe.renderToolCall(name: name, arguments: arguments ?? [:])
    }
}

private struct C5DataGateCandidateValue: Decodable {
    var type: String?
}

private struct C5ExpectedToolCall: Decodable {
    var name: String?
    var toolName: String?
    var arguments: [String: JSONValue]?

    var renderedToolCall: String? {
        let resolvedName = (name ?? toolName)?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        guard let resolvedName else {
            return nil
        }
        return C5DerivedHashRecipe.renderToolCall(name: resolvedName, arguments: arguments ?? [:])
    }

    enum CodingKeys: String, CodingKey {
        case name
        case toolName = "tool_name"
        case arguments
    }
}

private enum C5LegacyExpected {
    static func decode(from container: KeyedDecodingContainer<C5DataGateCandidate.CodingKeys>) -> [C5ExpectedToolCall]? {
        guard let expected = try? container.decodeIfPresent(C5LegacyExpectedPayload.self, forKey: .expected) else {
            return nil
        }
        return expected.frames.compactMap { frame in
            frame.type == "tool_call" ? C5ExpectedToolCall(name: nil, toolName: frame.toolName, arguments: frame.arguments) : nil
        }
    }
}

private struct C5LegacyExpectedPayload: Decodable {
    var frames: [C5LegacyFrame]
}

private struct C5LegacyFrame: Decodable {
    var type: String
    var toolName: String?
    var arguments: [String: JSONValue]?

    enum CodingKeys: String, CodingKey {
        case type
        case toolName = "tool_name"
        case arguments
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
