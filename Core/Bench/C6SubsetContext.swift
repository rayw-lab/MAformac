import Foundation

public struct C6SubsetContext: Codable, Equatable, Sendable {
    public var subsetPolicyID: String?
    public var subsetGroupID: String?
    public var mountMode: String?
    public var mountedToolIDsDigest: String?
    public var grammarToolsDigest: String?

    enum CodingKeys: String, CodingKey {
        case subsetPolicyID = "subset_policy_id"
        case subsetGroupID = "subset_group_id"
        case mountMode = "mount_mode"
        case mountedToolIDsDigest = "mounted_tool_ids_digest"
        case grammarToolsDigest = "grammar_tools_digest"
    }

    public init(
        subsetPolicyID: String? = nil,
        subsetGroupID: String? = nil,
        mountMode: String? = nil,
        mountedToolIDsDigest: String? = nil,
        grammarToolsDigest: String? = nil
    ) {
        self.subsetPolicyID = subsetPolicyID
        self.subsetGroupID = subsetGroupID
        self.mountMode = mountMode
        self.mountedToolIDsDigest = mountedToolIDsDigest
        self.grammarToolsDigest = grammarToolsDigest
    }
}

public enum C6ExpectedUnsupportedClass: String, Codable, Equatable, Sendable {
    case groupOutOfMount = "group_out_of_mount"
    case mvpUnsupported = "mvp_unsupported"
    case globalUnsupported = "global_unsupported"
}

public struct C6SubsetBenchCase: Codable, Equatable, Sendable {
    public var base: C6BenchCase
    public var subsetContext: C6SubsetContext?
    public var expectedUnsupportedClass: C6ExpectedUnsupportedClass?

    enum CodingKeys: String, CodingKey {
        case expectedUnsupportedClass = "expected_unsupported_class"
    }

    public init(
        base: C6BenchCase,
        subsetContext: C6SubsetContext? = nil,
        expectedUnsupportedClass: C6ExpectedUnsupportedClass? = nil
    ) {
        self.base = base
        self.subsetContext = subsetContext
        self.expectedUnsupportedClass = expectedUnsupportedClass
    }

    public init(from decoder: Decoder) throws {
        let subset = try C6SubsetContext(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.base = try C6BenchCase(from: decoder)
        self.subsetContext = subset.hasAnyField ? subset : nil
        self.expectedUnsupportedClass = try container.decodeIfPresent(
            C6ExpectedUnsupportedClass.self,
            forKey: .expectedUnsupportedClass
        )
    }

    public func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
        try subsetContext?.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(expectedUnsupportedClass, forKey: .expectedUnsupportedClass)
    }
}

public struct C6SubsetEvalRun: Codable, Equatable, Sendable {
    public var base: C6EvalRun
    public var subsetContext: C6SubsetContext?
    public var subsetFailureClass: C6SubsetFailureClass
    public var isModelFailure: Bool

    enum CodingKeys: String, CodingKey {
        case subsetFailureClass = "subset_failure_class"
        case isModelFailure = "is_model_failure"
    }

    public init(
        base: C6EvalRun,
        subsetContext: C6SubsetContext? = nil,
        subsetFailureClass: C6SubsetFailureClass = .none,
        isModelFailure: Bool = false
    ) {
        self.base = base
        self.subsetContext = subsetContext
        self.subsetFailureClass = subsetFailureClass
        self.isModelFailure = isModelFailure
    }

    public init(from decoder: Decoder) throws {
        let subset = try C6SubsetContext(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.base = try C6EvalRun(from: decoder)
        self.subsetContext = subset.hasAnyField ? subset : nil
        self.subsetFailureClass = try container.decodeIfPresent(
            C6SubsetFailureClass.self,
            forKey: .subsetFailureClass
        ) ?? .none
        self.isModelFailure = try container.decodeIfPresent(Bool.self, forKey: .isModelFailure) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
        try subsetContext?.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(subsetFailureClass, forKey: .subsetFailureClass)
        try container.encode(isModelFailure, forKey: .isModelFailure)
    }
}

public enum C6SubsetFailureClass: String, Codable, Equatable, Sendable {
    case missingExpectedInMounted = "missing_expected_in_mounted"
    case actualNotInAllowed = "actual_not_in_allowed"
    case unsupportedClassMismatch = "unsupported_class_mismatch"
    case none
}

public struct C6SubsetGateAccounting: Equatable, Sendable {
    public var subsetFailureClass: C6SubsetFailureClass
    public var isModelFailure: Bool

