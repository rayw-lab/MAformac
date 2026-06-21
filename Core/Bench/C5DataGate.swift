import Foundation

public struct C5DataGateCandidate: Decodable, Sendable {
    public var sampleID: String
    public var split: String?
    public var bucket: String
    public var caseID: String?
    public var parentSemanticID: String?
    public var mustNotTrain: Bool
    public var sourceAuthorization: String?
    public var inputText: String
    public var assistantText: String
    public var hasActionToolCall: Bool
    public var hasSharedWrapper: Bool
    public var masking: C5MaskingFlags

    enum CodingKeys: String, CodingKey {
        case sampleID = "sample_id"
        case split
        case bucket
        case datasetBucket = "dataset_bucket"
        case caseID = "case_id"
        case parentSemanticID = "parent_semantic_id"
        case parentID = "parent_id"
        case scenarioFamilyID = "scenario_family_id"
        case mustNotTrain = "must_not_train"
        case sourceAuthorization = "source_authorization"
        case inputZh = "input_zh"
        case utterance
        case queryTemplate = "query_template"
        case messages
        case toolCall = "tool_call"
        case expectedToolCalls = "expected_tool_calls"
        case expected
        case masking
    }

    public init(
        sampleID: String,
        split: String?,
        bucket: String,
        caseID: String?,
        parentSemanticID: String?,
        mustNotTrain: Bool,
        sourceAuthorization: String?,
        inputText: String,
        assistantText: String,
        hasActionToolCall: Bool,
        hasSharedWrapper: Bool,
        masking: C5MaskingFlags
    ) {
        self.sampleID = sampleID
        self.split = split
        self.bucket = bucket
        self.caseID = caseID
        self.parentSemanticID = parentSemanticID
        self.mustNotTrain = mustNotTrain
        self.sourceAuthorization = sourceAuthorization
        self.inputText = inputText
        self.assistantText = assistantText
        self.hasActionToolCall = hasActionToolCall
        self.hasSharedWrapper = hasSharedWrapper
        self.masking = masking
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
        let explicitWrapper = toolCall?.wrapper == "tool_call"
        self.sampleID = sampleID
        self.split = try container.decodeIfPresent(String.self, forKey: .split)
        self.bucket = bucket
        self.caseID = caseID
        self.parentSemanticID = try container.decodeIfPresent(String.self, forKey: .parentSemanticID)
            ?? container.decodeIfPresent(String.self, forKey: .parentID)
            ?? container.decodeIfPresent(String.self, forKey: .scenarioFamilyID)
        self.mustNotTrain = try container.decodeIfPresent(Bool.self, forKey: .mustNotTrain) ?? false
        self.sourceAuthorization = try container.decodeIfPresent(String.self, forKey: .sourceAuthorization)
        self.inputText = try container.decodeIfPresent(String.self, forKey: .inputZh)
            ?? container.decodeIfPresent(String.self, forKey: .utterance)
            ?? container.decodeIfPresent(String.self, forKey: .queryTemplate)
            ?? messages.first { $0.role == "user" }?.content
            ?? ""
        self.assistantText = assistantText
        self.hasActionToolCall = !(expectedToolCalls ?? []).isEmpty || toolCall != nil
        self.hasSharedWrapper = explicitWrapper || assistantText.contains("<tool_call>")
        self.masking = (try container.decodeIfPresent(C5MaskingFlags.self, forKey: .masking)) ?? C5MaskingFlags()
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

    public init(
        sourceSnapshotDigest: String,
        sourceAuthorizationStatus: String,
        formatContractVersion: String,
        generatedAt: String
    ) {
        self.sourceSnapshotDigest = sourceSnapshotDigest
        self.sourceAuthorizationStatus = sourceAuthorizationStatus
        self.formatContractVersion = formatContractVersion
        self.generatedAt = generatedAt
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
    public var toolCallFormatPass: Int
    public var toolCallFormatFailures: [C5DataGateFailure]
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
        case toolCallFormatPass = "tool_call_format_pass"
        case toolCallFormatFailures = "tool_call_format_failures"
        case maskingCoverage = "masking_coverage"
        case redactionStatus = "redaction_status"
        case quarantineCount = "quarantine_count"
        case failureReceipt = "failure_receipt"
        case proposedFix = "proposed_fix"
    }

    public var hasHardFailure: Bool {
        mustNotTrainViolations > 0
            || trainParentSemanticOverlap > 0
            || !toolCallFormatFailures.isEmpty
            || redactionStatus == "fail"
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

    public init() {}

    public func receipt(
        candidates: [C5DataGateCandidate],
        c6Cases: [C6BenchCase],
        context: C5DataGateRunContext
    ) -> C5DataGateReceipt {
        let protectedCaseIDs = Set(c6Cases.filter { $0.tags.mustPass || $0.tags.mustNotTrain }.map(\.caseID))
        let protectedParents = Set(c6Cases.filter { $0.tags.mustPass || $0.tags.mustNotTrain }.flatMap(\.sourceRefs.semanticContractIDs))
        let normalized = candidates.map { NormalizedCandidate(candidate: $0, split: normalizedSplit($0)) }
        let nonTrainParents = Set(normalized.filter { $0.split != "train" && $0.split != "dev_selection" && $0.split != "quarantine" }.compactMap(\.candidate.parentSemanticID))
            .union(protectedParents)
        let trainOverlapParents = Set(normalized.filter { $0.split == "train" }.compactMap(\.candidate.parentSemanticID))
            .intersection(nonTrainParents)
        var failures: [C5DataGateFailure] = []
        var formatFailures: [C5DataGateFailure] = []
        var redactionFailures: [C5DataGateFailure] = []
        var mustNotTrainViolations = 0
        var toolCallFormatPass = 0
        var quarantineCount = 0

        for item in normalized {
            let candidate = item.candidate
            var isQuarantined = item.split == "quarantine"
            if item.split == "train" && (candidate.mustNotTrain || candidate.caseID.map(protectedCaseIDs.contains) == true) {
                mustNotTrainViolations += 1
                failures.append(failure(candidate, split: item.split, reason: "must_not_train_candidate_in_train", severity: "P0"))
            }
            if item.split == "train", let parent = candidate.parentSemanticID, trainOverlapParents.contains(parent) {
                failures.append(failure(candidate, split: item.split, reason: "train_parent_semantic_overlap", severity: "P1"))
            }
            if item.split == "train" && candidate.parentSemanticID == nil {
                failures.append(failure(candidate, split: item.split, reason: "missing_parent_semantic_id_for_train", severity: "P1"))
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
            $0.split == "train" && ($0.candidate.parentSemanticID.map(trainOverlapParents.contains) == true)
        }.count
        let status: String
        if mustNotTrainViolations > 0 || hardTrainOverlap > 0 || !formatFailures.isEmpty || !redactionFailures.isEmpty {
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
            toolCallFormatPass: toolCallFormatPass,
            toolCallFormatFailures: formatFailures,
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
        - tool_call_format_pass: \(receipt.toolCallFormatPass)
        - tool_call_format_failures: \(receipt.toolCallFormatFailures.count)
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

    private func failure(_ candidate: C5DataGateCandidate, split: String, reason: String, severity: String) -> C5DataGateFailure {
        C5DataGateFailure(
            sampleID: candidate.sampleID,
            caseID: candidate.caseID,
            split: split,
            bucket: candidate.bucket,
            parentSemanticID: candidate.parentSemanticID,
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
        if failures.contains(where: { $0.reason == "tool_call_format_mismatch" }) {
            suggestions.append("render train action rows with shared qwen tool_call wrapper")
        }
        if failures.contains(where: { $0.reason == "redaction_violation" }) {
            suggestions.append("redact prohibited raw-source text before re-running gate")
        }
        return suggestions
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
    var arguments: [String: C5LooseJSON]?
}

private struct C5ExpectedToolCall: Decodable {
    var name: String?
    var toolName: String?
    var arguments: [String: C5LooseJSON]?

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
    var arguments: [String: C5LooseJSON]?

    enum CodingKeys: String, CodingKey {
        case type
        case toolName = "tool_name"
        case arguments
    }
}

private enum C5LooseJSON: Decodable, Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object
    case array
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if (try? container.decode([String: C5LooseJSON].self)) != nil {
            self = .object
        } else if (try? container.decode([C5LooseJSON].self)) != nil {
            self = .array
        } else {
            self = .null
        }
    }
}