    public init(subsetFailureClass: C6SubsetFailureClass, isModelFailure: Bool) {
        self.subsetFailureClass = subsetFailureClass
        self.isModelFailure = isModelFailure
    }
}

public struct C6SubsetFailureStats: Codable, Equatable, Sendable {
    public var missingExpectedInMountedCount: Int
    public var actualNotInAllowedCount: Int
    public var unsupportedClassMismatchCount: Int

    enum CodingKeys: String, CodingKey {
        case missingExpectedInMountedCount = "missing_expected_in_mounted_count"
        case actualNotInAllowedCount = "actual_not_in_allowed_count"
        case unsupportedClassMismatchCount = "unsupported_class_mismatch_count"
    }

    public init(
        missingExpectedInMountedCount: Int,
        actualNotInAllowedCount: Int,
        unsupportedClassMismatchCount: Int = 0
    ) {
        self.missingExpectedInMountedCount = missingExpectedInMountedCount
        self.actualNotInAllowedCount = actualNotInAllowedCount
        self.unsupportedClassMismatchCount = unsupportedClassMismatchCount
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.missingExpectedInMountedCount = try container.decodeIfPresent(
            Int.self,
            forKey: .missingExpectedInMountedCount
        ) ?? 0
        self.actualNotInAllowedCount = try container.decodeIfPresent(
            Int.self,
            forKey: .actualNotInAllowedCount
        ) ?? 0
        self.unsupportedClassMismatchCount = try container.decodeIfPresent(
            Int.self,
            forKey: .unsupportedClassMismatchCount
        ) ?? 0
    }
}

public struct C6SubsetSummary: Codable, Equatable, Sendable {
    public var status: String
    public var baseSummary: C6Summary
    public var subsetFailureStats: C6SubsetFailureStats

    enum CodingKeys: String, CodingKey {
        case status
        case baseSummary = "base_summary"
        case subsetFailureStats = "subset_failure_stats"
    }

    public init(status: String, baseSummary: C6Summary, subsetFailureStats: C6SubsetFailureStats) {
        self.status = status
        self.baseSummary = baseSummary
        self.subsetFailureStats = subsetFailureStats
    }
}

public extension C6BenchRunner {
    func evaluate(
        subsetCase: C6SubsetBenchCase,
        output: C6RuntimeOutput,
        mountedToolIDs: Set<String>,
        allowedToolIDs: Set<String>,
        actualUnsupportedClass: C6ExpectedUnsupportedClass? = nil,
        runIndex: Int = 0
    ) throws -> C6SubsetEvalRun {
        let baseRun = try evaluate(case: subsetCase.base, output: output, runIndex: runIndex)
        let accounting = C6SubsetGateClassifier.classify(
            expectedToolCalls: subsetCase.base.expectedToolCalls,
            actualToolCalls: output.toolCalls,
            mountedToolIDs: mountedToolIDs,
            allowedToolIDs: allowedToolIDs,
            expectedUnsupportedClass: subsetCase.expectedUnsupportedClass,
            actualUnsupportedClass: actualUnsupportedClass,
            behaviorClass: C6CaseBehaviorClassResolver.resolve(subsetCase.base),
            baseModelHardFailed: baseRun.gateResult.modelHardFailed
        )
        let runContext = subsetCase.subsetContext ?? C6SubsetContext()
        return C6SubsetEvalRun(
            base: baseRun,
            subsetContext: runContext.hasAnyField ? runContext : nil,
            subsetFailureClass: accounting.subsetFailureClass,
            isModelFailure: accounting.isModelFailure
        )
    }

    func summarize(
        subsetCases: [C6SubsetBenchCase],
        subsetRuns: [C6SubsetEvalRun],
        validation: C6DatasetValidation
    ) -> C6SubsetSummary {
        let baseSummary = summarize(
            cases: subsetCases.map(\.base),
            runs: subsetRuns.map(\.base),
            validation: validation
        )
        let missing = subsetRuns.filter { $0.subsetFailureClass == .missingExpectedInMounted }.count
        let actualNotAllowed = subsetRuns.filter { $0.subsetFailureClass == .actualNotInAllowed }.count
        let unsupportedClassMismatch = subsetRuns.filter {
            $0.subsetFailureClass == .unsupportedClassMismatch
        }.count
        let stats = C6SubsetFailureStats(
            missingExpectedInMountedCount: missing,
            actualNotInAllowedCount: actualNotAllowed,
            unsupportedClassMismatchCount: unsupportedClassMismatch
        )
        let hasSubsetFailure = subsetRuns.contains { $0.subsetFailureClass != .none }
        let status = hasSubsetFailure
            ? "construction_subset_blocked"
            : baseSummary.status
        return C6SubsetSummary(status: status, baseSummary: baseSummary, subsetFailureStats: stats)
    }
}

public enum C6SubsetGateClassifier {
    public static func classify(
        expectedToolCalls: [C6ToolCall],
        actualToolCalls: [C6ToolCall],
        mountedToolIDs: Set<String>,
        allowedToolIDs: Set<String>,
        expectedUnsupportedClass: C6ExpectedUnsupportedClass? = nil,
        actualUnsupportedClass: C6ExpectedUnsupportedClass? = nil,
        behaviorClass: VehicleToolBehaviorClass? = nil,
        baseModelHardFailed: Bool = false
    ) -> C6SubsetGateAccounting {
        let expectedIDs = Set(expectedToolCalls.map(\.name))
        let actualIDs = Set(actualToolCalls.map(\.name))
        let missingExpectedInMounted = !expectedIDs.subtracting(mountedToolIDs).isEmpty
        let actualNotInAllowed = !actualIDs.subtracting(allowedToolIDs).isEmpty
        let derivedUnsupportedClass = deriveUnsupportedClass(
            expectedIDs: expectedIDs,
            mountedToolIDs: mountedToolIDs,
            actualUnsupportedClass: actualUnsupportedClass,
            behaviorClass: behaviorClass
        )

        let subsetFailureClass: C6SubsetFailureClass
        if let expectedUnsupportedClass {
            if expectedUnsupportedClass != derivedUnsupportedClass {
                subsetFailureClass = .unsupportedClassMismatch
            } else if actualNotInAllowed {
                subsetFailureClass = .actualNotInAllowed
            } else {
                subsetFailureClass = .none
            }
        } else if missingExpectedInMounted {
            subsetFailureClass = .missingExpectedInMounted
        } else if actualNotInAllowed {
            subsetFailureClass = .actualNotInAllowed
        } else {
            subsetFailureClass = .none
        }

        if subsetFailureClass == .missingExpectedInMounted {
            return C6SubsetGateAccounting(
                subsetFailureClass: subsetFailureClass,
                isModelFailure: false
            )
        }

        return C6SubsetGateAccounting(
            subsetFailureClass: subsetFailureClass,
            isModelFailure: baseModelHardFailed || actualNotInAllowed
        )
    }

    private static func deriveUnsupportedClass(
        expectedIDs: Set<String>,
        mountedToolIDs: Set<String>,
        actualUnsupportedClass: C6ExpectedUnsupportedClass?,
        behaviorClass: VehicleToolBehaviorClass?
    ) -> C6ExpectedUnsupportedClass? {
        if !expectedIDs.subtracting(mountedToolIDs).isEmpty {
            return .groupOutOfMount
        }
        if let actualUnsupportedClass {
            return actualUnsupportedClass
        }
        if behaviorClass == .refusalNoAvailableTool {
            return .mvpUnsupported
        }
        return nil
    }
}

public enum C6SubsetDigestVerdict: String, Codable, Equatable, Sendable {
    case pass = "PASS"
    case blocked = "BLOCKED"
}

public struct C6SubsetDigestAxes: Codable, Equatable, Sendable {
    public var targetInPrompt: Bool
    public var expectedInMounted: Bool
    public var actualInAllowed: Bool
    public var promptToolsDigest: String
    public var grammarToolsDigest: String
    public var subsetPolicyDigest: String

    enum CodingKeys: String, CodingKey {
        case targetInPrompt = "target_in_prompt"
        case expectedInMounted = "expected_in_mounted"
        case actualInAllowed = "actual_in_allowed"
        case promptToolsDigest = "prompt_tools_digest"
        case grammarToolsDigest = "grammar_tools_digest"
        case subsetPolicyDigest = "subset_policy_digest"
    }
}

public struct C6SubsetDigestReceipt: Codable, Equatable, Sendable {
    public var receiptVersion: String
    public var verdict: C6SubsetDigestVerdict
    public var axes: C6SubsetDigestAxes
    public var mismatchReasons: [String]

    enum CodingKeys: String, CodingKey {
        case receiptVersion = "receipt_version"
        case verdict
        case axes
        case mismatchReasons = "mismatch_reasons"
    }
}

public struct C6SubsetDigestReceiptInput: Equatable, Sendable {
    public var targetToolIDs: [String]
    public var promptToolIDs: [String]
    public var expectedToolIDs: [String]
    public var mountedToolIDs: [String]
    public var actualToolIDs: [String]
    public var allowedToolIDs: [String]
    public var grammarToolIDs: [String]
    public var subsetContext: C6SubsetContext
    public var expectedPromptToolsDigest: String?
    public var expectedGrammarToolsDigest: String?
    public var expectedSubsetPolicyDigest: String?

    public init(
        targetToolIDs: [String],
        promptToolIDs: [String],
        expectedToolIDs: [String],
        mountedToolIDs: [String],
        actualToolIDs: [String],
        allowedToolIDs: [String],
        grammarToolIDs: [String],
        subsetContext: C6SubsetContext,
        expectedPromptToolsDigest: String? = nil,
        expectedGrammarToolsDigest: String? = nil,
        expectedSubsetPolicyDigest: String? = nil
    ) {
        self.targetToolIDs = targetToolIDs
        self.promptToolIDs = promptToolIDs
        self.expectedToolIDs = expectedToolIDs
        self.mountedToolIDs = mountedToolIDs
        self.actualToolIDs = actualToolIDs
        self.allowedToolIDs = allowedToolIDs
        self.grammarToolIDs = grammarToolIDs
        self.subsetContext = subsetContext
        self.expectedPromptToolsDigest = expectedPromptToolsDigest
        self.expectedGrammarToolsDigest = expectedGrammarToolsDigest
        self.expectedSubsetPolicyDigest = expectedSubsetPolicyDigest
    }
}

public enum C6SubsetDigestReceiptWriter {
    public static func write(_ input: C6SubsetDigestReceiptInput) throws -> C6SubsetDigestReceipt {
        let promptDigest = try digest(input.promptToolIDs)
        let grammarDigest = try digest(input.grammarToolIDs)
        let policyDigest = try digest(input.subsetContext)
        let axes = C6SubsetDigestAxes(
            targetInPrompt: Set(input.targetToolIDs).isSubset(of: Set(input.promptToolIDs)),
            expectedInMounted: Set(input.expectedToolIDs).isSubset(of: Set(input.mountedToolIDs)),
            actualInAllowed: Set(input.actualToolIDs).isSubset(of: Set(input.allowedToolIDs)),
            promptToolsDigest: promptDigest,
            grammarToolsDigest: grammarDigest,
            subsetPolicyDigest: policyDigest
        )
        let reasons = mismatchReasons(input: input, axes: axes)
        return C6SubsetDigestReceipt(
            receiptVersion: "c6_subset_digest_receipt.v1",
            verdict: reasons.isEmpty ? .pass : .blocked,
            axes: axes,
            mismatchReasons: reasons
        )
    }

    public static func digest(_ values: [String]) throws -> String {
        C6Hash.sha256Hex(try C6CanonicalJSON.encode(values.sorted()))
    }

    public static func digest(_ context: C6SubsetContext) throws -> String {
        C6Hash.sha256Hex(try C6CanonicalJSON.encode(context))
    }

    private static func mismatchReasons(
        input: C6SubsetDigestReceiptInput,
        axes: C6SubsetDigestAxes
    ) -> [String] {
        var reasons: [String] = []
        if !axes.targetInPrompt {
            reasons.append("target_not_in_prompt")
        }
        if !axes.expectedInMounted {
            reasons.append("expected_not_in_mounted")
        }
        if !axes.actualInAllowed {
            reasons.append("actual_not_in_allowed")
        }
        if let expected = input.expectedPromptToolsDigest, expected != axes.promptToolsDigest {
            reasons.append("prompt_tools_digest_mismatch")
        }
        if let expected = input.expectedGrammarToolsDigest, expected != axes.grammarToolsDigest {
            reasons.append("grammar_tools_digest_mismatch")
        }
        if let expected = input.expectedSubsetPolicyDigest, expected != axes.subsetPolicyDigest {
            reasons.append("subset_policy_digest_mismatch")
        }
        return reasons
    }
}

private extension C6SubsetContext {
    var hasAnyField: Bool {
        subsetPolicyID != nil
            || subsetGroupID != nil
            || mountMode != nil
            || mountedToolIDsDigest != nil
            || grammarToolsDigest != nil
    }
}
